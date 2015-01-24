//
//  DCTAuthRequestBody.h
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;

@protocol DCTAuthRequestBody <NSObject>

@property (nonatomic, readonly) NSDictionary *HTTPHeaderFields;
@property (nonatomic, readonly) NSData *HTTPBody;

@end
