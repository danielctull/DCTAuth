//
//  DCTAuthURLOpener.h
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthResponse.h"

@interface DCTAuthURLOpener : NSObject

+ (DCTAuthURLOpener *)sharedURLOpener;

- (id)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(DCTAuthResponse *response))handler;
- (void)close:(id)object;

@property (nonatomic, copy) BOOL (^URLOpener)(NSURL *URL);

- (void)openURL:(NSURL *)URL;
- (BOOL)handleURL:(NSURL *)URL;

@end
