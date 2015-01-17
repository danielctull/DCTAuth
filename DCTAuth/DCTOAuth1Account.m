//
//  DCTOAuth1Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuth1Account.h"
#import "DCTOAuth1.h"
#import "DCTAuthAccountSubclass.h"
#import "DCTOAuth1Credential.h"
#import "DCTOAuthSignature.h"
#import "DCTAuth.h"
#import "DCTAuthRequest.h"
#import "NSString+DCTAuth.h"

static const struct DCTOAuth1AccountProperties {
	__unsafe_unretained NSString *consumerKey;
	__unsafe_unretained NSString *consumerSecret;
	__unsafe_unretained NSString *requestTokenURL;
	__unsafe_unretained NSString *accessTokenURL;
	__unsafe_unretained NSString *authorizeURL;
	__unsafe_unretained NSString *signatureType;
	__unsafe_unretained NSString *parameterTransmission;
	__unsafe_unretained NSString *openURLObject;
} DCTOAuth1AccountProperties;

static const struct DCTOAuth1AccountProperties DCTOAuth1AccountProperties = {
	.consumerKey = @"consumerKey",
	.consumerSecret = @"consumerSecret",
	.requestTokenURL = @"requestTokenURL",
	.accessTokenURL = @"accessTokenURL",
	.authorizeURL = @"authorizeURL",
	.signatureType = @"signatureType",
	.parameterTransmission = @"parameterTransmission",
	.openURLObject = @"openURLObject"
};

@interface DCTOAuth1Account () <DCTAuthAccountSubclass>
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSURL *requestTokenURL;
@property (nonatomic, copy) NSURL *accessTokenURL;
@property (nonatomic, copy) NSURL *authorizeURL;
@property (nonatomic, assign) DCTOAuthSignatureType signatureType;
@property (nonatomic, assign) DCTOAuthParameterTransmission parameterTransmission;
@property (nonatomic, strong) id openURLObject;
@end

@implementation DCTOAuth1Account

