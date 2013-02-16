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

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithEncryptedData:(NSData *)data;

- (NSData *)encryptWithAccount:(DCTAuthAccount *)account;
- (NSDictionary *)decryptWithAccount:(DCTAuthAccount *)account;

- (void)encryptValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)decryptValueForKey:(NSString *)key;

+ (void)removeAllKeychainItemsForAccount:(DCTAuthAccount *)account;

@end
