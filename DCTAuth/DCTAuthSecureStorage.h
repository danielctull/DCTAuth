//
//  DCTAuthSecureStorage.h
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"

@interface DCTAuthSecureStorage : NSObject

- (void)setObject:(NSString *)value forKey:(NSString *)key;
- (NSString *)objectForKey:(NSString *)key;

@end
