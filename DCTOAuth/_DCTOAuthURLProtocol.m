//
//  DCTOAuthURLProtocol.m
//  DCTOAuthConnectionController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuthURLProtocol.h"

@implementation _DCTOAuthURLProtocol

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	
	for (NSURL *callbackURL in [self _callbackHandlers])
		if ([self _URL:request.URL hasPrefix:callbackURL])
			return YES;
	
	return NO;
}

- (void)startLoading {
	
	NSURL *incomingURL = self.request.URL;
	
	[[[self class] _callbackHandlers] enumerateKeysAndObjectsUsingBlock:^(NSURL *callbackURL, void(^handler)(NSURL *), BOOL *stop) {
		
		if (![[self class] _URL:incomingURL hasPrefix:callbackURL])
			return;
		
		handler(incomingURL);
	}];
}

- (void)stopLoading {}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

#pragma mark - DCTOAuthURLProtocol

+ (void)registerForCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler {
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self registerClass:[self class]];
	});
	
	[[self _callbackHandlers] setObject:[handler copy] forKey:callbackURL];
}

+ (void)unregisterForCallbackURL:(NSURL *)callbackURL {
	[[self _callbackHandlers] removeObjectForKey:callbackURL];
}

#pragma mark - Internal

+ (BOOL)_URL:(NSURL *)URL hasPrefix:(NSURL *)prefixURL {
	return [[URL absoluteString] hasPrefix:[prefixURL absoluteString]];
}

+ (NSMutableDictionary *)_callbackHandlers {
	
	static NSMutableDictionary *_callbackHandlers;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_callbackHandlers = [NSMutableDictionary new];
	});
	return _callbackHandlers;
}

@end
