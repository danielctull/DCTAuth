//
//  DCTAuthAccountStoreTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import XCTest;
@import DCTAuth;
#import "DCTTestAccount.h"

@interface DCTAuthAccountStoreTests : XCTestCase
@property (nonatomic) DCTAuthAccountStore *store;
@end

@implementation DCTAuthAccountStoreTests

- (void)setUp {
	[super setUp];
	self.store = [DCTAuthAccountStore accountStoreWithName:[[NSUUID UUID] UUIDString]];
}

- (void)tearDown {
	self.store = nil;
	[super tearDown];
}

- (void)testSame {
	NSString *name = [[NSUUID UUID] UUIDString];
	DCTAuthAccountStore *store1 = [DCTAuthAccountStore accountStoreWithName:name];
	DCTAuthAccountStore *store2 = [DCTAuthAccountStore accountStoreWithName:name];
	XCTAssertEqualObjects(store1, store2, @"Should retrieve exactly the same store object.");
}

- (void)testDifferent {
	NSString *name1 = [[NSUUID UUID] UUIDString];
	NSString *name2 = [[NSUUID UUID] UUIDString];
	DCTAuthAccountStore *store1 = [DCTAuthAccountStore accountStoreWithName:name1];
	DCTAuthAccountStore *store2 = [DCTAuthAccountStore accountStoreWithName:name2];
	XCTAssertNotEqualObjects(store1, store2, @"Should retrieve different store objects.");
}

- (void)testInsertion {
	DCTTestAccount *account = [DCTTestAccount new];
	[self.store saveAccount:account];
	XCTAssertTrue(self.store.accounts.count == 1, @"Store should have one account.");
	XCTAssertEqualObjects([self.store.accounts anyObject], account, @"The account should be the inserted account.");
}

- (void)testInsertion2 {
	DCTTestAccount *account1 = [DCTTestAccount new];
	DCTTestAccount *account2 = [DCTTestAccount new];
	[self.store saveAccount:account1];
	[self.store saveAccount:account2];

	XCTAssertEqual(self.store.accounts.count, (NSUInteger)2, @"Store should have two accounts.");
	XCTAssertTrue([self.store.accounts containsObject:account1], @"Store should contain account1.");
	XCTAssertTrue([self.store.accounts containsObject:account2], @"Store should contain account2.");
}

- (void)testDeletion {
	DCTTestAccount *account = [DCTTestAccount new];
	[self.store saveAccount:account];
	[self.store deleteAccount:account];
	XCTAssertEqual(self.store.accounts.count, (NSUInteger)0, @"The store should contain no accounts.");
}

- (void)testDeletion2 {
	DCTTestAccount *account1 = [DCTTestAccount new];
	DCTTestAccount *account2 = [DCTTestAccount new];
	[self.store saveAccount:account1];
	[self.store saveAccount:account2];
	[self.store deleteAccount:account1];
	XCTAssertEqual(self.store.accounts.count, (NSUInteger)1, @"The store should contain one account.");
	XCTAssertEqualObjects([self.store.accounts anyObject], account2, @"The account should be account2.");
}

@end
