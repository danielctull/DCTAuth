//
//  DCTAuthSecureStorage.h
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"

@interface DCTAuthSecureStorage : NSObject <NSCoding>

- (id)initWithAccount:(DCTAuthAccount *)account;
@property (nonatomic, weak) DCTAuthAccount *account;


- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

@end
