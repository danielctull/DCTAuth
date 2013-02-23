//
//  _DCTAuth2Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth2Account.h"
#import "_DCTOAuth2Credential.h"
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

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authorizeURL forKey:@"_authorizeURL"];
	[coder encodeObject:self.accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:self.scopes forKey:@"_scopes"];
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {
	
	NSMutableArray *responses = [NSMutableArray new];

	_DCTOAuth2Credential *credential = self.credential;
	NSString *clientID = (self.clientID != nil) ? self.clientID : credential.clientID;
	NSString *clientSecret = (self.clientSecret != nil) ? self.clientSecret : credential.clientSecret;
	NSString *state = [[NSProcessInfo processInfo] globallyUniqueString];
	__block NSString *code;
	__block NSString *accessToken;
	__block NSString *refreshToken;

	NSDictionary *(^OAuthParameters)(BOOL) = ^(BOOL includeState){
		NSMutableDictionary *parameters = [NSMutableDictionary new];

		if (accessToken) {
			[parameters setObject:accessToken forKey:@"access_token"];
			[parameters setObject:accessToken forKey:@"oauth_token"];
			return [parameters copy];
		}

		if (includeState) [parameters setObject:state forKey:@"state"];
		[parameters setObject:clientID forKey:@"client_id"];
		if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];

		if (code) {
			if (clientSecret.length > 0) [parameters setObject:clientSecret forKey:@"client_secret"];
			[parameters setObject:code forKey:@"code"];
			[parameters setObject:@"authorization_code" forKey:@"grant_type"];
		} else {

			if (self.scopes.count > 0) [parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];

			if (self.accessTokenURL)
				[parameters setObject:@"code" forKey:@"response_type"];
			else
				[parameters setObject:@"token" forKey:@"response_type"];
		}
		
		return [parameters copy];
	};

	BOOL (^shouldComplete)(DCTAuthResponse *, NSError *) = ^(DCTAuthResponse *response, NSError *error) {

		NSError *returnError;
		BOOL failure = NO;

		if (!response) {
			returnError = error;
			failure = YES;
		} else {

			[responses addObject:response];
			NSDictionary *dictionary = response.contentObject;

			if (![dictionary isKindOfClass:[NSDictionary class]]) {
				failure = YES;
				returnError = [NSError errorWithDomain:@"DCTAuth" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Response not dictionary."}];
			} else {

				id object = [dictionary objectForKey:@"error"];
				if (object) {
					failure = YES;
					returnError = [NSError errorWithDomain:@"OAuth" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey : [object description]}];
				} else {

					[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {

						if ([key isEqualToString:@"code"])
							code = value;

						else if ([key isEqualToString:@"refresh_token"])
							refreshToken = value;

						else if ([key isEqualToString:@"access_token"])
							accessToken = value;
					}];
				}
			}
		}

		if (failure && handler != NULL) handler([responses copy], returnError);
		return failure;
	};

	BOOL (^isFinishedAccessTokenHandler)(DCTAuthResponse *, NSError *) = ^(DCTAuthResponse *response, NSError *error) {
		if (shouldComplete(response, error)) return YES;
		self.credential = [[_DCTOAuth2Credential alloc] initWithClientID:clientID
															clientSecret:clientSecret
																	code:code
															 accessToken:accessToken
															refreshToken:refreshToken];

		if (self.authorized) {
			if (handler != NULL) handler([responses copy], nil);
			return YES;
		}
		return NO;
	};

	void (^fetchAccessToken)() = ^{
		DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																			URL:self.accessTokenURL
																	 parameters:OAuthParameters(YES)];
		[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

			if (isFinishedAccessTokenHandler(response, error)) return;

			// Try again but don't include the state - Google fails on sending the state
			DCTAuthRequest *request2 = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																				URL:self.accessTokenURL
																		 parameters:OAuthParameters(NO)];
			[request2 performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {
				isFinishedAccessTokenHandler(response, error);
			}];
		}];
	};
	
	void (^authorizeHandler)(DCTAuthResponse *) = ^(DCTAuthResponse *response) {
		if (shouldComplete(response, nil)) return;
		
		// If there's no access token URL, skip it.
		// This is the "Implicit Authentication Flow"
		if (self.accessTokenURL) {
			if (handler != NULL) handler([responses copy], nil);
			return;
		}
	
		fetchAccessToken();
	};
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authorizeURL
																 parameters:OAuthParameters(YES)];
	self.openURLObject = [DCTAuth openURL:[[request signedURLRequest] URL]
						  withCallbackURL:self.callbackURL
								  handler:authorizeHandler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {
	NSURL *URL = [request URL];
	URL = [URL dctAuth_URLByAddingQueryParameters:[self _OAuthParametersWithState:NO]];
	request.URL = URL;
}

- (NSDictionary *)_OAuthParametersWithState:(BOOL)includeState {
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	_DCTOAuth2Credential *credential = self.credential;
	
	if (credential.accessToken) {
		[parameters setObject:credential.accessToken forKey:@"access_token"];
		[parameters setObject:credential.accessToken forKey:@"oauth_token"];
		return [parameters copy];
	}

	[parameters setObject:self.clientID forKey:@"client_id"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];

	if (credential.code) {
		if (self.clientSecret.length > 0) [parameters setObject:self.clientSecret forKey:@"client_secret"];
		[parameters setObject:credential.code forKey:@"code"];
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

@end
