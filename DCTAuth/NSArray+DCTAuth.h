//
//  NSArray+DCTAuth.h
//  DCTAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import Foundation;

@interface NSArray (DCTAuth)

- (NSData *)dctAuth_formDataUsingEncoding:(NSStringEncoding)encoding;
- (NSData *)dctAuth_JSONDataUsingEncoding:(NSStringEncoding)encoding;
- (NSData *)dctAuth_plistDataUsingEncoding:(NSStringEncoding)encoding;

@end
