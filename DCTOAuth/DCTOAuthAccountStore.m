//
//  DCTOAuthAccountStore.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccountStore.h"
#import "_DCTOAuthAccount.h"

@implementation DCTOAuthAccountStore {
	__strong NSFileManager *_fileManager;
	__strong NSMutableArray *_accounts;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	_fileManager = [NSFileManager new];
	_accounts = [NSMutableArray new];
	
	[_fileManager createDirectoryAtURL:[self _storeURL] withIntermediateDirectories:YES attributes:nil error:nil];
	NSArray *identifiers = [_fileManager contentsOfDirectoryAtURL:[self _storeURL]
									   includingPropertiesForKeys:nil
														  options:NSDirectoryEnumerationSkipsHiddenFiles
															error:nil];
	
	[identifiers enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger i, BOOL *stop) {
		DCTOAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:[URL path]];
		[_accounts addObject:account];
	}];
	
	return self;
}

- (NSArray *)accounts {
	return [_accounts copy];
}

- (NSArray *)accountsWithType:(NSString *)type {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", type];
	return [_accounts filteredArrayUsingPredicate:predicate];
}

- (DCTOAuthAccount *)accountWithIdentifier:(NSString *)identifier {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
	NSArray *filteredAccounts = [_accounts filteredArrayUsingPredicate:predicate];
	return [filteredAccounts lastObject];
}

- (void)saveAccount:(DCTOAuthAccount *)account {
	NSURL *accountURL = [self _URLForAccountWithIdentifier:account.identifier];
	[NSKeyedArchiver archiveRootObject:account toFile:[accountURL path]];
	[_accounts addObject:account];
}

- (void)deleteAccount:(DCTOAuthAccount *)account {
	[account _willBeDeleted];
	[_accounts removeObject:account];
	NSURL *accountURL = [self _URLForAccountWithIdentifier:account.identifier];
	[_fileManager removeItemAtURL:accountURL error:NULL];
}

- (NSURL *)_URLForAccountWithIdentifier:(NSString *)identifier {
	return [[self _storeURL] URLByAppendingPathComponent:identifier];
}

- (NSURL *)_storeURL {
	NSURL *documentsURL = [[_fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	return [documentsURL URLByAppendingPathComponent:NSStringFromClass([self class])];
}

@end
