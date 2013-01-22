//
//  _DCTAuthXMLParser.h
//  DCTAuth
//
//  Created by Daniel Tull on 22.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _DCTAuthXMLParser : NSObject
+ (NSDictionary *)dictionaryFromXMLData:(NSData *)data;
@end
