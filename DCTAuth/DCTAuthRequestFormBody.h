//
//  DCTAuthRequestFormBody.h
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequestBody.h"

@interface DCTAuthRequestFormBody : NSObject <DCTAuthRequestBody>

- (instancetype)initWithEncoding:(NSStringEncoding)encoding dictionary:(NSDictionary *)dictionary;
@property (nonatomic, readonly) NSDictionary *dictionary;
@property (nonatomic, readonly) NSStringEncoding encoding;

@end
