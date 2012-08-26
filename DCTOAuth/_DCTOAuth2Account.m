//
//  DCTOAuth2Account.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth2Account.h"
#import "_DCTOAuthAccount.h"
#import "NSString+DCTOAuth.h"
#import "_DCTOAuthURLProtocol.h"
#import <UIKit/UIKit.h>

@implementation _DCTOAuth2Account {
	__strong NSString *_state;
}

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
		  clientID:(NSString *)clientID
	  clientSecret:(NSString *)clientSecret
			scopes:(NSArray *)scopes {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	_authorizeURL = [authorizeURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_clientID = [clientID copy];
	_clientSecret = [clientSecret copy];
	_scopes = [scopes copy];
	_state = [[NSProcessInfo processInfo] globallyUniqueString];
	
	return self;
}

- (void)_authorizeWithParameters:(NSDictionary *)inputParameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:inputParameters];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];
	[parameters setObject:self.clientID forKey:@"client_id"];
	[parameters setObject:@"code" forKey:@"response_type"];
	[parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];
	[parameters setObject:_state forKey:@"state"];
	
	NSMutableArray *keyValues = [NSMutableArray new];
	[parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		[keyValues addObject:[NSString stringWithFormat:@"%@=%@", key, [value dctOAuth_URLEncodedString]]];
	}];
	
	NSString *authorizeURLString = [NSString stringWithFormat:@"%@?%@", [self.authorizeURL absoluteString], [keyValues componentsJoinedByString:@"&"]];
	NSURL *authorizeURL = [NSURL URLWithString:authorizeURLString];
	
	[_DCTOAuthURLProtocol registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		[_DCTOAuthURLProtocol unregisterForCallbackURL:self.callbackURL];
		
		NSDictionary *dictionary = [[URL query] dctOAuth_parameterDictionary];
		completion(dictionary);
	}];
		
	[[UIApplication sharedApplication] openURL:authorizeURL];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {
	
	NSMutableDictionary *returnedValues = [NSMutableDictionary new];
	
	void (^tokenCompletion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		if (handler != NULL) handler([returnedValues copy]);
	};
	
	void (^authorizeCompletion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		[self _fetchTokenWithParameters:dictionary completion:tokenCompletion];
	};
	
	[self _authorizeWithParameters:nil completion:authorizeCompletion];
}

- (void)_fetchTokenWithParameters:(NSDictionary *)inputParameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:inputParameters];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];
	[parameters setObject:self.clientID forKey:@"client_id"];
	[parameters setObject:self.clientSecret forKey:@"client_secret"];
	[parameters setObject:self.code forKey:@"code"];
	[parameters setObject:_state forKey:@"state"];
	
	NSLog(@"%@:%@ %@ %@", self, NSStringFromSelector(_cmd), self.accessTokenURL, parameters);
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:self.accessTokenURL
                                                      requestMethod:DCTOAuthRequestMethodPOST
                                                         parameters:parameters];
	
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
		if (!dictionary) {
			NSString *string= [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			dictionary = [string dctOAuth_parameterDictionary];
		}
		completion(dictionary);
	}];
}

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest {
	
	NSString *format = @"%@=%@";
	if (OAuthRequest.requestMethod == DCTOAuthRequestMethodGET)
		format = @"%@=\"%@\"";
	
	NSMutableArray *parameters = [NSMutableArray new];
	[OAuthRequest.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [key dctOAuth_URLEncodedString];
        NSString *encodedValue = [value dctOAuth_URLEncodedString];
		NSString *string = [NSString stringWithFormat:format, encodedKey, encodedValue];
		[parameters addObject:string];
	}];
	NSString *parameterString = [parameters componentsJoinedByString:@"&"];
	
	NSURL *URL = OAuthRequest.URL;
	if (OAuthRequest.requestMethod == DCTOAuthRequestMethodGET) {
		NSString *URLString = [NSString stringWithFormat:@"%@?%@", [URL absoluteString], parameterString];
		URL = [NSURL URLWithString:URLString];
	}
	
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), URL);
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), parameterString);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
	[request setHTTPMethod:NSStringFromDCTOAuthRequestMethod(OAuthRequest.requestMethod)];

	if (OAuthRequest.requestMethod != DCTOAuthRequestMethodGET)
		[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return request;
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), dictionary);
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"code"])
			_code = value;
		
		else if ([key isEqualToString:@"access_token"])
			_accessToken = value;
		
		else if ([key isEqualToString:@"refresh_token"])
			_refreshToken = value;
	}];
}

@end
