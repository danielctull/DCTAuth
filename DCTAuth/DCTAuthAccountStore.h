//
//  DCTAuthAccountStore.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"

extern NSString *const DCTAuthAccountStoreAccountsKeyPath;

/** The DCTAuthAccountStore class provides an interface for accessing, manipulating, and storing accounts. To create and retrieve accounts from the database, you must create an DCTAuthAccountStore object. Each DCTAuthAccount object belongs to a single DCTAuthAccountStore object.
 */
@interface DCTAuthAccountStore : NSObject

/// @name Getting an account store

/** Retrieve the "default" global store. */
+ (instancetype)defaultAccountStore;

/** Get a store in the default directory with a given name.
 @param name The name of the store to retrieve.
 @return The store with the given name.
 */
+ (instancetype)accountStoreWithName:(NSString *)name;

+ (instancetype)accountStoreWithName:(NSString *)name accessGroup:(NSString *)accessGroup synchronizable:(BOOL)synchronizable;

/** Get a store at a given URL.
 @param storeURL A URL for a location on disk.
 @return The store at the give URL on disk.
 */
+ (instancetype)accountStoreWithURL:(NSURL *)storeURL __attribute__((deprecated));

@property (nonatomic, readonly) NSString *name;

/// @name Getting accounts

/** The accounts managed by this account store. */
@property(nonatomic, readonly) NSArray *accounts;

/** Returns all accounts of the specified type.
 @param accountType The type of an account.
 @return All accounts that match accountType.
 @see [DCTAuthAccount type]
 */
- (NSArray *)accountsWithType:(NSString *)accountType;

/** Returns the account with the specified identifier. 
 @param identifier A unique identifier for an account.
 @return The account that matches the value specified in identifier.
 */
- (DCTAuthAccount *)accountWithIdentifier:(NSString *)identifier;

/// @name Managing accounts

/** Saves an account to the Accounts database.
 @param account The account to save. Must not be nil.
 */
- (void)saveAccount:(DCTAuthAccount *)account __attribute__((nonnull(1))) __attribute((objc_requires_super));

/** Deletes an account from the Accounts database.
 @param account The account to delete. Must not be nil.
 */
- (void)deleteAccount:(DCTAuthAccount *)account __attribute__((nonnull(1))) __attribute((objc_requires_super));

@end
