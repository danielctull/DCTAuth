//
//  DCTBasicAuthAccountCredential.m
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTBasicAuthAccountCredential.h"
#import "DCTBasicAuthAccount.h"
#import "DCTAuthRequest.h"
#import "NSData+DCTAuth.h"

@implementation DCTBasicAuthAccountCredential

- (id)initWithPassword:(NSString *)password {
	self = [super init];
	if (!self) return nil;
	_password = [password copy];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (!self) return nil;
	_password = [coder decodeObjectForKey:@"password"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.password forKey:@"password"];
}

@end
