//
//  DCTAuthPlatform.h
//  DCTAuth
//
//  Created by Daniel Tull on 31/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import Foundation;

typedef void(^DCTAuthPlatformCompletion)(BOOL success);
typedef void(^DCTAuthPlatformExpirationHandler)();

@interface DCTAuthPlatform : NSObject

+ (instancetype)sharedPlatform;

@property (nonatomic, copy) void (^URLOpener) (NSURL *URL, DCTAuthPlatformCompletion completion);
@property (nonatomic, copy) id (^beginBackgroundTaskHandler) (DCTAuthPlatformExpirationHandler expirationHandler);
@property (nonatomic, copy) void (^endBackgroundTaskHandler) (id identifier);

// Used by DCTAuthAccount subclasses to open a webpage

- (void)openURL:(NSURL *)URL completion:(DCTAuthPlatformCompletion)completion;
- (id)beginBackgroundTaskWithExpirationHandler:(void(^)())handler;
- (void)endBackgroundTask:(id)identifier;

@end
