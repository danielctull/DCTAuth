//
//  DCTAuthRequestComponents.h
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;
#import "DCTAuthRequestMethod.h"
@protocol DCTAuthRequestBody;

@interface DCTAuthRequestComponents : NSObject

- (instancetype)initWithRequest:(NSURLRequest *)request;
@property (nonatomic, readonly) NSURLRequest *request;


@property (nonatomic) DCTAuthRequestMethod requestMethod;
@property (nonatomic) id<DCTAuthRequestBody> body;

@end
