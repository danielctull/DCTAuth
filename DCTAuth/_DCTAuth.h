//
//  _DCTOAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuth.h"

@interface DCTAuth (Private)
+ (void)_registerForCallbackURL:(NSURL *)callbackURL handler:(void (^)(NSURL *URL))handler;
@end
