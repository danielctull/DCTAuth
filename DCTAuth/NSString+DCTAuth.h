//
//  NSString+DCTOAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import Foundation;

@interface NSString (DCTAuth)

- (NSString *)dctAuth_URLEncodedString;
- (NSString *)dctAuth_bodyFormEncodedString;
- (NSDictionary *)dctAuth_parameterDictionary;

@end
