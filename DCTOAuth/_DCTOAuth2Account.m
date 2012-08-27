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
#import "_DCTOAuth.h"
#import "NSURL+DCTOAuth.h"
#import <UIKit/UIKit.h>

@implementation _DCTOAuth2Account {
	
	__strong NSURL *_authorizeURL;
	__strong NSURL *_accessTokenURL;
	
	__strong NSString *_clientID;
	__strong NSString *_clientSecret;
	
	__strong NSArray *_scopes;
	
	__strong NSString *_code;
	__strong NSString *_accessToken;
	__strong NSString *_refreshToken;
	
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

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	
	_authorizeURL = [coder decodeObjectForKey:@"_authorizeURL"];
	_accessTokenURL = [coder decodeObjectForKey:@"_accessTokenURL"];
	
	_clientID = [self _valueForSecureKey:@"_clientID"];
	_clientSecret = [self _valueForSecureKey:@"_clientSecret"];
	
	_scopes = [coder decodeObjectForKey:@"_scopes"];
	
	_code = [self _valueForSecureKey:@"_code"];
	_accessToken = [self _valueForSecureKey:@"_accessToken"];
	_refreshToken = [self _valueForSecureKey:@"_refreshToken"];
	
	_state = [self _valueForSecureKey:@"_state"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	
	[self _setValue:_clientID forSecureKey:@"_clientID"];
	[self _setValue:_clientSecret forSecureKey:@"_clientSecret"];
	
	[coder encodeObject:_scopes forKey:@"_scopes"];
	
	[self _setValue:_code forSecureKey:@"_code"];
	[self _setValue:_accessToken forSecureKey:@"_accessToken"];
	[self _setValue:_refreshToken forSecureKey:@"_refreshToken"];
	
	[self _setValue:_state forSecureKey:@"_state"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {
	
	NSMutableDictionary *returnedValues = [NSMutableDictionary new];
	
	void (^completion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		if (handler != NULL) handler([returnedValues copy]);
	};
	
	void (^fetchToken)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		[self _fetchTokenWithCompletion:completion];
	};
	
	[self _authorizeWithCompletion:fetchToken];
}

- (void)_authorizeWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:_authorizeURL
                                                      requestMethod:DCTOAuthRequestMethodGET
                                                         parameters:[self _OAuthParameters]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	[DCTOAuth _registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		NSDictionary *dictionary = [[URL query] dctOAuth_parameterDictionary];
		completion(dictionary);
	}];
	
#ifdef TARGET_OS_IPHONE
	[[UIApplication sharedApplication] openURL:authorizeURL];
#else
	[[NSWorkspace sharedWorkspace] openURL:authorizeURL];
#endif
}

- (void)_fetchTokenWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:_accessTokenURL
                                                      requestMethod:DCTOAuthRequestMethodPOST
                                                         parameters:nil];
	
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

- (void)_signURLRequest:(NSMutableURLRequest *)request {
	NSURL *URL = [request URL];
	URL = [URL dctOAuth_URLByAddingQueryParameters:[self _OAuthParameters]];
	request.URL = URL;
}

- (NSDictionary *)_OAuthParameters {
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	
	if (_accessToken) {
		[parameters setObject:_accessToken forKey:@"access_token"];
		return [parameters copy];
	}
	
	[parameters setObject:_clientID forKey:@"client_id"];
	[parameters setObject:_state forKey:@"state"];
	if ([_scopes count] > 0) [parameters setObject:[_scopes componentsJoinedByString:@","] forKey:@"scope"];
	if (_clientSecret) [parameters setObject:_clientSecret forKey:@"client_secret"];
	if (_code) [parameters setObject:_code forKey:@"code"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];
	
	return [parameters copy];
}

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest {
	
	NSString *format = @"%@=%@";
	if (OAuthRequest.requestMethod == DCTOAuthRequestMethodGET)
		format = @"%@=\"%@\"";
	
	NSMutableDictionary *parameters = [OAuthRequest.parameters mutableCopy];
	if ([_accessToken length] > 0) [parameters setObject:_accessToken forKey:@"access_token"];
	
	
	
	
	
	
	NSMutableArray *parameterStrings = [NSMutableArray new];
	[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [key dctOAuth_URLEncodedString];
        NSString *encodedValue = [value dctOAuth_URLEncodedString];
		NSString *string = [NSString stringWithFormat:format, encodedKey, encodedValue];
		[parameterStrings addObject:string];
	}];
	
	NSString *parameterString = [parameterStrings componentsJoinedByString:@"&"];
	
	NSURL *URL = OAuthRequest.URL;
	if (OAuthRequest.requestMethod == DCTOAuthRequestMethodGET) {
		NSString *URLString = [NSString stringWithFormat:@"%@?%@", [URL absoluteString], parameterString];
		URL = [NSURL URLWithString:URLString];
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
	[request setHTTPMethod:NSStringFromDCTOAuthRequestMethod(OAuthRequest.requestMethod)];

	if (OAuthRequest.requestMethod != DCTOAuthRequestMethodGET)
		[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return request;
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"code"])
			_code = value;
		
		else if ([key isEqualToString:@"access_token"])
			_accessToken = value;
		
		else if ([key isEqualToString:@"refresh_token"])
			_refreshToken = value;
	}];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; clientID = %@; code = %@>",
			NSStringFromClass([self class]),
			self,
			_clientID,
			_code];
}

@end
