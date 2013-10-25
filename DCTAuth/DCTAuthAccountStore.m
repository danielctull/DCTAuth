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

const struct DCTAuthAccountStoreProperties DCTAuthAccountStoreProperties = {
	.name = @"name",
	.accessGroup = @"accessGroup",
	.synchronizable = @"synchronizable",
	.identifier = @"identifier",
	.accounts = @"accounts"
};

static NSString *const DCTAuthAccountStoreDefaultStoreName = @"DCTDefaultAccountStore";

@interface DCTAuthAccountStore ()
@property (nonatomic, strong) NSMutableArray *mutableAccounts;
@property (nonatomic, copy) NSString *accessGroup;
@property (nonatomic) BOOL synchronizable;
- (NSUInteger)countOfAccounts;
- (id)objectInAccountsAtIndex:(NSUInteger)index;
- (void)insertObject:(DCTAuthAccount *)object inAccountsAtIndex:(NSUInteger)index;
- (void)removeObjectFromAccountsAtIndex:(NSUInteger)index;
@end

@implementation DCTAuthAccountStore

+ (NSMutableArray *)accountStores {
	static NSMutableArray *accountStores = nil;
	static dispatch_once_t accountStoresToken;
	dispatch_once(&accountStoresToken, ^{
		accountStores = [NSMutableArray new];
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
	return [self accountStoreWithName:name accessGroup:nil synchronizable:NO];
}

+ (instancetype)accountStoreWithName:(NSString *)name accessGroup:(NSString *)accessGroup synchronizable:(BOOL)synchronizable {

	NSMutableArray *accountStores = [self accountStores];

	NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountStoreProperties.name, name];
	NSPredicate *accessGroupPredicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountStoreProperties.accessGroup, accessGroup];
	NSPredicate *synchronizablePredicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountStoreProperties.synchronizable, @(synchronizable)];
	NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[namePredicate, accessGroupPredicate, synchronizablePredicate]];
	NSArray *filteredArray = [accountStores filteredArrayUsingPredicate:predicate];

	DCTAuthAccountStore *accountStore = [filteredArray firstObject];
	if (!accountStore) {
		accountStore = [[self alloc] initWithName:name accessGroup:accessGroup synchronizable:synchronizable];
		[accountStores addObject:accountStore];
	}

	return accountStore;
}

- (instancetype)init {
	return [[self class] accountStoreWithName:DCTAuthAccountStoreDefaultStoreName];
}

- (instancetype)initWithName:(NSString *)name accessGroup:(NSString *)accessGroup synchronizable:(BOOL)synchronizable {
	self = [super init];
	if (!self) return nil;
	_mutableAccounts = [NSMutableArray new];
	_name = [name copy];
	_accessGroup = [accessGroup copy];
	_synchronizable = synchronizable;
	
	NSArray *accountDatas = [_DCTAuthKeychainAccess accountDataForStoreName:name accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[accountDatas enumerateObjectsUsingBlock:^(NSData *data, NSUInteger i, BOOL *stop) {
		if (!data || [data isKindOfClass:[NSNull class]]) return;
		DCTAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		NSString *accountIdentifier = account.identifier;

		account.credentialFetcher = ^id<DCTAuthAccountCredential>() {
			NSData *data = [_DCTAuthKeychainAccess dataForAccountIdentifier:accountIdentifier
																  storeName:name
																	   type:_DCTAuthKeychainAccessTypeCredential
																accessGroup:accessGroup
															 synchronizable:synchronizable];
			if (!data) return nil;
			id<DCTAuthAccountCredential> credential = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			if (![credential conformsToProtocol:@protocol(DCTAuthAccountCredential)]) return nil;
			return credential;
		};
		[self insertAccount:account];
	}];

	return self;
}

- (NSArray *)accountsWithType:(NSString *)type {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountProperties.type, type];
	return [self.accounts filteredArrayUsingPredicate:predicate];
}

- (DCTAuthAccount *)accountWithIdentifier:(NSString *)identifier {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountProperties.identifier, identifier];
	NSArray *filteredAccounts = [self.accounts filteredArrayUsingPredicate:predicate];
	return [filteredAccounts lastObject];
}

- (void)saveAccount:(DCTAuthAccount *)account {

	NSUInteger accountIndex = [self.mutableAccounts indexOfObject:account];
	BOOL exists = accountIndex != NSNotFound;

	if (exists)
		[self willChange:NSKeyValueChangeReplacement
		 valuesAtIndexes:[NSIndexSet indexSetWithIndex:accountIndex]
				  forKey:DCTAuthAccountStoreProperties.accounts];


	NSString *identifier = account.identifier;
	NSString *storeName = self.name;

	NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:account];
	[_DCTAuthKeychainAccess addData:accountData
			   forAccountIdentifier:identifier
						  storeName:storeName
							   type:_DCTAuthKeychainAccessTypeAccount
						accessGroup:self.accessGroup
					 synchronizable:self.synchronizable];

	NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject:account.credential];
	[_DCTAuthKeychainAccess addData:credentialData
			   forAccountIdentifier:identifier
						  storeName:storeName
							   type:_DCTAuthKeychainAccessTypeCredential
						accessGroup:self.accessGroup
					 synchronizable:self.synchronizable];

	if (exists)
		[self didChange:NSKeyValueChangeReplacement
		valuesAtIndexes:[NSIndexSet indexSetWithIndex:accountIndex]
				 forKey:DCTAuthAccountStoreProperties.accounts];
	else
		[self insertAccount:account];
}

- (void)deleteAccount:(DCTAuthAccount *)account {
	NSString *identifier = account.identifier;
	NSString *storeName = self.name;
	[_DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:_DCTAuthKeychainAccessTypeAccount accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[_DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:_DCTAuthKeychainAccessTypeCredential accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[self removeObjectFromAccountsAtIndex:[self.mutableAccounts indexOfObject:account]];
}

- (void)insertAccount:(DCTAuthAccount *)account {
	NSMutableArray *accounts = [self.mutableAccounts mutableCopy];
	[accounts addObject:account];
	[accounts sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:DCTAuthAccountProperties.accountDescription ascending:YES]]];
	NSUInteger index = [accounts indexOfObject:account];
	[self insertObject:account inAccountsAtIndex:index];
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
