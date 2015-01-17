//
//  DCTAuthAccountStore.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountStore+Private.h"
#import "DCTAuthAccountSubclass.h"
#import "DCTAuthKeychainAccess.h"
#import "DCTAuthAccount+Private.h"

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

NSString *const DCTAuthAccountStoreDidChangeNotification = @"DCTAuthAccountStoreDidChangeNotification";

static NSString *const DCTAuthAccountStoreDefaultStoreName = @"DCTDefaultAccountStore";
static NSTimeInterval const DCTAuthAccountStoreUpdateTimeInterval = 15.0f;

@interface DCTAuthAccountStore ()
@property (nonatomic, copy) NSString *accessGroup;
@property (nonatomic) BOOL synchronizable;
@property (nonatomic) NSTimer *updateTimer;
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

- (void)dealloc {
	self.updateTimer = nil;
}

- (instancetype)initWithName:(NSString *)name accessGroup:(NSString *)accessGroup synchronizable:(BOOL)synchronizable {
	self = [super init];
	if (!self) return nil;
	_name = [name copy];
	_accessGroup = [accessGroup copy];
	_synchronizable = synchronizable;
	[self updateAccountList];

	if (accessGroup.length == 0 && !synchronizable) return self;

#if TARGET_OS_IPHONE
	NSString *becomeActiveNotification = UIApplicationDidBecomeActiveNotification;
	NSString *resignActiveNotification = UIApplicationWillResignActiveNotification;
#else
	NSString *becomeActiveNotification = NSApplicationDidBecomeActiveNotification;
	NSString *resignActiveNotification = NSApplicationWillResignActiveNotification;
#endif

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:becomeActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:resignActiveNotification object:nil];

	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:DCTAuthAccountStoreUpdateTimeInterval target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];

	return self;
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
	[self updateAccountList];
	self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:DCTAuthAccountStoreUpdateTimeInterval target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
	self.updateTimer = nil;
}

- (void)setUpdateTimer:(NSTimer *)updateTimer {
	[_updateTimer invalidate];
	_updateTimer = updateTimer;
}

- (void)updateTimer:(NSTimer *)timer {
	[self updateAccountList];
}

- (void)updateAccountList {

	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self updateAccountList];
		});
		return;
	}

	NSString *name = self.name;
	NSString *accessGroup = self.accessGroup;
	BOOL synchronizable = self.synchronizable;

	NSMutableArray *accountIdentifiersToDelete = [[self.accounts valueForKey:DCTAuthAccountProperties.identifier] mutableCopy];

	NSArray *accountDatas = [DCTAuthKeychainAccess accountDataForStoreName:name accessGroup:accessGroup synchronizable:synchronizable];
	[accountDatas enumerateObjectsUsingBlock:^(NSData *data, NSUInteger i, BOOL *stop) {

		if (!data || [data isKindOfClass:[NSNull class]]) return;

		@try {
			DCTAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			account.accountStore = self;
			NSString *accountIdentifier = account.identifier;
			[self updateAccount:account];
			[accountIdentifiersToDelete removeObject:accountIdentifier];
		}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-exception-parameter"
		@catch (NSException *exception) {
			return;
		}
#pragma clang diagnostic pop

	}];

	for (NSString *accountIdentifier in accountIdentifiersToDelete) {
		DCTAuthAccount<DCTAuthAccountSubclass> *account = [self accountWithIdentifier:accountIdentifier];
		[self deleteAccount:account];
	}
}

- (void)setAccountPredicate:(NSPredicate *)accountPredicate {
	_accountPredicate = accountPredicate;
	[self updateAccountList];
}

- (NSArray *)accountsWithType:(NSString *)type {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountProperties.type, type];
	return [self.accounts filteredArrayUsingPredicate:predicate];
}

- (DCTAuthAccount<DCTAuthAccountSubclass> *)accountWithIdentifier:(NSString *)identifier {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountProperties.identifier, identifier];
	NSArray *filteredAccounts = [self.accounts filteredArrayUsingPredicate:predicate];
	return [filteredAccounts lastObject];
}

- (void)saveAccount:(DCTAuthAccount<DCTAuthAccountSubclass> *)account {

	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self saveAccount:account];
		});
		return;
	}

	NSString *identifier = account.identifier;
	NSString *storeName = self.name;
	account.saveUUID = [[NSUUID UUID] UUIDString];

	NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:account];
	[DCTAuthKeychainAccess addData:accountData
			   forAccountIdentifier:identifier
						  storeName:storeName
							   type:DCTAuthKeychainAccessTypeAccount
						accessGroup:self.accessGroup
					 synchronizable:self.synchronizable];

	[self removeAccount:account];
	[self insertAccount:account];

	// This will cause the account to call back to save its credential
	account.accountStore = self;
}

