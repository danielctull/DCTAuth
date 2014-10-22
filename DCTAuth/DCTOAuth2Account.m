//
//  DCTAuth2Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuth2Account.h"
#import "DCTOAuth2.h"
#import "DCTAuthAccountSubclass.h"
#import "DCTOAuth2Credential.h"
#import "DCTAuthAccount+Private.h"
#import "DCTAuth.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"
#import "DCTBasicAuthCredential.h"

static const struct DCTOAuth2AccountProperties {
	__unsafe_unretained NSString *authorizeURL;
	__unsafe_unretained NSString *accessTokenURL;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *scopes;
} DCTOAuth2AccountProperties;

static const struct DCTOAuth2AccountProperties DCTOAuth2AccountProperties = {
	.authorizeURL = @"authorizeURL",
	.accessTokenURL = @"accessTokenURL",
	.username = @"username",
	.scopes = @"scopes"
};

@interface DCTOAuth2Account () <DCTAuthAccountSubclass>
@property (nonatomic, copy) NSURL *authorizeURL;
@property (nonatomic, copy) NSURL *accessTokenURL;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSArray *scopes;
@property (nonatomic, strong) id openURLObject;
@end

@implementation DCTOAuth2Account

- (instancetype)initWithType:(NSString *)type
				authorizeURL:(NSURL *)authorizeURL
			  accessTokenURL:(NSURL *)accessTokenURL
					clientID:(NSString *)clientID
				clientSecret:(NSString *)clientSecret
					  scopes:(NSArray *)scopes {
	self = [self initWithType:type];
	if (!self) return nil;
	_authorizeURL = [authorizeURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_clientID = [clientID copy];
	_clientSecret = [clientSecret copy];
	_scopes = [scopes copy];
	return self;
}

- (instancetype)initWithType:(NSString *)type
				authorizeURL:(NSURL *)authorizeURL
					clientID:(NSString *)clientID
				clientSecret:(NSString *)clientSecret
					username:(NSString *)username
					password:(NSString *)password
					  scopes:(NSArray *)scopes {
	self = [self initWithType:type];
	if (!self) return nil;
	_clientID = [clientID copy];
	_clientSecret = [clientSecret copy];
	_authorizeURL = [authorizeURL copy];
	_username = [username copy];
	_password = [password copy];
	_scopes = [scopes copy];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	_authorizeURL = [coder decodeObjectForKey:DCTOAuth2AccountProperties.authorizeURL];
	_accessTokenURL = [coder decodeObjectForKey:DCTOAuth2AccountProperties.accessTokenURL];
	_username = [coder decodeObjectForKey:DCTOAuth2AccountProperties.username];
	_scopes = [coder decodeObjectForKey:DCTOAuth2AccountProperties.scopes];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authorizeURL forKey:DCTOAuth2AccountProperties.authorizeURL];
	[coder encodeObject:self.accessTokenURL forKey:DCTOAuth2AccountProperties.accessTokenURL];
	[coder encodeObject:self.username forKey:DCTOAuth2AccountProperties.username];
	[coder encodeObject:self.scopes forKey:DCTOAuth2AccountProperties.scopes];
}

