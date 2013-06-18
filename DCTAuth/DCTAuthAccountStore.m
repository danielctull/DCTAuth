//
//  DCTAuthAccountStore.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountStore.h"
#import "DCTAuthAccountSubclass.h"
#import "_DCTAuthKeychainAccess.h"
#import "_DCTAuthAccount.h"

static NSString *const DCTAuthAccountStoreDefaultStoreName = @"DCTDefaultAccountStore";
NSString *const DCTAuthAccountStoreAccountsKeyPath = @"accounts";

@interface DCTAuthAccountStore ()
@property (nonatomic, strong) NSMutableArray *mutableAccounts;
- (NSUInteger)countOfAccounts;
- (id)objectInAccountsAtIndex:(NSUInteger)index;
- (void)insertObject:(DCTAuthAccount *)object inAccountsAtIndex:(NSUInteger)index;
- (void)removeObjectFromAccountsAtIndex:(NSUInteger)index;
@end

@implementation DCTAuthAccountStore

+ (NSMutableDictionary *)accountStores {
	static NSMutableDictionary *accountStores = nil;
	static dispatch_once_t accountStoresToken;
	dispatch_once(&accountStoresToken, ^{
		accountStores = [NSMutableDictionary new];
	});
	return accountStores;
}

+ (instancetype)defaultAccountStore {
	return [self accountStoreWithName:DCTAuthAccountStoreDefaultStoreName];
}

+ (instancetype)accountStoreWithURL:(NSURL *)URL {
	return [self accountStoreWithName:[URL absoluteString]];
}

+ (instancetype)accountStoreWithName:(NSString *)name {
	NSMutableDictionary *accountStores = [self accountStores];
	DCTAuthAccountStore *accountStore = [accountStores objectForKey:name];
	if (!accountStore) {
		accountStore = [[self alloc] initWithName:name];
		[accountStores setObject:accountStore forKey:name];
	}
	return accountStore;
}

- (id)init {
	return [[self class] accountStoreWithName:DCTAuthAccountStoreDefaultStoreName];
}

- (id)initWithName:(NSString *)name {
	self = [super init];
	if (!self) return nil;
	_mutableAccounts = [NSMutableArray new];
	_name = [name copy];

	NSArray *accountDatas = [_DCTAuthKeychainAccess accountDataForStoreName:name];
	[accountDatas enumerateObjectsUsingBlock:^(NSData *data, NSUInteger i, BOOL *stop) {
		DCTAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		NSString *accountIdentifier = account.identifier;

		account.credentialFetcher = ^id<DCTAuthAccountCredential>() {
			NSData *data = [_DCTAuthKeychainAccess dataForAccountIdentifier:accountIdentifier
																  storeName:name
																	   type:_DCTAuthKeychainAccessTypeCredential];
			id<DCTAuthAccountCredential> credential = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			if (![credential conformsToProtocol:@protocol(DCTAuthAccountCredential)]) return nil;
			return credential;
		};
		[self insertObject:account inAccountsAtIndex:i];
	}];

	return self;
}

- (NSArray *)accountsWithType:(NSString *)type {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", type];
	return [self.accounts filteredArrayUsingPredicate:predicate];
}

- (DCTAuthAccount *)accountWithIdentifier:(NSString *)identifier {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
	NSArray *filteredAccounts = [self.accounts filteredArrayUsingPredicate:predicate];
	return [filteredAccounts lastObject];
}

- (void)saveAccount:(DCTAuthAccount *)account {
	NSString *identifier = account.identifier;
	NSString *storeName = self.name;

	NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:account];
	[_DCTAuthKeychainAccess addData:accountData
			   forAccountIdentifier:identifier
						  storeName:storeName
							   type:_DCTAuthKeychainAccessTypeAccount];

	NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject:account.credential];
	[_DCTAuthKeychainAccess addData:credentialData
			   forAccountIdentifier:identifier
						  storeName:storeName
							   type:_DCTAuthKeychainAccessTypeCredential];

	if ([self.mutableAccounts indexOfObject:account] != NSNotFound) return;
	[self insertObject:account inAccountsAtIndex:[self countOfAccounts]];
}

- (void)deleteAccount:(DCTAuthAccount *)account {
	NSString *identifier = account.identifier;
	NSString *storeName = self.name;
	[_DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:_DCTAuthKeychainAccessTypeAccount];
	[_DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:_DCTAuthKeychainAccessTypeCredential];
	[self removeObjectFromAccountsAtIndex:[self.mutableAccounts indexOfObject:account]];
}

#pragma mark - Accounts accessors

- (NSArray *)accounts {
	return [self.mutableAccounts copy];
}
- (NSUInteger)countOfAccounts {
	return [self.mutableAccounts count];
}
- (id)objectInAccountsAtIndex:(NSUInteger)index {
	return [self.mutableAccounts objectAtIndex:index];
}
- (void)insertObject:(DCTAuthAccount *)object inAccountsAtIndex:(NSUInteger)index {
	[self.mutableAccounts insertObject:object atIndex:index];
}
- (void)removeObjectFromAccountsAtIndex:(NSUInteger)index {
	[self.mutableAccounts removeObjectAtIndex:index];
}

@end
