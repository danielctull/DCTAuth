//
//  DCTAuthAccountStoreQueryDelegateTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import XCTest;
@import DCTAuth;
#import "DCTTestAccount.h"
#import "DCTTestAccountStoreQueryDelegate.h"
#import "DCTTestAccountStoreQueryDelegateEvent.h"

@interface DCTAuthAccountStoreQueryDelegateTests : XCTestCase
@property (nonatomic) DCTAuthAccountStore *store;
@property (nonatomic) DCTAuthAccountStoreQuery *query;
@property (nonatomic) DCTTestAccountStoreQueryDelegate *delegate;
@end

@implementation DCTAuthAccountStoreQueryDelegateTests

- (void)setUp {
	[super setUp];
	self.store = [DCTAuthAccountStore accountStoreWithName:[[NSUUID UUID] UUIDString]];
	self.delegate = [DCTTestAccountStoreQueryDelegate new];
	NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:DCTAuthAccountProperties.accountDescription ascending:YES]];
	self.query = [[DCTAuthAccountStoreQuery alloc] initWithAccountStore:self.store predciate:nil sortDescriptors:sortDescriptors];
	self.query.delegate = self.delegate;
}

- (void)tearDown {
	self.store = nil;
	self.query = nil;
	self.delegate = nil;
	[super tearDown];
}

- (void)testInsert {

	DCTTestAccount *account = [DCTTestAccount new];
	[self.store saveAccount:account];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)1, @"Delegate should have received 1 callback.");
	DCTTestAccountStoreQueryDelegateEvent *insert = self.delegate.events[0];
	XCTAssertEqualObjects(insert.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(insert.account, account, @"Account should be the account.");
	XCTAssertEqual(insert.type, DCTTestAccountStoreQueryDelegateEventTypeInsert, @"Should receive insert callback.");
	XCTAssertEqual(insert.fromIndex, (NSUInteger)0, @"Should be inserted at index 0.");
	XCTAssertEqual(insert.toIndex, (NSUInteger)0, @"Should be inserted at index 0.");
}

- (void)testRemove {

	DCTTestAccount *account = [DCTTestAccount new];
	[self.store saveAccount:account];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)1, @"Delegate should have received 1 callback.");
	DCTTestAccountStoreQueryDelegateEvent *insert = self.delegate.events[0];
	XCTAssertEqualObjects(insert.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(insert.account, account, @"Account should be the account.");
	XCTAssertEqual(insert.type, DCTTestAccountStoreQueryDelegateEventTypeInsert, @"Should receive insert callback.");
	XCTAssertEqual(insert.fromIndex, (NSUInteger)0, @"Should be inserted at index 0.");
	XCTAssertEqual(insert.toIndex, (NSUInteger)0, @"Should be inserted at index 0.");

	[self.store deleteAccount:account];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)2, @"Delegate should have received 2 callbacks.");
	DCTTestAccountStoreQueryDelegateEvent *delete = self.delegate.events[1];
	XCTAssertEqualObjects(delete.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(delete.account, account, @"Account should be the account.");
	XCTAssertEqual(delete.type, DCTTestAccountStoreQueryDelegateEventTypeRemove, @"Should receive delete callback.");
	XCTAssertEqual(delete.fromIndex, (NSUInteger)0, @"Should be deleted from index 0.");
	XCTAssertEqual(delete.toIndex, (NSUInteger)0, @"Should be deleted at index 0.");
}

- (void)testMove {

	DCTTestAccount *account1 = [DCTTestAccount new];
	account1.accountDescription = @"A";
	[self.store saveAccount:account1];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)1, @"Delegate should have received 1 callback.");
	DCTTestAccountStoreQueryDelegateEvent *insert1 = self.delegate.events[0];
	XCTAssertEqualObjects(insert1.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(insert1.account, account1, @"Account should be account1.");
	XCTAssertEqual(insert1.type, DCTTestAccountStoreQueryDelegateEventTypeInsert, @"Should receive insert callback.");
	XCTAssertEqual(insert1.fromIndex, (NSUInteger)0, @"Should be inserted at index 0.");
	XCTAssertEqual(insert1.toIndex, (NSUInteger)0, @"Should be inserted at index 0.");

	DCTTestAccount *account2 = [DCTTestAccount new];
	account2.accountDescription = @"B";
	[self.store saveAccount:account2];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)2, @"Delegate should have received 2 callbacks.");
	DCTTestAccountStoreQueryDelegateEvent *insert2 = self.delegate.events[1];
	XCTAssertEqualObjects(insert2.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(insert2.account, account2, @"Account should be account2.");
	XCTAssertEqual(insert2.type, DCTTestAccountStoreQueryDelegateEventTypeInsert, @"Should receive insert callback.");
	XCTAssertEqual(insert2.fromIndex, (NSUInteger)1, @"Should be inserted at index 1.");
	XCTAssertEqual(insert2.toIndex, (NSUInteger)1, @"Should be inserted at index 1.");

	account1.accountDescription = @"C";
	[self.store saveAccount:account1];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)3, @"Delegate should have received 3 callbacks.");
	DCTTestAccountStoreQueryDelegateEvent *move = self.delegate.events[2];
	XCTAssertEqualObjects(move.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(move.account, account1, @"Account should be account1.");
	XCTAssertEqual(move.type, DCTTestAccountStoreQueryDelegateEventTypeMove, @"Should receive move callback.");
	XCTAssertEqual(move.fromIndex, (NSUInteger)1, @"Should be inserted at index 0.");
	XCTAssertEqual(move.toIndex, (NSUInteger)1, @"Should be inserted at index 1.");
}

- (void)testUpdate {

	DCTTestAccount *account = [DCTTestAccount new];
	account.accountDescription = @"A";
	[self.store saveAccount:account];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)1, @"Delegate should have received 1 callback.");
	DCTTestAccountStoreQueryDelegateEvent *insert = self.delegate.events[0];
	XCTAssertEqualObjects(insert.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(insert.account, account, @"Account should be the account.");
	XCTAssertEqual(insert.type, DCTTestAccountStoreQueryDelegateEventTypeInsert, @"Should receive insert callback.");
	XCTAssertEqual(insert.fromIndex, (NSUInteger)0, @"Should be inserted at index 0.");
	XCTAssertEqual(insert.toIndex, (NSUInteger)0, @"Should be inserted at index 0.");

	account.accountDescription = @"B";
	[self.store saveAccount:account];

	XCTAssertEqual(self.delegate.events.count, (NSUInteger)2, @"Delegate should have received 2 callbacks.");
	DCTTestAccountStoreQueryDelegateEvent *update = self.delegate.events[1];
	XCTAssertEqualObjects(update.query, self.query, @"Query should be the same query object.");
	XCTAssertEqualObjects(update.account, account, @"Account should be the account.");
	XCTAssertEqual(update.type, DCTTestAccountStoreQueryDelegateEventTypeUpdate, @"Should receive update callback.");
	XCTAssertEqual(update.fromIndex, (NSUInteger)0, @"Should be inserted at index 0.");
	XCTAssertEqual(update.toIndex, (NSUInteger)0, @"Should be inserted at index 0.");
}

@end