- (NSString *)scopeString {

	if (self.scopes.count > 0) {
		return [self.scopes componentsJoinedByString:@","];
	}

	return nil;
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {

	if (!handler) handler = ^(NSArray *responses, NSError *error){};

	NSMutableArray *responses = [NSMutableArray new];

	DCTOAuth2Credential *credential = self.credential;
	NSString *clientID = self.clientID ?: credential.clientID;
	NSString *clientSecret = self.clientSecret ?: credential.clientSecret;
	NSString *password = self.password ?: credential.password;
	NSString *username = self.username;
	NSString *state = [[NSProcessInfo processInfo] globallyUniqueString];

	void (^accessTokenHandler)(DCTAuthResponse *, NSError *) = ^(DCTAuthResponse *response, NSError *error) {

		[responses addObject:response];

		[DCTOAuth2 parseCredentialsFromResponse:response completion:^(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken, DCTOAuth2CredentialType type) {

			if (!error)
				self.credential = [[DCTOAuth2Credential alloc] initWithClientID:clientID
																   clientSecret:clientSecret
																	   password:password
																	accessToken:accessToken
																   refreshToken:refreshToken
																		   type:type];

			handler([responses copy], error);
		}];
	};
	
	void (^authorizeHandler)(DCTAuthResponse *) = ^(DCTAuthResponse *response) {

		[DCTOAuth2 parseCredentialsFromResponse:response completion:^(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken, DCTOAuth2CredentialType type) {

			// If there's no access token URL, skip it.
			// This is the "Implicit Authentication Flow"
			if (!self.accessTokenURL) {
				accessTokenHandler(response, nil);
				return;
			}

			[responses addObject:response];

			if (error) {
				handler([responses copy], error);
				return;
			}

			[self fetchAccessTokenWithClientID:clientID
								  clientSecret:clientSecret
										  code:code
									   handler:accessTokenHandler];
		}];
	};

	if (password.length > 0) {
		[self passwordAuthorizeWithClientID:clientID
							   clientSecret:clientSecret
								   username:username
								   password:password
									handler:accessTokenHandler];
	} else {
		[self authorizeWithClientID:clientID
							  state:state
							handler:authorizeHandler];
	}
}

- (void)reauthenticateWithHandler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	if (!handler) handler = ^(DCTAuthResponse *response, NSError *error) {};

	DCTOAuth2Credential *credential = self.credential;
	NSString *clientID = self.clientID ?: credential.clientID;
	NSString *clientSecret = self.clientSecret ?: credential.clientSecret;
	NSString *password = self.password ?: credential.password;
	NSString *refreshToken = credential.refreshToken;

	[self refreshAccessTokenWithRefreshToken:refreshToken clientID:clientID clientSecret:clientSecret handler:^(DCTAuthResponse *response, NSError *error) {

		[DCTOAuth2 parseCredentialsFromResponse:response completion:^(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken, DCTOAuth2CredentialType type) {

			if (!error)
				self.credential = [[DCTOAuth2Credential alloc] initWithClientID:clientID
																   clientSecret:clientSecret
																	   password:password
																	accessToken:accessToken
																   refreshToken:refreshToken
																		   type:type];

			handler(response, error);
		}];
	}];
}

- (void)passwordAuthorizeWithClientID:(NSString *)clientID
						 clientSecret:(NSString *)clientSecret
							 username:(NSString *)username
							 password:(NSString *)password
							  handler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	NSString *scope = self.scopeString;

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	parameters[DCTOAuth2Keys.grantType] = DCTOAuth2Keys.password;
	if (username) parameters[DCTOAuth2Keys.username] = username;
	if (password) parameters[DCTOAuth2Keys.password] = password;
	if (clientID) parameters[DCTOAuth2Keys.clientID] = clientID;
	if (clientSecret) parameters[DCTOAuth2Keys.clientSecret] = clientSecret;
	if (scope) parameters[DCTOAuth2Keys.scope] = scope;

	NSDictionary *authorizeExtras = [self parametersForRequestType:DCTOAuth2RequestType.authorize];
	NSDictionary *accessTokenExtras = [self parametersForRequestType:DCTOAuth2RequestType.accessToken];
	[parameters addEntriesFromDictionary:authorizeExtras];
	[parameters addEntriesFromDictionary:accessTokenExtras];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:self.authorizeURL
																 parameters:parameters];

	[request performRequestWithHandler:handler];
}

