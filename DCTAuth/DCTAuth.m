//
//  DCTAuth.m
//  DCTAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuth.h"
#import "_DCTAuthURLOpener.h"
#import "_DCTAuthURLRequestPerformer.h"

@implementation DCTAuth

+ (BOOL)handleURL:(NSURL *)URL {
	return [[_DCTAuthURLOpener sharedURLOpener] handleURL:URL];
}

+ (void)setURLOpener:(BOOL(^)(NSURL *URL))opener {
	[[_DCTAuthURLOpener sharedURLOpener] setURLOpener:opener];
}

+ (id)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackPrefixURL handler:(void (^)(DCTAuthResponse *response))handler {
	return [[_DCTAuthURLOpener sharedURLOpener] openURL:URL withCallbackURL:callbackPrefixURL handler:handler];
}

+ (void)cancelOpenURL:(id)object {
	[[_DCTAuthURLOpener sharedURLOpener] close:object];
}

+ (void)setURLRequestPerformer:(void(^)(NSURLRequest *request, DCTAuthRequestHandler handler))requestPerformer {
	[[_DCTAuthURLRequestPerformer sharedURLRequestPerformer] setURLRequestPerformer:requestPerformer];
}

@end
