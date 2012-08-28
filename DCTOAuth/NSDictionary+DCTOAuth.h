//
//  NSDictionary+DCTOAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DCTOAuth)

- (NSString *)dctOAuth_queryString;
- (NSData *)dctOAuth_bodyFormDataUsingEncoding:(NSStringEncoding)encoding;

@end
