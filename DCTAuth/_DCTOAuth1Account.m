//
//  _DCTOAuth1Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth1Account.h"
#import "_DCTAuthAccount.h"
#import "DCTAuthRequest.h"
#import "_DCTOAuthSignature.h"
#import "NSString+DCTAuth.h"
#import "_DCTAuth.h"

#ifdef TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif


@implementation _DCTOAuth1Account {
	__strong NSURL *_requestTokenURL;
	__strong NSURL *_accessTokenURL;
	__strong NSURL *_authorizeURL;
	
	__strong NSString *_consumerKey;
	__strong NSString *_consumerSecret;
	
	__strong NSString *_oauthToken;
	__strong NSString *_oauthTokenSecret;
	__strong NSString *_oauthVerifier;
}

- (id)initWithType:(NSString *)type
   requestTokenURL:(NSURL *)requestTokenURL
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
	   consumerKey:(NSString *)consumerKey
	consumerSecret:(NSString *)consumerSecret {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	
	_requestTokenURL = [coder decodeObjectForKey:@"_requestTokenURL"];
	_accessTokenURL = [coder decodeObjectForKey:@"_accessTokenURL"];
	_authorizeURL = [coder decodeObjectForKey:@"_authorizeURL"];
	
	_consumerKey = [self _valueForSecureKey:@"_consumerKey"];
	_consumerSecret = [self _valueForSecureKey:@"_consumerSecret"];
	
	_oauthToken = [self _valueForSecureKey:@"_oauthToken"];
	_oauthTokenSecret = [self _valueForSecureKey:@"_oauthTokenSecret"];
	_oauthVerifier = [self _valueForSecureKey:@"_oauthVerifier"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_requestTokenURL forKey:@"_requestTokenURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	
	[self _setValue:_consumerKey forSecureKey:@"_consumerKey"];
	[self _setValue:_consumerSecret forSecureKey:@"_consumerSecret"];
	
	[self _setValue:_oauthToken forSecureKey:@"_oauthToken"];
	[self _setValue:_oauthTokenSecret forSecureKey:@"_oauthTokenSecret"];
	[self _setValue:_oauthVerifier forSecureKey:@"_oauthVerifier"];
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
	
	void (^authorizeUser)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		[self _authorizeWithCompletion:fetchAccessToken];
	};
	
	// If there's no authorizeURL, assume there is no authorize step.
	// This is valid as shown by the server used in the demo app.
	if (!_authorizeURL) authorizeUser = fetchAccessToken;
	
	[self _fetchRequestTokenWithCompletion:authorizeUser];
}

- (void)_fetchRequestTokenWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithURL:_requestTokenURL
                                                      requestMethod:DCTAuthRequestMethodGET
                                                         parameters:nil];
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [string dctAuth_parameterDictionary];
		completion(dictionary);
	}];
}

- (void)_authorizeWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithURL:_authorizeURL
                                                      requestMethod:DCTAuthRequestMethodGET
                                                         parameters:[self _OAuthParameters]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	[DCTAuth _registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		NSDictionary *dictionary = [[URL query] dctAuth_parameterDictionary];
		completion(dictionary);
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
                                                         parameters:nil];
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [string dctAuth_parameterDictionary];
		[self _setAuthorized:([dictionary objectForKey:@"oauth_token_secret"] != nil)];
		completion(dictionary);
	}];
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

- (NSDictionary *)_OAuthParameters {
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters setObject:_consumerKey forKey:@"oauth_consumer_key"];
	[parameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	if (_oauthToken) [parameters setObject:_oauthToken forKey:@"oauth_token"];
	if (_oauthVerifier) [parameters setObject:_oauthVerifier forKey:@"oauth_verifier"];
	return [parameters copy];
}

- (void)_signURLRequest:(NSMutableURLRequest *)request oauthRequest:(DCTAuthRequest *)oauthRequest {
	
	NSMutableDictionary *OAuthParameters = [NSMutableDictionary new];
	[OAuthParameters addEntriesFromDictionary:[self _OAuthParameters]];
	[OAuthParameters addEntriesFromDictionary:oauthRequest.parameters];
	
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:request.URL
																 HTTPMethod:request.HTTPMethod
															 consumerSecret:_consumerSecret
																secretToken:_oauthTokenSecret
																 parameters:OAuthParameters];

	[request addValue:[signature authorizationHeader] forHTTPHeaderField:@"Authorization"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; consumerKey = %@; oauth_token = %@>",
			NSStringFromClass([self class]),
			self,
			_consumerKey,
			_oauthToken];
}

@end
