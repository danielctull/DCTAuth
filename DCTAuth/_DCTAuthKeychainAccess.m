//
//  _DCTAuthKeychainAccess.m
//  DCTAuth
//
//  Created by Daniel Tull on 16/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTAuthKeychainAccess.h"
@import Security;

@implementation _DCTAuthKeychainAccess

+ (NSArray *)accountDataForStoreName:(NSString *)storeName accessGroup:(NSString *)accessGroup {
	
	NSMutableDictionary *query = [self queryForAccountIdentifier:nil storeName:storeName type:_DCTAuthKeychainAccessTypeAccount accessGroup:accessGroup];
	[query addEntriesFromDictionary:@{
		(__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue,
		(__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll
	}];

	CFTypeRef result = NULL;
	SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	return (__bridge_transfer NSArray *)result;
}

+ (void)removeDataForAccountIdentifier:(NSString *)accountIdentifier
							 storeName:(NSString *)storeName
								  type:(_DCTAuthKeychainAccessType)type
						   accessGroup:(NSString *)accessGroup {

	NSMutableDictionary *query = [self queryForAccountIdentifier:accountIdentifier storeName:storeName type:type accessGroup:accessGroup];
	SecItemDelete((__bridge CFDictionaryRef)query);
}

+ (void)addData:(NSData *)data
forAccountIdentifier:(NSString *)accountIdentifier
	  storeName:(NSString *)storeName
		   type:(_DCTAuthKeychainAccessType)type
	accessGroup:(NSString *)accessGroup {

	NSMutableDictionary *query = [self queryForAccountIdentifier:accountIdentifier storeName:storeName type:type accessGroup:accessGroup];
	SecItemDelete((__bridge CFDictionaryRef)query);
	query[(__bridge id)kSecValueData] = data;
	SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

+ (NSData *)dataForAccountIdentifier:(NSString *)accountIdentifier
						   storeName:(NSString *)storeName
								type:(_DCTAuthKeychainAccessType)type
						 accessGroup:(NSString *)accessGroup {

	NSMutableDictionary *query = [self queryForAccountIdentifier:accountIdentifier
													   storeName:storeName
															type:type
													 accessGroup:accessGroup];
	query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
	query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

	CFTypeRef result = NULL;
	SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

	if (!result) return nil;
	NSData *data = (__bridge_transfer NSData *)result;
	if (![data isKindOfClass:[NSData class]]) return nil;
	return data;
}

+ (NSMutableDictionary *)queryForAccountIdentifier:(NSString *)accountIdentifier storeName:(NSString *)storeName type:(_DCTAuthKeychainAccessType)type accessGroup:(NSString *)accessGroup {

	NSAssert(storeName, @"storeName is required");

	NSString *service = [NSString stringWithFormat:@"DCTAuth 3.%@.%@", storeName, @(type)];
	NSMutableDictionary *query = [NSMutableDictionary new];
	query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
	query[(__bridge id)kSecAttrService] = service;
	if (accessGroup.length > 0) query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
	if (accountIdentifier.length > 0) query[(__bridge id)kSecAttrAccount] = accountIdentifier;
	return query;
}

@end
