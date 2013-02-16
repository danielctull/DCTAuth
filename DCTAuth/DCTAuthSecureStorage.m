//
//  DCTAuthSecureStorage.m
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthSecureStorage.h"
#import "_DCTAuthPasswordProvider.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

NSString *const DCTAuthSecureStorageKeys = @"DCTAuthSecureStorageKeys";

@interface DCTAuthSecureStorage ()
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, copy) NSData *encryptedData;
@end

@implementation DCTAuthSecureStorage

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];
	if (!self) return nil;
	_dictionary = [dictionary copy];
	return self;
}

- (id)initWithEncryptedData:(NSData *)data {
	self = [self init];
	if (!self) return nil;
	_encryptedData = [data copy];
	return self;
}

- (NSData *)encryptWithAccount:(DCTAuthAccount *)account {
	NSMutableDictionary *encryptedDictionary = [NSMutableDictionary new];
	[encryptedDictionary setObject:self.dictionary.allKeys forKey:DCTAuthSecureStorageKeys];
	[self.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[[self class] setSecureValue:object forKey:key account:account];
	}];
	return [NSKeyedArchiver archivedDataWithRootObject:encryptedDictionary];
}

- (NSDictionary *)decryptWithAccount:(DCTAuthAccount *)account {
	NSDictionary *encryptedDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:self.encryptedData];
	NSArray *keys = [encryptedDictionary objectForKey:DCTAuthSecureStorageKeys];
	NSMutableDictionary *decryptedDictionary = [[NSMutableDictionary alloc] initWithCapacity:encryptedDictionary.count];
	[keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger i, BOOL *stop) {
		NSString *value = [[self class] secureValueForKey:key account:account];
		[decryptedDictionary setObject:value forKey:key];
	}];
	return [decryptedDictionary copy];
}

+ (void)removeAllKeychainItemsForAccount:(DCTAuthAccount *)account {
	[self removeSecureValueForKey:nil account:account];
}

#pragma mark - Encryption

- (NSData *)decryptData:(NSData *)data withPassword:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)

	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

	NSUInteger dataLength = [data length];

	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);

	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [data bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);

	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}

	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)encryptData:(NSData *)data withPassword:(NSString *)key {
	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)

	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

	NSUInteger dataLength = [data length];

	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);

	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [data bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}

	free(buffer); //free the buffer;
	return nil;
}

#pragma mark - Keychain

+ (void)setSecureValue:(NSString *)value forKey:(NSString *)key account:(DCTAuthAccount *)account {
	if (!value) return;
	if (!key) return;

	[self removeSecureValueForKey:key account:account];

	NSMutableDictionary *query = [self queryForKey:key account:account];
	[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
#ifdef TARGET_OS_IPHONE
	[query setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
#endif
	SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

+ (NSString *)secureValueForKey:(NSString *)key account:(DCTAuthAccount *)account {
	if (!key) return nil;

	NSMutableDictionary *query = [self queryForKey:key account:account];
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	CFTypeRef result = NULL;
	SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	if (!result) return nil;
	return [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
}

+ (void)removeSecureValueForKey:(NSString *)key account:(DCTAuthAccount *)account {
	NSMutableDictionary *query = [self queryForKey:key account:account];
    SecItemDelete((__bridge CFDictionaryRef)query);
}

+ (NSMutableDictionary *)queryForKey:(NSString *)key account:(DCTAuthAccount *)account {
	NSMutableDictionary *query = [NSMutableDictionary new];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:[NSString stringWithFormat:@"DCTAuth:%@", account.identifier] forKey:(__bridge id)kSecAttrService];
	if (key) [query setObject:key forKey:(__bridge id)kSecAttrAccount];
	return query;
}

@end
