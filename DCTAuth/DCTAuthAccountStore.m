//
//  DCTAuthAccountStore.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountStore.h"
#import "DCTAuthAccountSubclass.h"

NSString *const DCTAuthAccountStoreDefaultStoreName = @"DCTDefaultAccountStore";

@interface DCTAuthAccountStore ()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableArray *mutableAccounts;
@property (nonatomic, strong) NSURL *URL;
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

+ (instancetype)accountStoreWithName:(NSString *)name {
	return [self accountStoreWithURL:[[self storeDirectoryURL] URLByAppendingPathComponent:name]];
}

+ (instancetype)accountStoreWithURL:(NSURL *)URL {
	NSMutableDictionary *accountStores = [self accountStores];
	DCTAuthAccountStore *accountStore = [accountStores objectForKey:URL];
	if (!accountStore) {
		accountStore = [[self alloc] initWithURL:URL];
		[accountStores setObject:accountStore forKey:URL];
	}
	return accountStore;
}

- (id)init {
	return [self initWithURL:[[[self class] storeDirectoryURL] URLByAppendingPathComponent:DCTAuthAccountStoreDefaultStoreName]];
}

- (id)initWithURL:(NSURL *)URL {
	self = [super init];
	if (!self) return nil;
	_fileManager = [NSFileManager new];
	_mutableAccounts = [NSMutableArray new];
	_URL = [URL copy];

	[_fileManager createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:nil];
	NSArray *identifiers = [_fileManager contentsOfDirectoryAtURL:URL
									   includingPropertiesForKeys:nil
														  options:NSDirectoryEnumerationSkipsHiddenFiles
															error:nil];
	
	[identifiers enumerateObjectsUsingBlock:^(NSURL *accountURL, NSUInteger i, BOOL *stop) {
		DCTAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:[accountURL path]];
		[self.mutableAccounts addObject:account];
	}];
	
	return self;
}

- (NSArray *)accounts {
	return [self.mutableAccounts copy];
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
	NSURL *accountURL = [self _URLForAccountWithIdentifier:account.identifier];
	[NSKeyedArchiver archiveRootObject:account toFile:[accountURL path]];
	[self.mutableAccounts addObject:account];
}

- (void)deleteAccount:(DCTAuthAccount *)account {
	[account prepareForDeletion];
	[self.mutableAccounts removeObject:account];
	NSURL *accountURL = [self _URLForAccountWithIdentifier:account.identifier];
	[self.fileManager removeItemAtURL:accountURL error:NULL];
}

- (NSURL *)_URLForAccountWithIdentifier:(NSString *)identifier {
	return [self.URL URLByAppendingPathComponent:identifier];
}

+ (NSURL *)storeDirectoryURL {
	NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	return [documentsURL URLByAppendingPathComponent:NSStringFromClass([self class])];
}

@end
