//
//  _DCTAuthURLOpener.h
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _DCTAuthURLOpener : NSObject

+ (_DCTAuthURLOpener *)sharedURLOpener;

- (BOOL)handleURL:(NSURL *)URL;
- (void)openURL:(NSURL *)URL withCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler;
@property (nonatomic, copy) BOOL (^URLOpener)(NSURL *URL);

@end