- (void)authorizeWithClientID:(NSString *)clientID
						state:(NSString *)state
					  handler:(void (^)(DCTAuthResponse *response))handler {

	NSString *responseType = self.accessTokenURL ? DCTOAuth2Keys.code : DCTOAuth2Keys.token;
	NSString *scope = self.scopeString;
	NSString *callback = self.callbackURL.absoluteString;

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	parameters[DCTOAuth2Keys.responseType] = responseType;
	if (clientID) parameters[DCTOAuth2Keys.clientID] = clientID;
	if (scope) parameters[DCTOAuth2Keys.scope] = scope;
	if (state) parameters[DCTOAuth2Keys.state] = state;
	if (self.shouldSendCallbackURL && callback) parameters[DCTOAuth2Keys.redirectURI] = callback;

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.authorize];
	[parameters addEntriesFromDictionary:extras];

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

	NSString *callback = self.callbackURL.absoluteString;

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	parameters[DCTOAuth2Keys.grantType] = DCTOAuth2Keys.authorizationCode;
	if (code) parameters[DCTOAuth2Keys.code] = code;
	if (clientID) parameters[DCTOAuth2Keys.clientID] = clientID;
	if (clientSecret) parameters[DCTOAuth2Keys.clientSecret] = clientSecret;
	if (self.shouldSendCallbackURL && callback) parameters[DCTOAuth2Keys.redirectURI] = callback;

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.accessToken];
	[parameters addEntriesFromDictionary:extras];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:self.accessTokenURL
																 parameters:parameters];

	DCTBasicAuthCredential *basicCredential = [[DCTBasicAuthCredential alloc] initWithUsername:clientID password:clientSecret];
	NSString *authorizationHeader = basicCredential.authorizationHeader;
	if (authorizationHeader) {
		request.HTTPHeaders = @{ @"Authorization" : authorizationHeader };
	}

	[request performRequestWithHandler:handler];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret
								   handler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	NSString *scope = self.scopeString;

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	parameters[DCTOAuth2Keys.grantType] = DCTOAuth2Keys.refreshToken;
	if (refreshToken) parameters[DCTOAuth2Keys.refreshToken] = refreshToken;
	if (clientID) parameters[DCTOAuth2Keys.clientID] = clientID;
	if (clientSecret) parameters[DCTOAuth2Keys.clientSecret] = clientSecret;
	if (scope) parameters[DCTOAuth2Keys.scope] = scope;

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.refresh];
	[parameters addEntriesFromDictionary:extras];

	NSURL *refreshURL = self.accessTokenURL ?: self.authorizeURL;
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:refreshURL
																 parameters:parameters];

	DCTBasicAuthCredential *basicCredential = [[DCTBasicAuthCredential alloc] initWithUsername:clientID password:clientSecret];
	NSString *authorizationHeader = basicCredential.authorizationHeader;
	if (authorizationHeader) {
		request.HTTPHeaders = @{ @"Authorization" : authorizationHeader };
	}

	[request performRequestWithHandler:handler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {

	NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
	NSDictionary *exitingParameters = [URLComponents.query dctAuth_parameterDictionary];
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:exitingParameters];

	// Instagram requires the access_token in the parameters list, and doesn't return a token_type
	// Foursquare requires this parameter to be called oauth_token and doesn't return a token_type
	// Soundcloud requires this parameter to be called oauth_token and doesn't return a token_type
	// LinkedIn requires the Bearer header, and doesn't return an token_type in the return :(
	//
	// Because of these differences if the server returns "bearer" for "token_type" only the bearer
	// is set otherwise, every variation is set to give the best chance of working.
	//
	DCTOAuth2Credential *credential = self.credential;
	NSString *authorizationHeader = credential.authorizationHeader;
	if (authorizationHeader) {
		[request addValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
	}

	if (credential.type == DCTOAuth2CredentialTypeParamter) {
		parameters[DCTOAuth2Keys.accessToken] = credential.accessToken;
		parameters[DCTOAuth2Keys.oauthToken] = credential.accessToken;
	}

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.signing];
	[parameters addEntriesFromDictionary:extras];

	URLComponents.query = [parameters dctAuth_queryString];
	request.URL = URLComponents.URL;
}

@end
