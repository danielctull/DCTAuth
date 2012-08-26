//
//  DCTOAuthAccountStore.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccountStore.h"

@implementation DCTOAuthAccountStore {
	__strong NSFileManager *_fileManager;
	__strong NSMutableArray *_accounts;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	_fileManager = [NSFileManager new];
	_accounts = [NSMutableArray new];
	
	[_fileManager createDirectoryAtPath:[self _storePath] withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSArray *identifiers = [_fileManager contentsOfDirectoryAtPath:[self _storePath] error:nil];
	[identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger i, BOOL *stop) {
		NSString *accountPath = [self _pathForAccountWithIdentifier:identifier];
		DCTOAuthAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:accountPath];
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
	NSString *accountPath = [self _pathForAccountWithIdentifier:account.identifier];
	[NSKeyedArchiver archiveRootObject:account toFile:accountPath];
	[_accounts addObject:account];
}

- (void)deleteAccount:(DCTOAuthAccount *)account {
	NSString *accountPath = [self _pathForAccountWithIdentifier:account.identifier];
	[_accounts removeObject:account];
	[_fileManager removeItemAtPath:accountPath error:NULL];
}

- (NSString *)_pathForAccountWithIdentifier:(NSString *)identifier {
	return [[self _storePath] stringByAppendingPathComponent:identifier];
}

- (NSString *)_storePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:NSStringFromClass([self class])];
}

@end