- (void)deleteAccount:(DCTAuthAccount<DCTAuthAccountSubclass> *)account {

	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self deleteAccount:account];
		});
		return;
	}

	NSString *identifier = account.identifier;
	NSString *storeName = self.name;
	[DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:DCTAuthKeychainAccessTypeAccount accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[DCTAuthKeychainAccess removeDataForAccountIdentifier:identifier storeName:storeName type:DCTAuthKeychainAccessTypeCredential accessGroup:self.accessGroup synchronizable:self.synchronizable];
	[self removeAccount:account];
}

- (void)removeAccount:(DCTAuthAccount *)account {
	NSMutableArray *array = [self mutableArrayValueForKey:DCTAuthAccountStoreProperties.accounts];
	[array removeObject:account];
	[[NSNotificationCenter defaultCenter] postNotificationName:DCTAuthAccountStoreDidChangeNotification object:self];
}

- (void)insertAccount:(DCTAuthAccount *)account {
	NSMutableArray *accounts = [self.accounts mutableCopy];
	[accounts addObject:account];
	[accounts sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:DCTAuthAccountProperties.accountDescription ascending:YES selector:@selector(localizedStandardCompare:)]]];
	NSUInteger index = [accounts indexOfObject:account];
	NSMutableArray *array = [self mutableArrayValueForKey:DCTAuthAccountStoreProperties.accounts];
	[array insertObject:account atIndex:index];
	[[NSNotificationCenter defaultCenter] postNotificationName:DCTAuthAccountStoreDidChangeNotification object:self];
}

- (void)updateAccount:(DCTAuthAccount *)account {

	DCTAuthAccount *currentAccount = [self accountWithIdentifier:account.identifier];

	// If no predicate is set, we show all the accounts we can
	BOOL shouldListAccount = self.accountPredicate ? [self.accountPredicate evaluateWithObject:account] : YES;
	if (!shouldListAccount) {

		if (currentAccount)
			[self removeAccount:currentAccount];

		return;
	}

	if ([currentAccount.saveUUID isEqualToString:account.saveUUID]) return;

	if (!currentAccount) {
		[self insertAccount:account];
		return;
	}

	NSMutableArray *accounts = [self.accounts mutableCopy];
	NSUInteger currentIndex = [accounts indexOfObject:currentAccount];
	[accounts removeObject:currentAccount];
	[accounts addObject:account];
	[accounts sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:DCTAuthAccountProperties.accountDescription ascending:YES selector:@selector(localizedStandardCompare:)]]];
	NSUInteger newIndex = [accounts indexOfObject:account];

	NSMutableArray *array = [self mutableArrayValueForKey:DCTAuthAccountStoreProperties.accounts];

	if (currentIndex == newIndex) {
		[array replaceObjectAtIndex:currentIndex withObject:account];
		return;
	}

	[self removeAccount:currentAccount];
	[self insertAccount:account];
}

@end

@implementation DCTAuthAccountStore (Private)

- (void)saveCredential:(id<DCTAuthAccountCredential>)credential forAccount:(DCTAuthAccount *)account {

	if (!credential) return;

	NSString *storeName = self.name;
	NSString *accessGroup = self.accessGroup;
	BOOL synchronizable = self.synchronizable;
	NSString *accountIdentifier = account.identifier;

	NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject:credential];
	[DCTAuthKeychainAccess addData:credentialData
			  forAccountIdentifier:accountIdentifier
						 storeName:storeName
							  type:DCTAuthKeychainAccessTypeCredential
					   accessGroup:accessGroup
					synchronizable:synchronizable];
}

- (id<DCTAuthAccountCredential>)retrieveCredentialForAccount:(DCTAuthAccount *)account {

	NSString *name = self.name;
	NSString *accessGroup = self.accessGroup;
	BOOL synchronizable = self.synchronizable;
	NSString *accountIdentifier = account.identifier;
	NSData *data = [DCTAuthKeychainAccess dataForAccountIdentifier:accountIdentifier
														 storeName:name
															  type:DCTAuthKeychainAccessTypeCredential
													   accessGroup:accessGroup
													synchronizable:synchronizable];
	if (!data) return nil;
	id<DCTAuthAccountCredential> credential = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (![credential conformsToProtocol:@protocol(DCTAuthAccountCredential)]) return nil;
	return credential;
}

@end



