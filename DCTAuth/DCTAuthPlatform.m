//
//  DCTAuthPlatform.m
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthPlatform.h"

@implementation DCTAuthPlatform

+ (instancetype)sharedPlatform {
	static DCTAuthPlatform *platform;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		platform = [self new];
	});
	return platform;
}

- (void)openURL:(NSURL *)URL completion:(DCTAuthPlatformCompletion)completion {

	if (!completion) {
		completion = ^(BOOL success) {};
	}

	if (!self.URLOpener) {
		completion(NO);
		return;
	}

	self.URLOpener(URL, completion);
}

- (id)beginBackgroundTaskWithExpirationHandler:(void(^)())handler {

	if (!self.beginBackgroundTaskHandler) {
		return nil;
	}

	return self.beginBackgroundTaskHandler(handler);
}

- (void)endBackgroundTask:(id)identifier {

	if (!self.endBackgroundTaskHandler) {
		return;
	}

	self.endBackgroundTaskHandler(identifier);
}

@end
