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

@interface _DCTAuthURLOpener ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) _DCTAuthOpen *currentOpen;
@end

@implementation _DCTAuthURLOpener

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
	
	[[self.queue copy] enumerateObjectsUsingBlock:^(_DCTAuthOpen *open, NSUInteger idx, BOOL *stop) {
		
		if ([URLString hasPrefix:[open.callbackURL absoluteString]]) {
			open.handler(URL);
			[self close:open];
			handled = YES;
			*stop = YES;
		}
	}];

	[self _openNextURL];

	return handled;
}

- (id)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler {
	_DCTAuthOpen *open = [_DCTAuthOpen new];
	open.URL = URL;
	open.callbackURL = callbackURL;
	open.handler = handler;
	[self.queue addObject:open];
	[self _openNextURL];
	return open;
}

- (void)close:(id)object {
	[self.queue removeObject:object];
	if ([self.currentOpen isEqual:object]) self.currentOpen = nil;
	[self _openNextURL];
}

- (void)_openNextURL {
	if (self.currentOpen != nil) return;
	if ([self.queue count] == 0) return;

	_DCTAuthOpen *open = [self.queue objectAtIndex:0];

	BOOL isOpen = NO;
	if (self.URLOpener != NULL) isOpen = self.URLOpener(open.URL);
	if (!isOpen) isOpen = [_DCTAuthPlatform openURL:open.URL];

	if (isOpen)
		self.currentOpen = open;
	else {
		[self.queue removeObject:open];
		[self _openNextURL];
	}
}

@end
