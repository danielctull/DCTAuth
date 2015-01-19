//
//  DCTTestAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTTestAccount.h"

const struct DCTTestAccountAttributes DCTTestAccountAttributes = {
	.name = @"name"
};

@implementation DCTTestAccount

- (instancetype)init {
	return [self initWithName:[[NSUUID UUID] UUIDString]];
}

- (instancetype)initWithName:(NSString *)name {
	self = [super initWithType:@"Test Account"];
	if (!self) return nil;
	_name = [name copy];
	return self;
}

#pragma mark - DCTAuthAccountSubclass

- (void)signURLRequest:(NSMutableURLRequest *)request {}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {}

- (void)reauthenticateWithHandler:(void(^)(DCTAuthResponse *response, NSError *error))handler {}

- (void)cancelAuthentication {}

@end
