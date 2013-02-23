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
NSString *const DCTAuthAccountStoreAccountsKeyPath = @"accounts";

@interface DCTAuthAccountStore ()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableArray *mutableAccounts;
@property (nonatomic, strong) NSURL *URL;
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
		account.credential = [self credentialForIdentifier:account.identifier];
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
	NSURL *accountURL = [self _URLForAccountWithIdentifier:identifier];
	[NSKeyedArchiver archiveRootObject:account toFile:[accountURL path]];
	[self setCredential:account.credential forIdentifier:identifier];
	if ([self.mutableAccounts indexOfObject:account] != NSNotFound) return;
	[self insertObject:account inAccountsAtIndex:[self countOfAccounts]];
}

- (void)deleteAccount:(DCTAuthAccount *)account {
	NSString *identifier = account.identifier;
	NSURL *accountURL = [self _URLForAccountWithIdentifier:identifier];
	if (![self.fileManager removeItemAtURL:accountURL error:NULL]) return;
	[self removeCredentialForIdentifier:identifier];
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

#pragma mark - Private

- (NSURL *)_URLForAccountWithIdentifier:(NSString *)identifier {
	return [self.URL URLByAppendingPathComponent:identifier];
}

+ (NSURL *)storeDirectoryURL {
	NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	return [documentsURL URLByAppendingPathComponent:NSStringFromClass([self class])];
}

- (void)setCredential:(id<DCTAuthAccountCredential>)credential
		forIdentifier:(NSString *)identifier {
	if (!credential) return;
	if (!identifier) return;
	[self removeCredentialForIdentifier:identifier];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:credential];
	NSMutableDictionary *query = [self queryForIdentifier:identifier];
	[query setObject:data forKey:(__bridge id)kSecValueData];
	SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

- (id<DCTAuthAccountCredential>)credentialForIdentifier:(NSString *)identifier {
	if (!identifier) return nil;
	NSMutableDictionary *query = [self queryForIdentifier:identifier];
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	CFTypeRef result = NULL;
	SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	if (!result) return nil;
	id credential = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)result];
	if (![credential conformsToProtocol:@protocol(DCTAuthAccountCredential)]) return nil;
	return credential;
}

- (void)removeCredentialForIdentifier:(NSString *)identifier {
	NSMutableDictionary *query = [self queryForIdentifier:identifier];
    SecItemDelete((__bridge CFDictionaryRef)query);
}

- (NSMutableDictionary *)queryForIdentifier:(NSString *)identifier {
	NSMutableDictionary *query = [NSMutableDictionary new];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:@"DCTAuth" forKey:(__bridge id)kSecAttrService];
	if (identifier) [query setObject:identifier forKey:(__bridge id)kSecAttrAccount];
	return query;
}

@end
