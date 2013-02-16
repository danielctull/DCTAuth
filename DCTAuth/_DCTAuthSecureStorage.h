//
//  _DCTAuthSecureStorage.h
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthSecureStorage.h"

@interface DCTAuthSecureStorage (Private)

- (id)initWithEncryptedData:(NSData *)data;

- (NSData *)encryptWithAccount:(DCTAuthAccount *)account;
- (NSDictionary *)decryptWithAccount:(DCTAuthAccount *)account;

+ (void)removeAllKeychainItemsForAccount:(DCTAuthAccount *)account;

@end
