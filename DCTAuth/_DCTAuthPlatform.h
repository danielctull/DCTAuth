//
//  _DCTAuthPlatform.h
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _DCTAuthPlatform : NSObject
+ (id)beginBackgroundTaskWithExpirationHandler:(void(^)())handler;
+ (void)endBackgroundTask:(id)object;
+ (BOOL)openURL:(NSURL *)URL;
@end
