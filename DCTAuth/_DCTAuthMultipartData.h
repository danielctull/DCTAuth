//
//  _DCTAuthMultipartData.h
//  DCTAuth
//
//  Created by Daniel Tull on 02/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _DCTAuthMultipartData : NSObject

@property (nonatomic, copy) NSData *data;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;

- (NSData *)dataWithBoundary:(NSString *)boundary;

@end
