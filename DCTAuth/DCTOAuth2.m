//
//  DCTOAuth2.m
//  DCTAuth
//
//  Created by Daniel Tull on 22.10.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTAuth.h"
#import "DCTOAuth2.h"

const struct DCTOAuth2Keys DCTOAuth2Keys = {
	.clientID = @"client_id",
	.clientSecret = @"client_secret",
	.responseType = @"response_type",
	.scope = @"scope",
	.state = @"state",
	.redirectURI = @"redirect_uri",
	.error = @"error",
	.errorDescription = @"error_description",
	.errorURI = @"error_uri",
	.grantType = @"grant_type",
	.code = @"code",
	.accessToken = @"access_token",
	.tokenType = @"token_type",
	.expiresIn = @"expires_in",
	.username = @"username",
	.password = @"password",
	.refreshToken = @"refresh_token",
	.token = @"token",
	.authorizationCode = @"authorization_code",
	.oauthToken = @"oauth_token",
	.bearer = @"Bearer"
};

@implementation DCTOAuth2

+ (NSError *)errorWithStatusCode:(NSInteger)statusCode dictionary:(NSDictionary *)dictionary {

	NSString *OAuthError = [dictionary objectForKey:DCTOAuth2Keys.error];

	if (![OAuthError isKindOfClass:[NSString class]]) return nil;

	NSString *description = [DCTAuth localizedStringForDomain:@"OAuth2" key:OAuthError];
	if (description.length == 0) description = @"An unknown error occured while attempting to authorize.";

	return [NSError errorWithDomain:@"DCTAuth"
							   code:statusCode
						   userInfo:@{NSLocalizedDescriptionKey : description}];
}

- (void)parseCredentialsFromResponse:(DCTAuthResponse *)response completion:(void (^)(NSError *error, NSString *code, NSString *accessToken, NSString *refreshToken, DCTOAuth2CredentialType type))completion {

	NSDictionary *dictionary = response.contentObject;

	if (![dictionary isKindOfClass:[NSDictionary class]]) {
		NSError *error = [NSError errorWithDomain:@"DCTAuth" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Response not dictionary."}];
		completion(error, nil, nil, nil, DCTOAuth2CredentialTypeParamter);
		return;
	}

	NSError *error = [DCTOAuth2 errorWithStatusCode:response.statusCode dictionary:dictionary];
	if (error) {
		completion(error, nil, nil, nil, DCTOAuth2CredentialTypeParamter);
		return;
	}

	NSString *code = dictionary[DCTOAuth2Keys.code];
	NSString *accessToken = dictionary[DCTOAuth2Keys.accessToken];
	NSString *refreshToken = dictionary[DCTOAuth2Keys.refreshToken];

	DCTOAuth2CredentialType type = DCTOAuth2CredentialTypeParamter;
	NSString *tokenType = [dictionary[DCTOAuth2Keys.tokenType] lowercaseString];
	NSString *bearer = [DCTOAuth2Keys.bearer lowercaseString];
	if ([tokenType isEqualToString:bearer]) {
		type = DCTOAuth2CredentialTypeBearer;
	}

	completion(nil, code, accessToken, refreshToken, type);
}

@end
