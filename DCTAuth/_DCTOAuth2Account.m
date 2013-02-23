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
															 accessToken:accessToken
															refreshToken:refreshToken];
		if (self.authorized) {
			if (handler != NULL) handler([responses copy], nil);
			return YES;
		}
		return NO;
	};
	
	void (^authorizeHandler)(DCTAuthResponse *) = ^(DCTAuthResponse *response) {

		if (shouldComplete(response, nil)) return;

		// If there's no access token URL, skip it.
		// This is the "Implicit Authentication Flow"
		if (!self.accessTokenURL) {
			isFinishedAccessTokenHandler(response, nil);
			return;
		}
	
		[self fetchAccessTokenWithClientID:clientID
							  clientSecret:clientSecret
									  code:code
								   handler:^(DCTAuthResponse *response, NSError *error) {
									   isFinishedAccessTokenHandler(response, error);
								   }];
	};

	[self authorizeWithClientID:clientID
						  state:state
						handler:authorizeHandler];
}

- (void)authorizeWithClientID:(NSString *)clientID
						state:(NSString *)state
					  handler:(void (^)(DCTAuthResponse *response))handler {

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	if (self.accessTokenURL)
		[parameters setObject:@"code" forKey:@"response_type"];
	else
		[parameters setObject:@"token" forKey:@"response_type"];

	[parameters setObject:clientID forKey:@"client_id"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];
	if (self.scopes.count > 0) [parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];
	[parameters setObject:state forKey:@"state"];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authorizeURL
																 parameters:parameters];
	self.openURLObject = [DCTAuth openURL:[[request signedURLRequest] URL]
						  withCallbackURL:self.callbackURL
								  handler:handler];
}

- (void)fetchAccessTokenWithClientID:(NSString *)clientID
						clientSecret:(NSString *)clientSecret
								code:(NSString *)code
							 handler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters setObject:@"authorization_code" forKey:@"grant_type"];
	[parameters setObject:code forKey:@"code"];
	[parameters setObject:clientID forKey:@"client_id"];
	if (clientSecret) [parameters setObject:clientSecret forKey:@"client_secret"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:self.accessTokenURL
																 parameters:parameters];
	[request performRequestWithHandler:handler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {
	NSURL *URL = [request URL];
	_DCTOAuth2Credential *credential = self.credential;
	URL = [URL dctAuth_URLByAddingQueryParameters:@{ @"access_token" : credential.accessToken }];
	request.URL = URL;
}

@end
