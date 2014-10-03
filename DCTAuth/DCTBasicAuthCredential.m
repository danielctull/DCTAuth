//
//  DCTBasicAuthCredential.m
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTBasicAuthCredential.h"

static const struct DCTBasicAuthCredentialProperties {
	__unsafe_unretained NSString *password;
} DCTBasicAuthCredentialProperties;

static const struct DCTBasicAuthCredentialProperties DCTBasicAuthCredentialProperties = {
	.password = @"password"
};

@implementation DCTBasicAuthCredential

- (instancetype)initWithPassword:(NSString *)password {
	self = [self init];
	if (!self) return nil;
	_password = [password copy];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_password = [coder decodeObjectForKey:DCTBasicAuthCredentialProperties.password];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.password forKey:DCTBasicAuthCredentialProperties.password];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@ = %@>",
			NSStringFromClass([self class]),
			self,
			DCTBasicAuthCredentialProperties.password, self.password];
}

@end
