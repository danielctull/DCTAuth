//
//  DCTAuthPlatform.m
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthPlatform.h"

#if TARGET_OS_IPHONE

@import UIKit;

@implementation DCTAuthPlatform
+ (id)beginBackgroundTaskWithExpirationHandler:(void(^)())handler {
	UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:handler];
	return @(identifier);
}
+ (void)endBackgroundTask:(id)object {
	[[UIApplication sharedApplication] endBackgroundTask:[object unsignedIntegerValue]];
}
+ (BOOL)openURL:(NSURL *)URL {
	return [[UIApplication sharedApplication] openURL:URL];
}
+ (id)imageFromData:(NSData *)data {
	return [[UIImage alloc] initWithData:data];
}
@end

#else

@import AppKit;

@implementation DCTAuthPlatform
+ (id)beginBackgroundTaskWithExpirationHandler:(void(^)())handler {
	return nil;
}
+ (void)endBackgroundTask:(id)object {}
+ (BOOL)openURL:(NSURL *)URL {
	return [[NSWorkspace sharedWorkspace] openURL:URL];
}
+ (id)imageFromData:(NSData *)data {
	return [[NSImage alloc] initWithData:data];
}
@end

#endif