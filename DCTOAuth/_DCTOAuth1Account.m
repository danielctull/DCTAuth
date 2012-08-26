//
//  DCTOAuth1Account.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth1Account.h"
#import "_DCTOAuthAccount.h"
#import "DCTOAuthRequest.h"
#import "_DCTOAuthSignature.h"
#import "NSString+DCTOAuth.h"
#import "_DCTOAuthURLProtocol.h"
#import <UIKit/UIKit.h>

@implementation _DCTOAuth1Account

- (id)initWithType:(NSString *)type
   requestTokenURL:(NSURL *)requestTokenURL
	  authorizeURL:(NSURL *)authorizeURL
	   callbackURL:(NSURL *)callbackURL
	accessTokenURL:(NSURL *)accessTokenURL
	   consumerKey:(NSString *)consumerKey
	consumerSecret:(NSString *)consumerSecret {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_callbackURL = [callbackURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	
	return self;
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {
	
	NSMutableDictionary *returnedValues = [NSMutableDictionary new];
	
	void (^requestTokenCompletion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		if (handler != NULL) handler([returnedValues copy]);
	};
	
	void (^authorizeCompletion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		[self fetchRequestTokenWithParameters:dictionary completion:requestTokenCompletion];
	};
	
	void (^accessTokenCompletion)(NSDictionary *) = nil;
	
	if (self.authorizeURL) {
		accessTokenCompletion = ^(NSDictionary *dictionary) {
			[returnedValues addEntriesFromDictionary:dictionary];
			[self _setValuesFromOAuthDictionary:dictionary];
			[self authorizeWithParameters:dictionary completion:authorizeCompletion];
		};
	} else {
		accessTokenCompletion = ^(NSDictionary *dictionary) {
			[returnedValues addEntriesFromDictionary:dictionary];
			[self _setValuesFromOAuthDictionary:dictionary];
			[self fetchRequestTokenWithParameters:dictionary completion:requestTokenCompletion];
		};
	}
	
	[self fetchAccessTokenWithParameters:nil completion:accessTokenCompletion];
}

- (void)fetchAccessTokenWithParameters:(NSDictionary *)userParameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:userParameters];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:self.requestTokenURL
                                                      requestMethod:DCTOAuthRequestMethodGET
                                                         parameters:parameters];
	
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [self _dictionaryFromString:string];
		completion(dictionary);
	}];
}

- (void)fetchRequestTokenWithParameters:(NSDictionary *)parameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:self.accessTokenURL
                                                      requestMethod:DCTOAuthRequestMethodGET
                                                         parameters:parameters];
	
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [self _dictionaryFromString:string];
		completion(dictionary);
	}];
}


- (void)authorizeWithParameters:(NSDictionary *)inputParameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:inputParameters];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	
	NSMutableArray *keyValues = [NSMutableArray new];
	[parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		[keyValues addObject:[NSString stringWithFormat:@"%@=%@", key, [value dctOAuth_URLEncodedString]]];
	}];
	
	NSString *authorizeURLString = [NSString stringWithFormat:@"%@?%@", [self.authorizeURL absoluteString], [keyValues componentsJoinedByString:@"&"]];
	NSURL *authorizeURL = [NSURL URLWithString:authorizeURLString];
	
	[_DCTOAuthURLProtocol registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		[_DCTOAuthURLProtocol unregisterForCallbackURL:self.callbackURL];
		
		NSDictionary *dictionary = [self _dictionaryFromString:[URL query]];
		completion(dictionary);
	}];
	[[UIApplication sharedApplication] openURL:authorizeURL];
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"oauth_token"])
			_oauthToken = value;
		
		else if ([key isEqualToString:@"oauth_token_secret"])
			_oauthTokenSecret = value;
		
		else if ([key isEqualToString:@"oauth_verifier"])
			_oauthVerifier = value;
	}];
}

- (NSDictionary *)_dictionaryFromString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@"&"];
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	[components enumerateObjectsUsingBlock:^(NSString *keyValueString, NSUInteger idx, BOOL *stop) {
		NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
		if ([keyValueArray count] != 2) return;
		[dictionary setObject:[keyValueArray objectAtIndex:1] forKey:[keyValueArray objectAtIndex:0]];
	}];
	return [dictionary copy];
}

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest {
	
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:OAuthRequest.URL
															requestMethod:OAuthRequest.requestMethod
															  consumerKey:self.consumerKey
														   consumerSecret:self.consumerSecret
																	token:self.oauthToken
															  secretToken:self.oauthTokenSecret
															   parameters:OAuthRequest.parameters];
	
	NSMutableArray *parameters = [NSMutableArray new];
	[signature.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [key dctOAuth_URLEncodedString];
        NSString *encodedValue = [value dctOAuth_URLEncodedString];
		NSString *string = [NSString stringWithFormat:@"%@=\"%@\"", encodedKey, encodedValue];
		[parameters addObject:string];
	}];
	
	NSString *string = [NSString stringWithFormat:@"oauth_signature=\"%@\"", [signature signedString]];
	[parameters addObject:string];
	NSString *parameterString = [parameters componentsJoinedByString:@","];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:OAuthRequest.URL];
	[request setHTTPMethod:NSStringFromDCTOAuthRequestMethod(OAuthRequest.requestMethod)];
	[request setAllHTTPHeaderFields:@{ @"Authorization" : [NSString stringWithFormat:@"OAuth %@", parameterString]}];
	return request;
}

@end
