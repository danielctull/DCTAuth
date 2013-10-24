//
//  _DCTAuthKeychainAccess.h
//  DCTAuth
//
//  Created by Daniel Tull on 16/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountStore.h"

typedef NS_ENUM(NSInteger, _DCTAuthKeychainAccessType) {
	_DCTAuthKeychainAccessTypeAccount,
	_DCTAuthKeychainAccessTypeCredential
};

@interface _DCTAuthKeychainAccess : NSObject

+ (NSArray *)accountDataForStoreName:(NSString *)storeName
						 accessGroup:(NSString *)accessGroup;

+ (void)removeDataForAccountIdentifier:(NSString *)accountIdentifier
							 storeName:(NSString *)storeName
								  type:(_DCTAuthKeychainAccessType)type
						   accessGroup:(NSString *)accessGroup;

+ (void)addData:(NSData *)data
forAccountIdentifier:(NSString *)accountIdentifier
	  storeName:(NSString *)storeName
		   type:(_DCTAuthKeychainAccessType)type
	accessGroup:(NSString *)accessGroup;

+ (NSData *)dataForAccountIdentifier:(NSString *)accountIdentifier
						   storeName:(NSString *)storeName
								type:(_DCTAuthKeychainAccessType)type
						 accessGroup:(NSString *)accessGroup;

@end
