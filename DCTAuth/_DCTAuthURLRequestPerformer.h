//
//  _DCTAuthURLRequestPerformer.h
//  DCTAuth
//
//  Created by Daniel Tull on 20.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthRequest.h"

@interface _DCTAuthURLRequestPerformer : NSObject

+ (instancetype)sharedURLRequestPerformer;

- (void)performRequest:(NSURLRequest *)URLRequest withHandler:(DCTAuthRequestHandler)handler;

@property (nonatomic, copy) void(^URLRequestPerformer)(NSURLRequest *request, DCTAuthRequestHandler handler);

@end
