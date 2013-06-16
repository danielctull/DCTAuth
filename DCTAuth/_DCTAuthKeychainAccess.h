//
//  _DCTAuthKeychainAccess.h
//  DCTAuth
//
//  Created by Daniel Tull on 16/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccountStore.h"

typedef NS_ENUM(NSInteger, _DCTAuthKeychainAccessType) {
	_DCTAuthKeychainAccessTypeAccount,
	_DCTAuthKeychainAccessTypeCredential
};

@interface _DCTAuthKeychainAccess : NSObject

+ (NSArray *)accountDataForStoreName:(NSString *)storeName;

+ (void)removeDataForAccountIdentifier:(NSString *)accountIdentifier
							 storeName:(NSString *)storeName
								  type:(_DCTAuthKeychainAccessType)type;

+ (void)addData:(NSData *)data
forAccountIdentifier:(NSString *)accountIdentifier
	  storeName:(NSString *)storeName
		   type:(_DCTAuthKeychainAccessType)type;

+ (NSData *)dataForAccountIdentifier:(NSString *)accountIdentifier
						   storeName:(NSString *)storeName
								type:(_DCTAuthKeychainAccessType)type;
@end
