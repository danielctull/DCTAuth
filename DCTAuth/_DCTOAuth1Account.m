//
//  _DCTOAuth1Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequest.h"
#import "_DCTOAuth1Account.h"
#import "_DCTAuthAccount.h"
#import "_DCTOAuthSignature.h"
#import "_DCTAuthURLOpener.h"
#import "NSString+DCTAuth.h"

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

	void (^completion)(NSError *) = ^(NSError *error) {
		if (handler != NULL) handler([responses copy], error);
	};

	void (^accessTokenHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		[responses setObject:response forKey:_DCTOAuth1AccountAccessTokenResponseKey];
		completion(error);
	};

	void (^authorizeHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		[responses setObject:response forKey:_DCTOAuth1AccountAuthorizeResponseKey];
		if (error) {
			completion(error);
			return;
		}
		[self _fetchAccessTokenWithHandler:accessTokenHandler];
	};

	void (^requestTokenHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		[responses setObject:response forKey:_DCTOAuth1AccountRequestTokenResponseKey];
		if (error) {
			completion(error);
			return;
		}
		
		// If there's no authorizeURL, assume there is no authorize step.
		// This is valid as shown by the server used in the demo app.
		if (_authorizeURL)
			[self _authorizeWithHandler:authorizeHandler];
		else
			[self _fetchAccessTokenWithHandler:accessTokenHandler];
	};

	[self _fetchRequestTokenWithHandler:requestTokenHandler];
}

- (void)_fetchRequestTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:_requestTokenURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:[self _requestHandlerFromHandler:handler]];
}

- (void)_authorizeWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:_authorizeURL
																 parameters:[self _OAuthParameters]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	[[_DCTAuthURLOpener sharedURLOpener] openURL:authorizeURL withCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		NSDictionary *dictionary = [[URL query] dctAuth_parameterDictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		handler(dictionary, nil);
	}];
}

- (void)_fetchAccessTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:_accessTokenURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:[self _requestHandlerFromHandler:handler]];
}




- (void(^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))_requestHandlerFromHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	return ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (!responseData) {
			handler(nil, error);
			return;
		}
		
		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
		if (!dictionary) {
			NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			dictionary = [string dctAuth_parameterDictionary];
		}
		[self _setValuesFromOAuthDictionary:dictionary];
		NSError *oAuthError = [self _errorFromOAuthDictionary:dictionary];
		handler(dictionary, oAuthError);
	};
}

- (void)_nilCurrentOAuthValues {
	_oauthToken = nil;
	_oauthTokenSecret = nil;
	_oauthVerifier = nil;
	[self _setAuthorized:NO];
}

- (NSError *)_errorFromOAuthDictionary:(NSDictionary *)dictionary {
	
	if ([dictionary count] == 0) {
		return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{}];
	}
	
	return nil;
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
