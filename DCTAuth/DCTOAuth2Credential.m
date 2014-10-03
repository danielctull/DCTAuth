//
//  DCTOAuth2Credential.m
//  DCTAuth
//
//  Created by Daniel Tull on 23/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTOAuth2Credential.h"

static const struct DCTOAuth2CredentialProperties {
	__unsafe_unretained NSString *clientID;
	__unsafe_unretained NSString *clientSecret;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *refreshToken;
} DCTOAuth2CredentialProperties;

static const struct DCTOAuth2CredentialProperties DCTOAuth2CredentialProperties = {
	.clientID = @"clientID",
	.clientSecret = @"clientSecret",
	.password = @"password",
	.accessToken = @"accessToken",
	.refreshToken = @"refreshToken"
};

@implementation DCTOAuth2Credential

- (instancetype)initWithClientID:(NSString *)clientID
					clientSecret:(NSString *)clientSecret
						password:(NSString *)password
					 accessToken:(NSString *)accessToken
					refreshToken:(NSString *)refreshToken {

	if (password.length == 0) {
		if (clientID.length == 0) return nil;
		if (accessToken.length == 0) return nil;
	}

	self = [self init];
	if (!self) return nil;
	_clientID = [clientID copy];
	_clientSecret = [clientSecret copy];
	_password = [password copy];
	_accessToken = [accessToken copy];
	_refreshToken = [refreshToken copy];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_clientID = [coder decodeObjectForKey:DCTOAuth2CredentialProperties.clientID];
	_clientSecret = [coder decodeObjectForKey:DCTOAuth2CredentialProperties.clientSecret];
	_password = [coder decodeObjectForKey:DCTOAuth2CredentialProperties.password];
	_accessToken = [coder decodeObjectForKey:DCTOAuth2CredentialProperties.accessToken];
	_refreshToken = [coder decodeObjectForKey:DCTOAuth2CredentialProperties.refreshToken];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.clientID forKey:DCTOAuth2CredentialProperties.clientID];
	[coder encodeObject:self.clientSecret forKey:DCTOAuth2CredentialProperties.clientSecret];
	[coder encodeObject:self.password forKey:DCTOAuth2CredentialProperties.password];
	[coder encodeObject:self.accessToken forKey:DCTOAuth2CredentialProperties.accessToken];
	[coder encodeObject:self.refreshToken forKey:DCTOAuth2CredentialProperties.refreshToken];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@ = %@; %@ = %@; %@ = %@; %@ = %@>",
			NSStringFromClass([self class]),
			self,
			DCTOAuth2CredentialProperties.clientID, self.clientID,
			DCTOAuth2CredentialProperties.clientSecret, self.clientSecret,
			DCTOAuth2CredentialProperties.accessToken, self.accessToken,
			DCTOAuth2CredentialProperties.refreshToken, self.refreshToken];
}

@end
