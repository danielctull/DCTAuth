//
//  AppDelegate.m
//  OAuth Demo
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "AppDelegate.h"
#import <DCTOAuthController/DCTOAuthController.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	NSString *consumerKey = @"";
	NSString *consumerSecret = @"";
	
	NSURL *callbackURL = [NSURL URLWithString:@"oauthcallback://"];
	NSURL *requestTokenURL = [NSURL URLWithString:@""];
	NSURL *accessTokenURL = [NSURL URLWithString:@""];
	NSURL *authorizeURL = [NSURL URLWithString:@""];
		
	DCTOAuthController *oauthController = [[DCTOAuthController alloc] initWithRequestTokenURL:requestTokenURL
																			   accessTokenURL:accessTokenURL
																				 authorizeURL:authorizeURL
																				  callbackURL:callbackURL
																				  consumerKey:consumerKey
																			   consumerSecret:consumerSecret];
	
	[oauthController fetchAccessTokenCompletion:^(NSDictionary *returnedValues) {
		NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), returnedValues);
	}];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [UIViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

// These methods fire the URL as a request in a connection. Custom protocol handlers
// will handle these. For instance, the Facebook handler will handle Facebook callbacks
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), url);
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection connectionWithRequest:request delegate:nil];
	return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), url);
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection connectionWithRequest:request delegate:nil];
	return NO;
}

@end
