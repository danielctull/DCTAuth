//
//  DCTAuthAccountStoreQuery.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountStoreQuery.h"
#import "DCTAuthAccountStore.h"

@implementation DCTAuthAccountStoreQuery

- (instancetype)initWithAccountStore:(DCTAuthAccountStore *)accountStore
						   predciate:(NSPredicate *)predicate
					 sortDescriptors:(NSArray *)sortDescriptors {

	NSParameterAssert(accountStore);
	NSParameterAssert(sortDescriptors);

	self = [super init];
	if (!self) return nil;

	_accountStore = accountStore;
	_predicate = predicate;
	_sortDescriptors = sortDescriptors;
	_accounts = [self accountsFromAccountStore:accountStore predciate:predicate sortDescriptors:sortDescriptors];

	return self;
}

#pragma mark - Helper methods

- (NSArray *)accountsFromAccountStore:(DCTAuthAccountStore *)objectStore
							predciate:(NSPredicate *)predicate
					  sortDescriptors:(NSArray *)sortDescriptors {

	NSArray *accounts = objectStore.accounts;

	if (!accounts) {
		return @[];
	}

	if (predicate) {
		accounts = [accounts filteredArrayUsingPredicate:predicate];
	}

	return [accounts sortedArrayUsingDescriptors:sortDescriptors];
}

@end
