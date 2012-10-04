//
//  _DCTAuthURLOpener.m
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTAuthURLOpener.h"
#import "_DCTAuthPlatform.h"

@interface _DCTAuthOpen : NSObject
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSURL *callbackURL;
@property (nonatomic, copy) void (^handler)(NSURL *URL);
@end
@implementation _DCTAuthOpen
@end

@implementation _DCTAuthURLOpener {
	__strong NSMutableArray *_queue;
	BOOL _opening;
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
	_queue = [NSMutableArray new];
    return self;
}

- (BOOL)handleURL:(NSURL *)URL {

	__block BOOL handled = NO;
	NSString *URLString = [URL absoluteString];
	
	[[_queue copy] enumerateObjectsUsingBlock:^(_DCTAuthOpen *open, NSUInteger idx, BOOL *stop) {
		
		if ([URLString hasPrefix:[open.callbackURL absoluteString]]) {
			open.handler(URL);
			[_queue removeObject:open];
			handled = YES;
			*stop = YES;
		}
	}];
	
	_opening = !handled;
	[self _openNextURL];

	return handled;
}

- (void)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler {
	NSLog(@"%@:%@ %@ %@", self, NSStringFromSelector(_cmd), URL, callbackURL);
	_DCTAuthOpen *open = [_DCTAuthOpen new];
	open.URL = URL;
	open.callbackURL = callbackURL;
	open.handler = handler;
	[_queue addObject:open];
	[self _openNextURL];
}

- (void)_openNextURL {
	if (_opening) return;
	if ([_queue count] == 0) return;

	_DCTAuthOpen *open = [_queue objectAtIndex:0];
	
	if (self.URLOpener) _opening = self.URLOpener(open.URL);
	if (!_opening) _opening = [_DCTAuthPlatform openURL:open.URL];

	if (!_opening) {
		[_queue removeObject:open];
		[self _openNextURL];
	}
}

@end
