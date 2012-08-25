//
//  AppDelegate.m
//  OAuth Demo
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "AppDelegate.h"
#import "OAuthTestViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[OAuthTestViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

// These methods fire the URL as a request in a connection. Custom protocol handlers
// will handle these. For instance, the Facebook handler will handle Facebook callbacks
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection connectionWithRequest:request delegate:nil];
	return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection connectionWithRequest:request delegate:nil];
	return NO;
}

@end
