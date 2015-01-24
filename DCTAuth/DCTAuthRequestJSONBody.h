//
//  DCTAuthRequestJSONBody.h
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequestBody.h"

@interface DCTAuthRequestJSONBody : NSObject <DCTAuthRequestBody>

- (instancetype)initWithJSONObject:(id<NSCopying>)JSON;
@property (nonatomic, readonly) id JSON;

@end
