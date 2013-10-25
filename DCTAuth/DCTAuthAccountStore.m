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

- (instancetype)init {
	return [[self class] accountStoreWithName:DCTAuthAccountStoreDefaultStoreName];
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

	NSString *name = self.name;
	NSString *accessGroup = self.accessGroup;
	BOOL synchronizable = self.synchronizable;

	NSMutableArray *accountIdentifiersToDelete = [[self.accounts valueForKey:DCTAuthAccountProperties.identifier] mutableCopy];

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

		[self updateAccount:account];
		[accountIdentifiersToDelete removeObject:accountIdentifier];
	}];

	for (NSString *accountIdentifier in accountIdentifiersToDelete) {
		DCTAuthAccount *account = [self accountWithIdentifier:accountIdentifier];
		[self deleteAccount:account];
	}
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
	account.saveUUID = [[NSUUID UUID] UUIDString];

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

	DCTAuthAccount *currentAccount = [self accountWithIdentifier:account.identifier];
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
