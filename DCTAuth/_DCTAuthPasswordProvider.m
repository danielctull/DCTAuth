//
//  _DCTAuthPasswordProvider.m
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTAuthPasswordProvider.h"

@implementation _DCTAuthPasswordProvider

+ (instancetype)sharedPasswordProvider {
	static _DCTAuthPasswordProvider *provider;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		provider = [self new];
	});
	return provider;
}

- (NSString *)passwordForAccount:(DCTAuthAccount *)account {

	if (!self.passwordProvider)
		return nil;

	return self.passwordProvider(account);
}


@end
