//
//  _DCTAuthSecureStorage.h
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthSecureStorage.h"

@interface DCTAuthSecureStorage (Private)

- (id)initWithEncryptedData:(NSData *)encryptedData;
@property (nonatomic, readonly) NSData *encryptedData;

- (void)encryptWithAccount:(DCTAuthAccount *)account;
- (void)decryptWithAccount:(DCTAuthAccount *)account;

+ (void)removeAllKeychainItemsForAccount:(DCTAuthAccount *)account;

@end
