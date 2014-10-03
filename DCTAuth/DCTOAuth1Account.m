//
//  DCTOAuth1Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuth1Account.h"
#import "DCTOAuth1Credential.h"
#import "DCTOAuthSignature.h"
#import "DCTAuth.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"

static NSString *const DCTOAuth1AccountOAuthCallback = @"oauth_callback";
static NSString *const DCTOAuth1AccountOAuthConsumerKey = @"oauth_consumer_key";
static NSString *const DCTOAuth1AccountOAuthConsumerSecret = @"oauth_consumer_secret";
static NSString *const DCTOAuth1AccountOAuthToken = @"oauth_token";
static NSString *const DCTOAuth1AccountOAuthTokenSecret = @"oauth_token_secret";
static NSString *const DCTOAuth1AccountOAuthVerifier = @"oauth_verifier";

static const struct DCTOAuth1AccountProperties {
	__unsafe_unretained NSString *consumerKey;
	__unsafe_unretained NSString *consumerSecret;
	__unsafe_unretained NSString *requestTokenURL;
	__unsafe_unretained NSString *accessTokenURL;
	__unsafe_unretained NSString *authorizeURL;
	__unsafe_unretained NSString *signatureType;
	__unsafe_unretained NSString *openURLObject;
} DCTOAuth1AccountProperties;

static const struct DCTOAuth1AccountProperties DCTOAuth1AccountProperties = {
	.consumerKey = @"consumerKey",
	.consumerSecret = @"consumerSecret",
	.requestTokenURL = @"requestTokenURL",
	.accessTokenURL = @"accessTokenURL",
	.authorizeURL = @"authorizeURL",
	.signatureType = @"signatureType",
	.openURLObject = @"openURLObject"
};

@interface DCTOAuth1Account ()
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSURL *requestTokenURL;
@property (nonatomic, copy) NSURL *accessTokenURL;
@property (nonatomic, copy) NSURL *authorizeURL;
@property (nonatomic, assign) DCTOAuthSignatureType signatureType;
@property (nonatomic, strong) id openURLObject;
@end

@implementation DCTOAuth1Account

