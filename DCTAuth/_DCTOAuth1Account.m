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

NSString *const _DCTOAuth1AccountRequestTokenResponseKey = @"RequestTokenResponse";
NSString *const _DCTOAuth1AccountAuthorizeResponseKey = @"AuthorizeResponse";
NSString *const _DCTOAuth1AccountAccessTokenResponseKey = @"AccessTokenResponse";

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
	
	_consumerKey = [self _secureValueForKey:@"_consumerKey"];
	_consumerSecret = [self _secureValueForKey:@"_consumerSecret"];
	
	_oauthToken = [self _secureValueForKey:@"_oauthToken"];
	_oauthTokenSecret = [self _secureValueForKey:@"_oauthTokenSecret"];
	_oauthVerifier = [self _secureValueForKey:@"_oauthVerifier"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_requestTokenURL forKey:@"_requestTokenURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	
	[self _setSecureValue:_consumerKey forKey:@"_consumerKey"];
	[self _setSecureValue:_consumerSecret forKey:@"_consumerSecret"];
	
	[self _setSecureValue:_oauthToken forKey:@"_oauthToken"];
	[self _setSecureValue:_oauthTokenSecret forKey:@"_oauthTokenSecret"];
	[self _setSecureValue:_oauthVerifier forKey:@"_oauthVerifier"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {

	[self _nilCurrentOAuthValues];
	NSMutableDictionary *responses = [NSMutableDictionary new];

	void (^completion)() = ^ {
		if (handler != NULL) handler([responses copy], nil);
	};
	
	void (^fetchAccessToken)() = ^{
		[self _fetchAccessTokenWithCompletion:^(NSDictionary *response) {
			[responses setObject:response forKey:_DCTOAuth1AccountAccessTokenResponseKey];
			completion();
		}];
	};
	
	void (^authorizeUser)() = ^ {
		[self _authorizeWithCompletion:^(NSDictionary *response) {
			[responses setObject:response forKey:_DCTOAuth1AccountAuthorizeResponseKey];
			fetchAccessToken();
		}];
	};
	
	[self _fetchRequestTokenWithCompletion:^(NSDictionary *response) {

		[responses setObject:response forKey:_DCTOAuth1AccountRequestTokenResponseKey];

		// If there's no authorizeURL, assume there is no authorize step.
		// This is valid as shown by the server used in the demo app.
		if (_authorizeURL)
			authorizeUser();
		else
			fetchAccessToken();
	}];
}



- (void)_fetchRequestTokenWithCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithURL:_requestTokenURL
                                                      requestMethod:DCTAuthRequestMethodGET
                                                         parameters:nil];
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [string dctAuth_parameterDictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
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
		[self _setValuesFromOAuthDictionary:dictionary];
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
		[self _setValuesFromOAuthDictionary:dictionary];
		completion(dictionary);
	}];
}

- (void)_setResponse:(NSDictionary *)response forKey:(NSString *)key {
	[self _setValuesFromOAuthDictionary:response];

}

- (void)_nilCurrentOAuthValues {
	_oauthToken = nil;
	_oauthTokenSecret = nil;
	_oauthVerifier = nil;
	[self _setAuthorized:NO];
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {

	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"oauth_token"])
			_oauthToken = value;

		else if ([key isEqualToString:@"oauth_verifier"])
			_oauthVerifier = value;
		
		else if ([key isEqualToString:@"oauth_token_secret"]) {
			_oauthTokenSecret = value;
			[self _setAuthorized:YES];
		}

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

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {
	
	NSMutableDictionary *OAuthParameters = [NSMutableDictionary new];
	[OAuthParameters addEntriesFromDictionary:[self _OAuthParameters]];
	[OAuthParameters addEntriesFromDictionary:authRequest.parameters];
	
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
