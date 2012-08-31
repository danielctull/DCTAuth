//
//  _DCTAuthURLOpener.m
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTAuthURLOpener.h"
#import "_DCTAuthPlatform.h"

@implementation _DCTAuthURLOpener {
	__strong NSMutableDictionary *_handlers;
}

+ (_DCTAuthURLOpener *)sharedURLOpener {
	static _DCTAuthURLOpener *opener;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		opener = [_DCTAuthURLOpener new];
	});
	return opener;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
	_handlers = [NSMutableDictionary new];
    return self;
}

- (BOOL)handleURL:(NSURL *)URL {

	__block NSURL *handlerURL = nil;
	NSString *URLString = [URL absoluteString];
	
	[_handlers enumerateKeysAndObjectsUsingBlock:^(NSURL *prefixURL, id obj, BOOL *stop) {

		if ([URLString hasPrefix:[prefixURL absoluteString]]) {
			handlerURL = prefixURL;
			*stop = YES;
		}
	}];

	if (!handlerURL) return NO;

	void (^handler)(NSURL *) = [_handlers objectForKey:handlerURL];
	handler(URL);
	[_handlers removeObjectForKey:handlerURL];

	return YES;
}

- (void)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler {
	[_handlers setObject:[handler copy] forKey:[callbackURL copy]];
	[_DCTAuthPlatform openURL:URL];
}

@end
