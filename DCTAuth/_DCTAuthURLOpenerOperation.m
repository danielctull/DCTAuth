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
@property (nonatomic) BOOL cancelled;
@property (nonatomic) BOOL executing;
@property (nonatomic) BOOL finished;
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

	if (!self.executing || self.finished || self.cancelled) return NO;

	if ([[URL absoluteString] hasPrefix:[self.callbackURL absoluteString]]) {
		DCTAuthResponse *response = [[DCTAuthResponse alloc] initWithURL:URL];
		[self handleResponse:response];
		[self finish];
		return YES;
	}

	return NO;
}

- (void)handleResponse:(DCTAuthResponse *)response {

	if (![NSThread isMainThread]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self handleResponse:response];
		});
		return;
	}

	self.handler(response);
}

- (BOOL)isReady {
	return self.URL != nil;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)setFinished:(BOOL)finished {
	[self willChangeValueForKey:@"isFinished"];
	_finished = finished;
	[self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished {
	return self.finished;
}

- (void)setExecuting:(BOOL)executing {
	[self willChangeValueForKey:@"isExecuting"];
	_executing = executing;
	[self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
	return self.executing;
}

- (void)setCancelled:(BOOL)cancelled {
	[self willChangeValueForKey:@"isCancelled"];
	_cancelled = cancelled;
	[self didChangeValueForKey:@"isCancelled"];

}

- (BOOL)isCancelled {
	return self.cancelled;
}

- (void)start {

	if (self.cancelled) return;

	self.executing = YES;

	[[_DCTAuthURLOpener sharedURLOpener] openURL:self.URL];
}

- (void)cancel {
	self.cancelled = YES;
	self.executing = NO;
}

- (void)finish {
	self.finished = YES;
	self.executing = NO;
}

@end
