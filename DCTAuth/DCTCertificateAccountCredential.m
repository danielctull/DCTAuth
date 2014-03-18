//
//  DCTCertificateAccountCredential.m
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTCertificateAccountCredential.h"

static const struct DCTCertificateAccountCredentialProperties {
	__unsafe_unretained NSString *certificate;
	__unsafe_unretained NSString *password;
} DCTCertificateAccountCredentialProperties;

static const struct DCTCertificateAccountCredentialProperties DCTCertificateAccountCredentialProperties = {
	.certificate = @"ceritficate",
	.password = @"password"
};

@implementation DCTCertificateAccountCredential

- (instancetype)initWithCertificate:(NSData *)certificate password:(NSString *)password {
	self = [self init];
	if (!self) return nil;
	_certificate = [certificate copy];
	_password = [password copy];
	return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_certificate = [coder decodeObjectForKey:DCTCertificateAccountCredentialProperties.certificate];
	_password = [coder decodeObjectForKey:DCTCertificateAccountCredentialProperties.password];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.certificate forKey:DCTCertificateAccountCredentialProperties.certificate];
	[coder encodeObject:self.password forKey:DCTCertificateAccountCredentialProperties.password];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@ = %@; %@ = %@>",
			NSStringFromClass([self class]),
			self,
			DCTCertificateAccountCredentialProperties.certificate, self.certificate,
			DCTCertificateAccountCredentialProperties.password, self.password];
}


@end
