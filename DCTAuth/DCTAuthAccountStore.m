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

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import Cocoa;
#endif

const struct DCTAuthAccountStoreProperties DCTAuthAccountStoreProperties = {
	.name = @"name",
	.accessGroup = @"accessGroup",
	.synchronizable = @"synchronizable",
	.identifier = @"identifier",
	.accounts = @"accounts"
};

static NSString *const DCTAuthAccountStoreDefaultStoreName = @"DCTDefaultAccountStore";

@interface DCTAuthAccountStore ()
@property (nonatomic, copy) NSString *accessGroup;
@property (nonatomic) BOOL synchronizable;
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
	_name = [name copy];
	_accessGroup = [accessGroup copy];
	_synchronizable = synchronizable;
	[self updateAccountList:nil];

#if TARGET_OS_IPHONE
	NSString *notificationName = UIApplicationDidBecomeActiveNotification;
#else
	NSString *notificationName = NSApplicationDidBecomeActiveNotification;
#endif

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(updateAccountList:) name:notificationName object:nil];

	return self;
}

- (void)updateAccountList:(NSNotification *)notification {

	NSString *name = self.name;
	NSString *accessGroup = self.accessGroup;
	BOOL synchronizable = self.synchronizable;

	NSMutableArray *array = [self mutableArrayValueForKey:DCTAuthAccountStoreProperties.accounts];
	[array removeAllObjects];

	NSArray *accountDatas = [_DCTAuthKeychainAccess accountDataForStoreName:name accessGroup:accessGroup synchronizable:synchronizable];
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

	[self removeAccount:account];
	[self insertAccount:account];
}

- (void)deleteAccount:(DCTAuthAccount *)account {
	NSString *identifier = account.identifier;
	NSString *storeName = self.name;
	[_DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:_DCTAuthKeychainAccessTypeAccount accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[_DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:_DCTAuthKeychainAccessTypeCredential accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[self removeAccount:account];
}

- (void)removeAccount:(DCTAuthAccount *)account {
	if (![self.accounts containsObject:account]) return;
	NSMutableArray *array = [self mutableArrayValueForKey:DCTAuthAccountStoreProperties.accounts];
	[array removeObject:account];
}

- (void)insertAccount:(DCTAuthAccount *)account {
	NSMutableArray *accounts = [self.accounts mutableCopy];
	[accounts addObject:account];
	[accounts sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:DCTAuthAccountProperties.accountDescription ascending:YES selector:@selector(localizedStandardCompare:)]]];
	NSUInteger index = [accounts indexOfObject:account];
	NSMutableArray *array = [self mutableArrayValueForKey:DCTAuthAccountStoreProperties.accounts];
	[array insertObject:account atIndex:index];
}

- (void)updateAccount:(DCTAuthAccount *)account {
	[self removeAccount:account];
	[self insertAccount:account];
}

@end
