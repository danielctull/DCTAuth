//
//  DCTOAuthRequest.h
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthRequestMethod.h"

@interface DCTOAuthRequest : NSObject

@property(nonatomic, readonly) DCTOAuthRequestMethod requestMethod;

- (NSURLRequest *)signedURLRequest;
- (void)performRequestWithHandler:(void(^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))handler;

@end