- (instancetype)initWithType:(NSString *)type
			 requestTokenURL:(NSURL *)requestTokenURL
				authorizeURL:(NSURL *)authorizeURL
			  accessTokenURL:(NSURL *)accessTokenURL
				 consumerKey:(NSString *)consumerKey
			  consumerSecret:(NSString *)consumerSecret
			   signatureType:(DCTOAuthSignatureType)signatureType
	   parameterTransmission:(DCTOAuthParameterTransmission)parameterTransmission {
	
	self = [self initWithType:type];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	_signatureType = signatureType;
	_parameterTransmission = parameterTransmission;
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	_requestTokenURL = [coder decodeObjectForKey:DCTOAuth1AccountProperties.requestTokenURL];
	_accessTokenURL = [coder decodeObjectForKey:DCTOAuth1AccountProperties.accessTokenURL];
	_authorizeURL = [coder decodeObjectForKey:DCTOAuth1AccountProperties.authorizeURL];
	_signatureType = [[coder decodeObjectForKey:DCTOAuth1AccountProperties.signatureType] integerValue];
	_parameterTransmission = [[coder decodeObjectForKey:DCTOAuth1AccountProperties.parameterTransmission] integerValue];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.requestTokenURL forKey:DCTOAuth1AccountProperties.requestTokenURL];
	[coder encodeObject:self.accessTokenURL forKey:DCTOAuth1AccountProperties.accessTokenURL];
	[coder encodeObject:self.authorizeURL forKey:DCTOAuth1AccountProperties.authorizeURL];
	[coder encodeObject:@(self.signatureType) forKey:DCTOAuth1AccountProperties.signatureType];
	[coder encodeObject:@(self.parameterTransmission) forKey:DCTOAuth1AccountProperties.parameterTransmission];
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {

	NSMutableArray *responses = [NSMutableArray new];

	DCTOAuth1Credential *credential = self.credential;
	NSString *consumerKey = self.consumerKey ?: credential.consumerKey;
	NSString *consumerSecret = self.consumerSecret ?: credential.consumerSecret;
	NSString *callback = self.callbackURL.absoluteString;
	__block NSString *oauthToken;
	__block NSString *oauthTokenSecret;
	__block NSString *oauthVerifier;

	NSArray *(^OAuthItems)() = ^{

		NSMutableArray *OAuthItems = [NSMutableArray new];

		if (oauthToken.length > 0) {
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:DCTOAuth1Keys.token value:oauthToken];
			[OAuthItems addObject:item];
		}

		if (consumerKey.length > 0) {
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:DCTOAuth1Keys.comsumerKey value:consumerKey];
			[OAuthItems addObject:item];
		}

		if (oauthVerifier.length > 0) {
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:DCTOAuth1Keys.verifier value:oauthVerifier];
			[OAuthItems addObject:item];
		}

		if (self.shouldSendCallbackURL && callback) {
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:DCTOAuth1Keys.callback value:callback];
			[OAuthItems addObject:item];
		}

		return [OAuthItems copy];
	};

	NSString *(^signature)(DCTAuthRequest *) = ^(DCTAuthRequest *request) {

		NSMutableArray *items = [OAuthItems() mutableCopy];
		[items addObjectsFromArray:request.items];
		NSString *HTTPMethod = NSStringFromDCTAuthRequestMethod(request.requestMethod);

		DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:request.URL
																   HTTPMethod:HTTPMethod
															   consumerSecret:consumerSecret
																  secretToken:oauthTokenSecret
																		items:items
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

						if ([key isEqualToString:DCTOAuth1Keys.token])
							oauthToken = value;

						else if	([key isEqualToString:DCTOAuth1Keys.verifier])
							oauthVerifier = value;

						else if ([key isEqualToString:DCTOAuth1Keys.tokenSecret])
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
		DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET URL:self.accessTokenURL items:nil];
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

		DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET URL:self.authorizeURL items:OAuthItems()];
		NSURL *authorizeURL = [[request signedURLRequest] URL];
		self.openURLObject = [DCTAuth openURL:authorizeURL withCallbackURL:self.callbackURL handler:authorizeHandler];
	};

	DCTAuthRequest *requestTokenRequest = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET URL:self.requestTokenURL items:nil];
	requestTokenRequest.HTTPHeaders = @{ @"Authorization" : signature(requestTokenRequest) };
	[requestTokenRequest performRequestWithHandler:requestTokenHandler];
}

- (void)cancelAuthentication {
	[super cancelAuthentication];
	[DCTAuth cancelOpenURL:self.openURLObject];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {

	DCTOAuth1Credential *credential = self.credential;
	NSString *oauthToken = credential.oauthToken;
	NSString *consumerKey = credential.consumerKey;

	NSMutableArray *OAuthItems = [NSMutableArray new];
	
	if (oauthToken) {
		NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:DCTOAuth1Keys.token value:oauthToken];
		[OAuthItems addObject:item];
	}

	if (consumerKey) {
		NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:DCTOAuth1Keys.comsumerKey value:consumerKey];
		[OAuthItems addObject:item];
	}
	
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:request.URL
															   HTTPMethod:request.HTTPMethod
														   consumerSecret:credential.consumerSecret
															  secretToken:credential.oauthTokenSecret
																	items:OAuthItems
																	 type:self.signatureType];

	switch (self.parameterTransmission) {

		case DCTOAuthParameterTransmissionAuthorizationHeader: {
			NSString *authorizationHeader = signature.authorizationHeader;
			if (authorizationHeader) [request addValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
			break;
		}

		case DCTOAuthParameterTransmissionURLQuery: {
			NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
			NSMutableArray *items = [NSMutableArray new];
			[items addObjectsFromArray:signature.authorizationItems];
			[items addObjectsFromArray:URLComponents.queryItems];
			URLComponents.queryItems = items;
			request.URL = URLComponents.URL;
		}
	}
}

@end
