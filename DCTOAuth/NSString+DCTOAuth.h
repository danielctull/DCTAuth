//
//  NSString+DCTOAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DCTOAuth)
- (NSString *)dctOAuth_URLEncodedString;
- (NSDictionary *)dctOAuth_parameterDictionary;
@end
