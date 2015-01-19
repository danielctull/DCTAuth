//
//  DCTTestAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTTestAccount.h"

@implementation DCTTestAccount

- (instancetype)init {
	return [super initWithType:@"Test Account"];
}

#pragma mark - DCTAuthAccountSubclass

- (void)signURLRequest:(NSMutableURLRequest *)request {}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {}

- (void)reauthenticateWithHandler:(void(^)(DCTAuthResponse *response, NSError *error))handler {}

- (void)cancelAuthentication {}

@end
