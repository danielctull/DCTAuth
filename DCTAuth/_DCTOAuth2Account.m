//
//  _DCTAuth2Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth2Account.h"
#import "_DCTAuthURLOpener.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"
#import "NSURL+DCTAuth.h"

NSString *const _DCTOAuth2AccountAuthorizeResponseKey = @"AuthorizeResponse";
NSString *const _DCTOAuth2AccountAccessTokenResponseKey = @"AccessTokenResponse";

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

	id _openURLObject;
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
	
	_clientID = [self secureValueForKey:@"_clientID"];
	_clientSecret = [self secureValueForKey:@"_clientSecret"];
	
	_scopes = [coder decodeObjectForKey:@"_scopes"];
	
	_code = [self secureValueForKey:@"_code"];
	_accessToken = [self secureValueForKey:@"_accessToken"];
	_refreshToken = [self secureValueForKey:@"_refreshToken"];
	
	_state = [self secureValueForKey:@"_state"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	
	[self setSecureValue:_clientID forKey:@"_clientID"];
	[self setSecureValue:_clientSecret forKey:@"_clientSecret"];
	
	[coder encodeObject:_scopes forKey:@"_scopes"];
	
	[self setSecureValue:_code forKey:@"_code"];
	[self setSecureValue:_accessToken forKey:@"_accessToken"];
	[self setSecureValue:_refreshToken forKey:@"_refreshToken"];
	
	[self setSecureValue:_state forKey:@"_state"];
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
		if (error || !self->_accessTokenURL) {
			completion(error);
			return;
		}
	
		[self _fetchAccessTokenWithHandler:accessTokenHandler];
	};
	
	[self _authorizeWithHandler:authorizeHandler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[[_DCTAuthURLOpener sharedURLOpener] close:_openURLObject];
}

- (void)_authorizeWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:_authorizeURL
																 parameters:[self _OAuthParametersWithState:YES]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	_openURLObject = [[_DCTAuthURLOpener sharedURLOpener] openURL:authorizeURL withCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		NSMutableDictionary *dictionary = [NSMutableDictionary new];
		NSDictionary *queryDictionary = [[URL query] dctAuth_parameterDictionary];
		[dictionary addEntriesFromDictionary:queryDictionary];
		NSDictionary *fragmentDictionary = [[URL fragment] dctAuth_parameterDictionary];
		[dictionary addEntriesFromDictionary:fragmentDictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		NSError *error = [self _errorFromOAuthDictionary:dictionary];
		handler([dictionary copy], error);
	}];
}

- (void)_fetchAccessTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	[self _fetchAccessTokenWithState:YES Handler:handler];
}

- (void)_fetchAccessTokenWithState:(BOOL)sendState Handler:(void(^)(NSDictionary *response, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:_accessTokenURL
																 parameters:[self _OAuthParametersWithState:sendState]];

	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (!responseData) {
			handler(nil, error);
			return;
		}
		
		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL];
		if (!dictionary) {
			NSString *string= [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			dictionary = [string dctAuth_parameterDictionary];
		}
		[self _setValuesFromOAuthDictionary:dictionary];

		if (!self.authorized && sendState) {
			// Try again but don't include the state - Google fails on sending the state
			[self _fetchAccessTokenWithState:NO Handler:handler];
			return;
		}

		NSError *oAuthError = [self _errorFromOAuthDictionary:dictionary];
		handler(dictionary, oAuthError);
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

	if (_accessToken) {
		[parameters setObject:_accessToken forKey:@"access_token"];
		[parameters setObject:_accessToken forKey:@"oauth_token"];
		return [parameters copy];
	}

	if (includeState) [parameters setObject:_state forKey:@"state"];
	[parameters setObject:_clientID forKey:@"client_id"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];

	if (_code) {
		if (_clientSecret.length > 0) [parameters setObject:_clientSecret forKey:@"client_secret"];
		[parameters setObject:_code forKey:@"code"];
		[parameters setObject:@"authorization_code" forKey:@"grant_type"];
	} else {

		if (_scopes.count > 0) [parameters setObject:[_scopes componentsJoinedByString:@","] forKey:@"scope"];

		if (_accessTokenURL)
			[parameters setObject:@"code" forKey:@"response_type"];
		else
			[parameters setObject:@"token" forKey:@"response_type"];
	}

	return [parameters copy];
}

- (void)_nilCurrentOAuthValues {
	_code = nil;
	_accessToken = nil;
	_refreshToken = nil;
	self.authorized = NO;
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"code"])
			self->_code = value;
		
		else if ([key isEqualToString:@"refresh_token"])
			self->_refreshToken = value;

		else if ([key isEqualToString:@"access_token"]) {
			self->_accessToken = value;
			self.authorized = YES;
		}
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
