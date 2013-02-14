//
//  DCTAuthAccountStore.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountStore.h"
#import "DCTAuthAccountSubclass.h"

@interface DCTAuthAccountStore ()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableArray *mutableAccounts;
@end

@implementation DCTAuthAccountStore

- (id)init {
	self = [super init];
	if (!self) return nil;
	_fileManager = [NSFileManager new];
	_mutableAccounts = [NSMutableArray new];
	
	[_fileManager createDirectoryAtURL:[self _storeURL] withIntermediateDirectories:YES attributes:nil error:nil];
	NSArray *identifiers = [_fileManager contentsOfDirectoryAtURL:[self _storeURL]
									   includingPropertiesForKeys:nil
														  options:NSDirectoryEnumerationSkipsHiddenFiles
															error:nil];
	
	[identifiers enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger i, BOOL *stop) {
		DCTAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:[URL path]];
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
	NSParameterAssert(account);
	NSURL *accountURL = [self _URLForAccountWithIdentifier:account.identifier];
	[NSKeyedArchiver archiveRootObject:account toFile:[accountURL path]];
	[self.mutableAccounts addObject:account];
}

- (void)deleteAccount:(DCTAuthAccount *)account {
	NSParameterAssert(account);
	[account prepareForDeletion];
	[self.mutableAccounts removeObject:account];
	NSURL *accountURL = [self _URLForAccountWithIdentifier:account.identifier];
	[self.fileManager removeItemAtURL:accountURL error:NULL];
}

- (NSURL *)_URLForAccountWithIdentifier:(NSString *)identifier {
	return [[self _storeURL] URLByAppendingPathComponent:identifier];
}

- (NSURL *)_storeURL {
	NSURL *documentsURL = [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	return [documentsURL URLByAppendingPathComponent:NSStringFromClass([self class])];
}

@end
