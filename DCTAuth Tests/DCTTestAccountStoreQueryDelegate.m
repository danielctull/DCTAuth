//
//  DCTTestAccountStoreQueryDelegate.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTTestAccountStoreQueryDelegate.h"
#import "DCTTestAccountStoreQueryDelegateEvent.h"

@interface DCTTestAccountStoreQueryDelegate ()
@property (nonatomic) NSMutableArray *internalEvents;
@end

@implementation DCTTestAccountStoreQueryDelegate

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];
	if (!self) return nil;
	_internalEvents = [NSMutableArray new];
	return self;
}

#pragma mark - DCTTestAccountStoreQueryDelegate

- (NSArray *)events {
	return [self.internalEvents copy];
}

#pragma mark - DCTAuthAccountStoreQueryDelegate

- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didInsertAccount:(DCTAuthAccount *)account atIndex:(NSUInteger)index {
	DCTTestAccountStoreQueryDelegateEvent *event = [[DCTTestAccountStoreQueryDelegateEvent alloc] initWithAccountStoreQuery:query
																													account:account
																													   type:DCTTestAccountStoreQueryDelegateEventTypeInsert
																												  fromIndex:index
																													toIndex:index];
	[self.internalEvents addObject:event];
}

- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didRemoveAccount:(DCTAuthAccount *)account fromIndex:(NSUInteger)index {
	DCTTestAccountStoreQueryDelegateEvent *event = [[DCTTestAccountStoreQueryDelegateEvent alloc] initWithAccountStoreQuery:query
																													account:account
																													   type:DCTTestAccountStoreQueryDelegateEventTypeRemove
																												  fromIndex:index
																													toIndex:index];
	[self.internalEvents addObject:event];
}

- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didMoveAccount:(DCTAuthAccount *)account fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
	DCTTestAccountStoreQueryDelegateEvent *event = [[DCTTestAccountStoreQueryDelegateEvent alloc] initWithAccountStoreQuery:query
																													account:account
																													   type:DCTTestAccountStoreQueryDelegateEventTypeMove
																												  fromIndex:fromIndex
																													toIndex:toIndex];
	[self.internalEvents addObject:event];
}

- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didUpdateAccount:(DCTAuthAccount *)account atIndex:(NSUInteger)index {
	DCTTestAccountStoreQueryDelegateEvent *event = [[DCTTestAccountStoreQueryDelegateEvent alloc] initWithAccountStoreQuery:query
																													account:account
																													   type:DCTTestAccountStoreQueryDelegateEventTypeUpdate
																												  fromIndex:index
																													toIndex:index];
	[self.internalEvents addObject:event];
}

@end