- (instancetype)initWithType:(NSString *)type
   requestTokenURL:(NSURL *)requestTokenURL
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
	   consumerKey:(NSString *)consumerKey
	consumerSecret:(NSString *)consumerSecret
	 signatureType:(DCTOAuthSignatureType)signatureType {
	
	self = [self initWithType:type];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	_signatureType = signatureType;
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	_requestTokenURL = [coder decodeObjectForKey:DCTOAuth1AccountProperties.requestTokenURL];
	_accessTokenURL = [coder decodeObjectForKey:DCTOAuth1AccountProperties.accessTokenURL];
	_authorizeURL = [coder decodeObjectForKey:DCTOAuth1AccountProperties.authorizeURL];
	_signatureType = [[coder decodeObjectForKey:DCTOAuth1AccountProperties.signatureType] integerValue];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.requestTokenURL forKey:DCTOAuth1AccountProperties.requestTokenURL];
	[coder encodeObject:self.accessTokenURL forKey:DCTOAuth1AccountProperties.accessTokenURL];
	[coder encodeObject:self.authorizeURL forKey:DCTOAuth1AccountProperties.authorizeURL];
	[coder encodeObject:@(self.signatureType) forKey:DCTOAuth1AccountProperties.signatureType];
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {

	NSMutableArray *responses = [NSMutableArray new];

	DCTOAuth1Credential *credential = self.credential;
	NSString *consumerKey = (self.consumerKey != nil) ? self.consumerKey : credential.consumerKey;
	NSString *consumerSecret = (self.consumerSecret != nil) ? self.consumerSecret : credential.consumerSecret;
	__block NSString *oauthToken;
	__block NSString *oauthTokenSecret;
	__block NSString *oauthVerifier;

	NSDictionary *(^OAuthParameters)() = ^{
		NSMutableDictionary *OAuthParameters = [NSMutableDictionary new];
		if (oauthToken.length > 0) [OAuthParameters setObject:oauthToken forKey:DCTOAuth1AccountOAuthToken];
		if (consumerKey.length > 0) [OAuthParameters setObject:consumerKey forKey:DCTOAuth1AccountOAuthConsumerKey];
		if (oauthVerifier.length > 0) [OAuthParameters setObject:oauthVerifier forKey:DCTOAuth1AccountOAuthVerifier];
		if (self.shouldSendCallbackURL && self.callbackURL) [OAuthParameters setObject:[self.callbackURL absoluteString] forKey:DCTOAuth1AccountOAuthCallback];
		return [OAuthParameters copy];
	};

	NSString *(^signature)(DCTAuthRequest *) = ^(DCTAuthRequest *request) {

		NSMutableDictionary *parameters = [OAuthParameters() mutableCopy];
		[parameters addEntriesFromDictionary:request.parameters];
		NSString *HTTPMethod = [DCTAuthRequest stringForRequestMethod:request.requestMethod];

		DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:request.URL
																   HTTPMethod:HTTPMethod
															   consumerSecret:consumerSecret
																  secretToken:oauthTokenSecret
																   parameters:parameters
																		 type:self.signatureType];
		return [signature authorizationHeader];
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

						if ([key isEqualToString:DCTOAuth1AccountOAuthToken])
							oauthToken = value;

						else if	([key isEqualToString:DCTOAuth1AccountOAuthVerifier])
							oauthVerifier = value;

						else if ([key isEqualToString:DCTOAuth1AccountOAuthTokenSecret])
							oauthTokenSecret = value;
					}];
				}
			}
		}

		if (failure && handler != NULL) handler([responses copy], returnError);
		return failure;
	};

	void (^accessTokenHandler)(DCTAuthResponse *, NSError *) = ^(DCTAuthResponse *response, NSError *error) {
		if (shouldComplete(response, error)) return;
		self.credential = [[DCTOAuth1Credential alloc] initWithConsumerKey:consumerKey
																   consumerSecret:consumerSecret
																	   oauthToken:oauthToken
																 oauthTokenSecret:oauthTokenSecret];
		if (handler != NULL) handler([responses copy], nil);
	};

	void (^fetchAccessToken)() = ^{
		DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																			URL:self.accessTokenURL
																	 parameters:nil];
		request.HTTPHeaders = @{ @"Authorization" : signature(request) };
		[request performRequestWithHandler:accessTokenHandler];
	};

	void (^authorizeHandler)(DCTAuthResponse *) = ^(DCTAuthResponse *response) {
		if (shouldComplete(response, nil)) return;
		fetchAccessToken();
	};

	void (^requestTokenHandler)(DCTAuthResponse *response, NSError *error) = ^(DCTAuthResponse *response, NSError *error) {

		if (shouldComplete(response, error)) return;
		
		// If there's no authorizeURL, assume there is no authorize step.
		// This is valid as shown by the server used in the demo app.
		if (!self.authorizeURL) {
			fetchAccessToken();
			return;
		}

		DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																			URL:self.authorizeURL
																	 parameters:OAuthParameters()];
		NSURL *authorizeURL = [[request signedURLRequest] URL];
		self.openURLObject = [DCTAuth openURL:authorizeURL withCallbackURL:self.callbackURL handler:authorizeHandler];
	};

	DCTAuthRequest *requestTokenRequest = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET URL:self.requestTokenURL parameters:nil];
	requestTokenRequest.HTTPHeaders = @{ @"Authorization" : signature(requestTokenRequest) };
	[requestTokenRequest performRequestWithHandler:requestTokenHandler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {

	DCTOAuth1Credential *credential = self.credential;
	if (!credential) return;

	NSMutableDictionary *OAuthParameters = [NSMutableDictionary new];
	[OAuthParameters setObject:credential.oauthToken forKey:DCTOAuth1AccountOAuthToken];
	[OAuthParameters setObject:credential.consumerKey forKey:DCTOAuth1AccountOAuthConsumerKey];
	[OAuthParameters addEntriesFromDictionary:authRequest.parameters];
	
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:request.URL
															   HTTPMethod:request.HTTPMethod
														   consumerSecret:credential.consumerSecret
															  secretToken:credential.oauthTokenSecret
															   parameters:OAuthParameters
																	 type:self.signatureType];
	[request addValue:[signature authorizationHeader] forHTTPHeaderField:@"Authorization"];
}

@end


@compatibility_alias _DCTOAuth1Account DCTOAuth1Account;
