//
//  _DCTOAuth1Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuth1Account.h"
#import "_DCTOAuthSignature.h"
#import "DCTAuth.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"

NSString *const _DCTOAuth1AccountRequestTokenResponseKey = @"RequestTokenResponse";
NSString *const _DCTOAuth1AccountAuthorizeResponseKey = @"AuthorizeResponse";
NSString *const _DCTOAuth1AccountAccessTokenResponseKey = @"AccessTokenResponse";

@interface DCTOAuth1Account ()
@property (nonatomic, copy) NSURL *requestTokenURL;
@property (nonatomic, copy) NSURL *accessTokenURL;
@property (nonatomic, copy) NSURL *authorizeURL;
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSString *oauthToken;
@property (nonatomic, copy) NSString *oauthTokenSecret;
@property (nonatomic, copy) NSString *oauthVerifier;
@property (nonatomic, assign) DCTOAuthSignatureType signatureType;
@property (nonatomic, strong) id openURLObject;
@end

@implementation DCTOAuth1Account

- (id)initWithType:(NSString *)type
   requestTokenURL:(NSURL *)requestTokenURL
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
	   consumerKey:(NSString *)consumerKey
	consumerSecret:(NSString *)consumerSecret
	 signatureType:(DCTOAuthSignatureType)signatureType {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	_signatureType = signatureType;
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	_requestTokenURL = [coder decodeObjectForKey:@"_requestTokenURL"];
	_accessTokenURL = [coder decodeObjectForKey:@"_accessTokenURL"];
	_authorizeURL = [coder decodeObjectForKey:@"_authorizeURL"];
	_signatureType = [coder decodeIntegerForKey:@"_signatureType"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.requestTokenURL forKey:@"_requestTokenURL"];
	[coder encodeObject:self.accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:self.authorizeURL forKey:@"_authorizeURL"];
	[coder encodeInteger:self.signatureType forKey:@"_signatureType"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {

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
		if (response) [responses setObject:response forKey:_DCTOAuth1AccountRequestTokenResponseKey];
		if (error) {
			completion(error);
			return;
		}
		
		// If there's no authorizeURL, assume there is no authorize step.
		// This is valid as shown by the server used in the demo app.
		if (self.authorizeURL)
			[self _authorizeWithHandler:authorizeHandler];
		else
			[self _fetchAccessTokenWithHandler:accessTokenHandler];
	};

	[self _fetchRequestTokenWithHandler:requestTokenHandler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)_fetchRequestTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.requestTokenURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {
		[self _setValuesFromOAuthDictionary:response.contentObject];
		NSError *oAuthError = [self _errorFromOAuthDictionary:response.contentObject];
		handler(response.contentObject, oAuthError);
	}];
}

- (void)_authorizeWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authorizeURL
																 parameters:[self _OAuthParameters]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	self.openURLObject = [DCTAuth openURL:authorizeURL withCallbackURL:self.callbackURL handler:^(DCTAuthResponse *response) {
		[self _setValuesFromOAuthDictionary:response.contentObject];
		handler(response.contentObject, nil);
	}];
}

- (void)_fetchAccessTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.accessTokenURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {
		self.authorized = (response.statusCode == 200);
		[self _setValuesFromOAuthDictionary:response.contentObject];
		NSError *oAuthError = [self _errorFromOAuthDictionary:response.contentObject];
		handler(response.contentObject, oAuthError);
	}];
}

- (void)_nilCurrentOAuthValues {
	self.oauthToken = nil;
	self.oauthTokenSecret = nil;
	self.oauthVerifier = nil;
	self.authorized = NO;
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
			self.oauthToken = value;

		else if ([key isEqualToString:@"oauth_verifier"])
			self.oauthVerifier = value;
		
		else if ([key isEqualToString:@"oauth_token_secret"])
			self.oauthTokenSecret = value;

	}];
}

- (NSDictionary *)_OAuthParameters {
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters setObject:self.consumerKey forKey:@"oauth_consumer_key"];
	[parameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	if (self.oauthToken) [parameters setObject:self.oauthToken forKey:@"oauth_token"];
	if (self.oauthVerifier) [parameters setObject:self.oauthVerifier forKey:@"oauth_verifier"];
	return [parameters copy];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {
	
	NSMutableDictionary *OAuthParameters = [NSMutableDictionary new];
	[OAuthParameters addEntriesFromDictionary:[self _OAuthParameters]];
	[OAuthParameters addEntriesFromDictionary:authRequest.parameters];
	
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:request.URL
																 HTTPMethod:request.HTTPMethod
															 consumerSecret:self.consumerSecret
																secretToken:self.oauthTokenSecret
																 parameters:OAuthParameters
																	   type:self.signatureType];
	[request addValue:[signature authorizationHeader] forHTTPHeaderField:@"Authorization"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; consumerKey = %@; oauth_token = %@>",
			NSStringFromClass([self class]),
			self,
			self.consumerKey,
			self.oauthToken];
}

@end
