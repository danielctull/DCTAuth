//
//  DCTOAuth1AccountCredential.m
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth1Credential.h"

static const struct _DCTOAuth1CredentialProperties {
	__unsafe_unretained NSString *consumerKey;
	__unsafe_unretained NSString *consumerSecret;
	__unsafe_unretained NSString *oauthToken;
	__unsafe_unretained NSString *oauthTokenSecret;
} _DCTOAuth1CredentialProperties;

static const struct _DCTOAuth1CredentialProperties _DCTOAuth1CredentialProperties = {
	.consumerKey = @"consumerKey",
	.consumerSecret = @"consumerSecret",
	.oauthToken = @"oauthToken",
	.oauthTokenSecret = @"oauthTokenSecret"
};

@implementation _DCTOAuth1Credential

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
		   consumerSecret:(NSString *)consumerSecret
			   oauthToken:(NSString *)oauthToken
		 oauthTokenSecret:(NSString *)oauthTokenSecret {

	if (consumerKey.length == 0) return nil;
	if (consumerSecret.length == 0) return nil;
	if (oauthToken.length == 0) return nil;
	if (oauthTokenSecret.length == 0) return nil;

	self = [self init];
	if (!self) return nil;
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	_oauthToken = [oauthToken copy];
	_oauthTokenSecret = [oauthTokenSecret copy];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_consumerKey = [coder decodeObjectForKey:_DCTOAuth1CredentialProperties.consumerKey];
	_consumerSecret = [coder decodeObjectForKey:_DCTOAuth1CredentialProperties.consumerSecret];
	_oauthToken = [coder decodeObjectForKey:_DCTOAuth1CredentialProperties.oauthToken];
	_oauthTokenSecret = [coder decodeObjectForKey:_DCTOAuth1CredentialProperties.oauthTokenSecret];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.consumerKey forKey:_DCTOAuth1CredentialProperties.consumerKey];
	[coder encodeObject:self.consumerSecret forKey:_DCTOAuth1CredentialProperties.consumerSecret];
	[coder encodeObject:self.oauthToken forKey:_DCTOAuth1CredentialProperties.oauthToken];
	[coder encodeObject:self.oauthTokenSecret forKey:_DCTOAuth1CredentialProperties.oauthTokenSecret];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@ = %@; %@ = %@; %@ = %@; %@ = %@>",
			NSStringFromClass([self class]),
			self,
			_DCTOAuth1CredentialProperties.consumerKey, self.consumerKey,
			_DCTOAuth1CredentialProperties.consumerSecret, self.consumerSecret,
			_DCTOAuth1CredentialProperties.oauthToken, self.oauthToken,
			_DCTOAuth1CredentialProperties.oauthTokenSecret, self.oauthTokenSecret];
}

@end
