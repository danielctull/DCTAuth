//
//  DCTAuth.m
//  DCTAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuth.h"

@implementation DCTAuth

+ (BOOL)handleURL:(NSURL *)URL {
	
	__block NSURL *handlerURL = nil;
	NSString *URLString = [URL absoluteString];
	NSMutableDictionary *handlers = [self _handlers];
	
	[handlers enumerateKeysAndObjectsUsingBlock:^(NSURL *prefixURL, id obj, BOOL *stop) {
		
		if ([URLString hasPrefix:[prefixURL absoluteString]]) {
			handlerURL = prefixURL;
			*stop = YES;
		}
	}];
	
	if (!handlerURL) return NO;
	
	void (^handler)(NSURL *) = [handlers objectForKey:handlerURL];
	handler(URL);
	[handlers removeObjectForKey:handlerURL];
	
	return YES;
}
			
+ (BOOL)_URL:(NSURL *)URL hasPrefix:(NSURL *)prefixURL {
	return [[URL absoluteString] hasPrefix:[prefixURL absoluteString]];
}

+ (NSMutableDictionary *)_handlers {
	static NSMutableDictionary *handlers;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		handlers = [NSMutableDictionary new];
	});
	return handlers;
}

@end

#import "_DCTAuth.h"

#ifdef TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@implementation DCTAuth (Private)

+ (void)_openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler {

	[[self _handlers] setObject:[handler copy] forKey:[callbackURL copy]];
	
#ifdef TARGET_OS_IPHONE
	[[UIApplication sharedApplication] openURL:URL];
#else
	[[NSWorkspace sharedWorkspace] openURL:URL];
#endif
}

@end
