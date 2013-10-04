//
//  DCTBasicAuthAccountCredential.m
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTBasicAuthCredential.h"

static const struct _DCTBasicAuthCredentialProperties {
	__unsafe_unretained NSString *password;
} _DCTBasicAuthCredentialProperties;

static const struct _DCTBasicAuthCredentialProperties _DCTBasicAuthCredentialProperties = {
	.password = @"password"
};

@implementation _DCTBasicAuthCredential

- (instancetype)initWithPassword:(NSString *)password {
	self = [self init];
	if (!self) return nil;
	_password = [password copy];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_password = [coder decodeObjectForKey:_DCTBasicAuthCredentialProperties.password];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.password forKey:_DCTBasicAuthCredentialProperties.password];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@ = %@>",
			NSStringFromClass([self class]),
			self,
			_DCTBasicAuthCredentialProperties.password, self.password];
}

@end
