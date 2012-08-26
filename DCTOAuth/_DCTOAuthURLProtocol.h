//
//  DCTOAuthURLProtocol.h
//  DCTOAuthConnectionController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _DCTOAuthURLProtocol : NSURLProtocol

+ (void)registerForCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler;
+ (void)unregisterForCallbackURL:(NSURL *)callbackURL;

@end
