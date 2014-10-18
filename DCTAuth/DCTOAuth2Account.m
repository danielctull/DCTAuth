//
//  DCTAuth2Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuth2Account.h"
#import "DCTAuthAccountSubclass.h"
#import "DCTOAuth2Credential.h"
#import "DCTAuthAccount+Private.h"
#import "DCTAuth.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"

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
		  username:(NSString *)username
		  password:(NSString *)password
			scopes:(NSArray *)scopes {
	self = [self initWithType:type];
	if (!self) return nil;
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

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {

	if (!handler) handler = ^(NSArray *responses, NSError *error){};

	NSMutableArray *responses = [NSMutableArray new];

	DCTOAuth2Credential *credential = self.credential;
	NSString *clientID = (self.clientID != nil) ? self.clientID : credential.clientID;
	NSString *clientSecret = (self.clientSecret != nil) ? self.clientSecret : credential.clientSecret;
	NSString *password = (self.password != nil) ? self.password : credential.password;
	NSString *username = self.username;
	NSString *state = [[NSProcessInfo processInfo] globallyUniqueString];

	void (^accessTokenHandler)(DCTAuthResponse *, NSError *) = ^(DCTAuthResponse *response, NSError *error) {

		[responses addObject:response];

		[self parseCredentialsFromResponse:response completion:^(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken) {

			if (!error)
				self.credential = [[DCTOAuth2Credential alloc] initWithClientID:clientID
																   clientSecret:clientSecret
																	   password:password
																	accessToken:accessToken
																   refreshToken:refreshToken];

			handler([responses copy], error);
		}];
	};
	
	void (^authorizeHandler)(DCTAuthResponse *) = ^(DCTAuthResponse *response) {

		[self parseCredentialsFromResponse:response completion:^(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken) {

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

	if (password.length > 0)
		[self passwordAuthorizeWithUsername:username
								   password:password
									handler:accessTokenHandler];
	else
		[self authorizeWithClientID:clientID
							  state:state
							handler:authorizeHandler];
}

- (void)reauthenticateWithHandler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	if (!handler) handler = ^(DCTAuthResponse *response, NSError *error) {};

	DCTOAuth2Credential *credential = self.credential;
	NSString *clientID = (self.clientID != nil) ? self.clientID : credential.clientID;
	NSString *clientSecret = (self.clientSecret != nil) ? self.clientSecret : credential.clientSecret;
	NSString *password = (self.password != nil) ? self.password : credential.password;
	NSString *refreshToken = credential.refreshToken;

	[self refreshAccessTokenWithRefreshToken:refreshToken clientID:clientID clientSecret:clientSecret handler:^(DCTAuthResponse *response, NSError *error) {

		[self parseCredentialsFromResponse:response completion:^(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken) {

			if (!error)
				self.credential = [[DCTOAuth2Credential alloc] initWithClientID:clientID
																   clientSecret:clientSecret
																	   password:password
																	accessToken:accessToken
																   refreshToken:refreshToken];

			handler(response, error);
		}];
	}];
}

- (void)passwordAuthorizeWithUsername:(NSString *)username
							 password:(NSString *)password
							  handler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	parameters[@"grant_type"] = @"password";
	parameters[@"username"] = username;
	parameters[@"password"] = password;

	NSDictionary *authorizeExtras = [self parametersForRequestType:DCTOAuth2RequestType.authorize];
	NSDictionary *accessTokenExtras = [self parametersForRequestType:DCTOAuth2RequestType.accessToken];
	[parameters addEntriesFromDictionary:authorizeExtras];
	[parameters addEntriesFromDictionary:accessTokenExtras];

	if (self.scopes.count > 0) [parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:self.authorizeURL
																 parameters:parameters];

	[request performRequestWithHandler:handler];
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
	if (self.shouldSendCallbackURL && self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];
	if (self.scopes.count > 0) [parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];
	[parameters setObject:state forKey:@"state"];

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

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters setObject:@"authorization_code" forKey:@"grant_type"];
	if (code) [parameters setObject:code forKey:@"code"];
	[parameters setObject:clientID forKey:@"client_id"];
	[parameters setObject:@"web_server" forKey:@"type"];
	if (clientSecret) [parameters setObject:clientSecret forKey:@"client_secret"];
	if (self.shouldSendCallbackURL && self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.accessToken];
	[parameters addEntriesFromDictionary:extras];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:self.accessTokenURL
																 parameters:parameters];
	[request performRequestWithHandler:handler];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret
								   handler:(void (^)(DCTAuthResponse *response, NSError *error))handler {

	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters setObject:@"refresh_token" forKey:@"grant_type"];
	[parameters setObject:refreshToken forKey:@"refresh_token"];
	[parameters setObject:clientID forKey:@"client_id"];
	[parameters setObject:@"web_server" forKey:@"type"];
	if (clientSecret) [parameters setObject:clientSecret forKey:@"client_secret"];

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.refresh];
	[parameters addEntriesFromDictionary:extras];

	if (self.scopes.count > 0) [parameters setObject:[self.scopes componentsJoinedByString:@","] forKey:@"scope"];

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

	NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
	NSDictionary *exitingParameters = [URLComponents.query dctAuth_parameterDictionary];
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:exitingParameters];
	
	DCTOAuth2Credential *credential = self.credential;
	parameters[@"access_token"] = credential.accessToken;

	NSDictionary *extras = [self parametersForRequestType:DCTOAuth2RequestType.signing];
	[parameters addEntriesFromDictionary:extras];

	URLComponents.query = [parameters dctAuth_queryString];
	request.URL = URLComponents.URL;
}

- (void)parseCredentialsFromResponse:(DCTAuthResponse *)response completion:(void (^)(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken))completion {

	NSDictionary *dictionary = response.contentObject;

	if (![dictionary isKindOfClass:[NSDictionary class]]) {
		NSError *error = [NSError errorWithDomain:@"DCTAuth" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Response not dictionary."}];
		completion(error, nil, nil, nil);
		return;
	}

	NSError *error = [self errorWithStatusCode:response.statusCode dictionary:dictionary];
	if (error) {
		completion(error, nil, nil, nil);
		return;
	}

	NSString *code = dictionary[@"code"];
	NSString *accessToken = dictionary[@"access_token"];
	NSString *refreshToken = dictionary[@"refresh_token"];
	completion(nil, code, accessToken, refreshToken);
}

- (NSError *)errorWithStatusCode:(NSInteger)statusCode dictionary:(NSDictionary *)dictionary {
	
	
	NSString *OAuthError = [dictionary objectForKey:@"error"];
	
	if (![OAuthError isKindOfClass:[NSString class]]) return nil;
	
	NSString *description = [DCTAuth localizedStringForDomain:@"OAuth2" key:OAuthError];
	if (description.length == 0) description = @"An unknown error occured while attempting to authorize.";
	
	return [NSError errorWithDomain:@"DCTAuth"
							   code:statusCode
						   userInfo:@{NSLocalizedDescriptionKey : description}];
}

@end
