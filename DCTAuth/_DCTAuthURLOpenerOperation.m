//
//  _DCTAuthURLOpenerOperation.m
//  DCTAuth
//
//  Created by Daniel Tull on 27.09.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTAuthURLOpenerOperation.h"
#import "_DCTAuthURLOpener.h"

@interface _DCTAuthURLOpenerOperation ()
@property (nonatomic, getter = isCancelled) BOOL cancelled;
@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;
@end

@implementation _DCTAuthURLOpenerOperation

- (id)initWithURL:(NSURL *)URL callbackURL:(NSURL *)callbackURL handler:(void (^)(DCTAuthResponse *response))handler {
	self = [self init];
	if (!self) return nil;
	_URL = [URL copy];
	_callbackURL = [callbackURL copy];
	_handler = [handler copy];
	return self;
}

- (BOOL)handleURL:(NSURL *)URL {

	if (![self isExecuting]) return NO;

	if ([[URL absoluteString] hasPrefix:[self.callbackURL absoluteString]]) {
		DCTAuthResponse *response = [[DCTAuthResponse alloc] initWithURL:URL];
		dispatch_async(dispatch_get_main_queue(), ^{
			self.handler(response);
		});
		self.executing = NO;
		self.finished = YES;
		return YES;
	}

	return NO;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)cancel {
	self.executing = NO;
	self.cancelled = YES;
}

- (void)start {

	if (self.cancelled) return;

	self.executing = YES;
	[[_DCTAuthURLOpener sharedURLOpener] openURL:self.URL];
}

@end
