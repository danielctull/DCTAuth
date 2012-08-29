//
//  NSDictionary+DCTAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DCTAuth)

- (NSString *)dctAuth_queryString;
- (NSData *)dctAuth_bodyFormDataUsingEncoding:(NSStringEncoding)encoding;

@end
