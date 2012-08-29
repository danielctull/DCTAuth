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
	
	void (^fetchAccessToken)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		[self _fetchAccessTokenWithCompletion:completion];
	};
	
	// If there's no access token URL, skip it.
	// This is the "Implicit Authentication Flow"
	if (!_accessTokenURL) fetchAccessToken = completion;
	
	[self _authorizeWithCompletion:fetchAccessToken];
}

- (void)_authorizeWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:[self _OAuthParameters]];
	if (!_accessTokenURL) [parameters setObject:@"token" forKey:@"response_type"];
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithURL:_authorizeURL
                                                      requestMethod:DCTAuthRequestMethodGET
                                                         parameters:parameters];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	[DCTAuth _registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		NSMutableDictionary *dictionary = [NSMutableDictionary new];
		NSDictionary *queryDictionary = [[URL query] dctOAuth_parameterDictionary];
		[dictionary addEntriesFromDictionary:queryDictionary];
		NSDictionary *fragmentDictionary = [[URL fragment] dctOAuth_parameterDictionary];
		[dictionary addEntriesFromDictionary:fragmentDictionary];
		completion([dictionary copy]);
	}];
	
#ifdef TARGET_OS_IPHONE
	[[UIApplication sharedApplication] openURL:authorizeURL];
#else
	[[NSWorkspace sharedWorkspace] openURL:authorizeURL];
#endif
}

- (void)_fetchAccessTokenWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithURL:_accessTokenURL
                                                      requestMethod:DCTAuthRequestMethodGET
                                                         parameters:[self _OAuthParameters]];
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
		if (!dictionary) {
			NSString *string= [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			dictionary = [string dctOAuth_parameterDictionary];
		}
		completion(dictionary);
	}];
}

- (void)_signURLRequest:(NSMutableURLRequest *)request oauthRequest:(DCTAuthRequest *)oauthRequest {
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
	return [NSString stringWithFormat:@"<%@: %p; type = %@; clientID = %@; has code = %@; has access token = %@>",
			NSStringFromClass([self class]),
			self,
			self.type,
			_clientID,
			_code ? @"YES" : @"NO",
			_accessToken ? @"YES" : @"NO"];
}

@end
