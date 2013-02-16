//
//  _DCTAuth2Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth2Account.h"
#import "DCTAuth.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"
#import "NSURL+DCTAuth.h"

NSString *const _DCTOAuth2AccountAuthorizeResponseKey = @"AuthorizeResponse";
NSString *const _DCTOAuth2AccountAccessTokenResponseKey = @"AccessTokenResponse";

@interface _DCTOAuth2Account ()
@property (nonatomic, copy) NSURL *authorizeURL;
@property (nonatomic, copy) NSURL *accessTokenURL;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSArray *scopes;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, strong) id openURLObject;
@end

@implementation _DCTOAuth2Account

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
	_scopes = [coder decodeObjectForKey:@"_scopes"];
	return self;
}

- (void)decodeWithSecureStorage:(DCTAuthSecureStorage *)secureStorage {
	[super decodeWithSecureStorage:secureStorage];
	self.clientID = [secureStorage objectForKey:@"_clientID"];
	self.clientSecret = [secureStorage objectForKey:@"_clientSecret"];
	self.state = [secureStorage objectForKey:@"_state"];
	self.code = [secureStorage objectForKey:@"_code"];
	self.accessToken = [secureStorage objectForKey:@"_accessToken"];
	self.refreshToken = [secureStorage objectForKey:@"_refreshToken"];
}


- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authorizeURL forKey:@"_authorizeURL"];
	[coder encodeObject:self.accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:self.scopes forKey:@"_scopes"];
}

- (void)encodeWithSecureStorage:(DCTAuthSecureStorage *)secureStorage {
	[super encodeWithSecureStorage:secureStorage];
	[secureStorage setObject:self.clientID forKey:@"_clientID"];
	[secureStorage setObject:self.clientSecret forKey:@"_clientSecret"];
	[secureStorage setObject:self.state forKey:@"_state"];
	[secureStorage setObject:self.code forKey:@"_code"];
	[secureStorage setObject:self.accessToken forKey:@"_accessToken"];
	[secureStorage setObject:self.refreshToken forKey:@"_refreshToken"];
	
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {
	
	[self _nilCurrentOAuthValues];
	NSMutableDictionary *responses = [NSMutableDictionary new];
	
	void (^completion)(NSError *) = ^(NSError *error) {
		if (handler != NULL) handler([responses copy], error);
	};
	
	void (^accessTokenHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		if (response) [responses setObject:response forKey:_DCTOAuth2AccountAccessTokenResponseKey];
		completion(error);
	};
	
	void (^authorizeHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		if (response) [responses setObject:response forKey:_DCTOAuth2AccountAuthorizeResponseKey];
		
		// If there's no access token URL, skip it.
		// This is the "Implicit Authentication Flow"
		if (error || !self.accessTokenURL) {
			completion(error);
			return;
		}
	
		[self _fetchAccessTokenWithHandler:accessTokenHandler];
	};
	
	[self _authorizeWithHandler:authorizeHandler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)_authorizeWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authorizeURL
																 parameters:[self _OAuthParametersWithState:YES]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	self.openURLObject = [DCTAuth openURL:authorizeURL withCallbackURL:self.callbackURL handler:^(DCTAuthResponse *response) {
		[self _setValuesFromOAuthDictionary:response.contentObject];
		NSError *error = [self _errorFromOAuthDictionary:response.contentObject];
		handler(response.contentObject, error);
	}];
}

- (void)_fetchAccessTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	[self _fetchAccessTokenWithState:YES Handler:handler];
}

- (void)_fetchAccessTokenWithState:(BOOL)sendState Handler:(void(^)(NSDictionary *response, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:self.accessTokenURL
																 parameters:[self _OAuthParametersWithState:sendState]];

	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

		[self _setValuesFromOAuthDictionary:response.contentObject];

		if (!self.authorized && sendState) {
			// Try again but don't include the state - Google fails on sending the state
			[self _fetchAccessTokenWithState:NO Handler:handler];
			return;
		}

		NSError *oAuthError = [self _errorFromOAuthDictionary:response.contentObject];
		handler(response.contentObject, oAuthError);
	}];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {
	NSURL *URL = [request URL];
	URL = [URL dctAuth_URLByAddingQueryParameters:[self _OAuthParametersWithState:NO]];
	request.URL = URL;
}

- (NSError *)_errorFromOAuthDictionary:(NSDictionary *)dictionary {
	
	if ([dictionary count] == 0) {
		return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{}];
	}
	
	return nil;
}

- (NSDictionary *)_OAuthParametersWithState:(BOOL)includeState {
	NSMutableDictionary *parameters = [NSMutableDictionary new];

	if (self.accessToken) {
		[parameters setObject:self.accessToken forKey:@"access_token"];
		[parameters setObject:self.accessToken forKey:@"oauth_token"];
		return [parameters copy];
	}

	if (includeState) [parameters setObject:self.state forKey:@"state"];
	[parameters setObject:self.clientID forKey:@"client_id"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];

	if (self.code) {
		if (self.clientSecret.length > 0) [parameters setObject:self.clientSecret forKey:@"client_secret"];
		[parameters setObject:self.code forKey:@"code"];
		[parameters setObject:@"authorization_code" forKey:@"grant_type"];
	} else {

		if (self.scopes.count > 0) [parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];

		if (self.accessTokenURL)
			[parameters setObject:@"code" forKey:@"response_type"];
		else
			[parameters setObject:@"token" forKey:@"response_type"];
	}

	return [parameters copy];
}

- (void)_nilCurrentOAuthValues {
	self.code = nil;
	self.accessToken = nil;
	self.refreshToken = nil;
	self.authorized = NO;
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"code"])
			self.code = value;
		
		else if ([key isEqualToString:@"refresh_token"])
			self.refreshToken = value;

		else if ([key isEqualToString:@"access_token"]) {
			self.accessToken = value;
			self.authorized = YES;
		}
	}];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; type = %@; clientID = %@; has code = %@; has access token = %@>",
			NSStringFromClass([self class]),
			self,
			self.type,
			self.clientID,
			self.code ? @"YES" : @"NO",
			self.accessToken ? @"YES" : @"NO"];
}

@end
