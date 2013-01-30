//
//  AppDelegate.m
//  OAuth Demo
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "AppDelegate.h"
#import <DCTAuth/DCTAuth.h>
#import "AuthTestViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	NSString *charset = @"UTF-8";
	CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)charset);
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), @(encoding));
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), @(kCFStringEncodingUTF8));

	NSStringEncoding stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), @(stringEncoding));
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), @(NSUTF8StringEncoding));

	charset = (__bridge_transfer NSString *)CFStringConvertEncodingToIANACharSetName(encoding);
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), charset);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[AuthTestViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)URL {
	return [DCTAuth handleURL:URL];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [DCTAuth handleURL:URL];
}

@end
