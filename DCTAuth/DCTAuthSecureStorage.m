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

NSString *const DCTAuthSecureStorageKey = @"DCTAuthSecureStorage";
NSString *const DCTAuthSecureAccountKey = @"DCTAuthSecureAccount";

@interface DCTAuthSecureStorage ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation DCTAuthSecureStorage

- (id)initWithAccount:(DCTAuthAccount *)account {
	self = [self init];
	if (!self) return nil;
	_account = account;
	_dictionary = [NSMutableDictionary new];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (!self) return nil;

	DCTAuthAccount *account = [coder decodeObjectForKey:DCTAuthSecureAccountKey];
	_account = account;

	[[_DCTAuthPasswordProvider sharedPasswordProvider] passwordForAccount:account handler:^(NSString *password) {
		NSMutableDictionary *encryptedDictionary = [coder decodeObjectForKey:DCTAuthSecureStorageKey];
		self.dictionary = [[NSMutableDictionary alloc] initWithCapacity:encryptedDictionary.count];
		[encryptedDictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSData *encryptedData, BOOL *stop) {
			NSData *data = [self decryptData:encryptedData withPassword:password];
			id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			[self.dictionary setObject:object forKey:key];
		}];
	}];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	DCTAuthAccount *account = self.account;
	[[_DCTAuthPasswordProvider sharedPasswordProvider] passwordForAccount:account handler:^(NSString *password) {
		NSMutableDictionary *encryptedDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.dictionary.count];
		[self.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
			NSData *encryptedData = [self encryptData:data withPassword:password];
			[encryptedDictionary setObject:encryptedData forKey:key];
		}];
		[coder encodeObject:encryptedDictionary forKey:DCTAuthSecureStorageKey];
	}];
	[coder encodeObject:account forKey:DCTAuthSecureAccountKey];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
	[self.dictionary setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
	return [self.dictionary objectForKey:key];
}

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


@end
