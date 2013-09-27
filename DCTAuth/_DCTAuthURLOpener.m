//
//  _DCTAuthURLOpener.m
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTAuthURLOpener.h"
#import "_DCTAuthURLOpenerOperation.h"
#import "_DCTAuthPlatform.h"

@interface _DCTAuthURLOpener ()
@property (nonatomic, strong) NSOperationQueue *queue;
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
	_queue = [NSOperationQueue new];
	_queue.maxConcurrentOperationCount = 1;
    return self;
}

- (BOOL)handleURL:(NSURL *)URL {

	__block BOOL handled = NO;

	[self.queue.operations enumerateObjectsUsingBlock:^(_DCTAuthURLOpenerOperation *operation, NSUInteger i, BOOL *stop) {
		*stop = handled = [operation handleURL:URL];
	}];

	return handled;
}

- (id)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(DCTAuthResponse *response))handler {


	_DCTAuthURLOpenerOperation *operation = [[_DCTAuthURLOpenerOperation alloc] initWithURL:URL
																				callbackURL:callbackURL
																					handler:handler];
	[self.queue addOperation:operation];
	return operation;
}

- (void)close:(id)object {
	NSAssert([object isKindOfClass:[_DCTAuthURLOpenerOperation class]], @"Object should be the object returned from openURL:withCallbackURL:handler:");
	_DCTAuthURLOpenerOperation *operation = object;
	[operation cancel];
}

- (void)openURL:(NSURL *)URL {
	dispatch_async(dispatch_get_main_queue(), ^{
		BOOL isOpen = NO;
		if (self.URLOpener != NULL) isOpen = self.URLOpener(URL);
		if (!isOpen) [_DCTAuthPlatform openURL:URL];
	});
}

@end
