//
//  DCTAuthAccountStore.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"

extern NSString *const DCTAuthAccountStoreAccountsKeyPath;

/** The DCTAuthAccountStore class provides an interface for accessing, manipulating, and storing accounts. To create and retrieve accounts from the database, you must create an DCTAuthAccountStore object. Each DCTAuthAccount object belongs to a single DCTAuthAccountStore object.
 */
@interface DCTAuthAccountStore : NSObject

/// @name Getting an account store

+ (instancetype)defaultAccountStore;

+ (instancetype)accountStoreWithName:(NSString *)name;

+ (instancetype)accountStoreWithURL:(NSURL *)storeURL;

/// @name Getting accounts

/** The accounts managed by this account store. */
@property(nonatomic, readonly) NSArray *accounts;

/** Returns all accounts of the specified type.
 @param accountType The type of an account.
 @return All accounts that match accountType.
 */
- (NSArray *)accountsWithType:(NSString *)accountType;

/** Returns the account with the specified identifier. 
 @param identifier A unique identifier for an account.
 @return The account that matches the value specified in identifier.
 */
- (DCTAuthAccount *)accountWithIdentifier:(NSString *)identifier;

/// @name Managing accounts

/** Saves an account to the Accounts database.
 @param account The account to save.*/
- (void)saveAccount:(DCTAuthAccount *)account;

/** Deletes an account from the Accounts database.
 @param account The account to delete. */
- (void)deleteAccount:(DCTAuthAccount *)account;

@end
