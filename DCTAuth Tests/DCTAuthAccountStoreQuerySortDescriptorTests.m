//
//  DCTAuthAccountStoreQuerySortDescriptorTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import XCTest;
@import DCTAuth;
#import "DCTTestAccount.h"

@interface DCTAuthAccountStoreQuerySortDescriptorTests : XCTestCase
@property (nonatomic) DCTAuthAccountStore *store;
@property (nonatomic) DCTAuthAccountStoreQuery *query;
@end

@implementation DCTAuthAccountStoreQuerySortDescriptorTests

- (void)setUp {
	[super setUp];
	self.store = [DCTAuthAccountStore accountStoreWithName:[[NSUUID UUID] UUIDString]];
	NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:DCTAuthAccountProperties.accountDescription ascending:YES]];
	self.query = [[DCTAuthAccountStoreQuery alloc] initWithAccountStore:self.store predciate:nil sortDescriptors:sortDescriptors];
}

- (void)tearDown {
	self.store = nil;
	[super tearDown];
}

- (void)testSort {
	DCTTestAccount *account1 = [DCTTestAccount new];
	account1.accountDescription = @"1";
	[self.store saveAccount:account1];

	DCTTestAccount *account2 = [DCTTestAccount new];
	account2.accountDescription = @"2";
	[self.store saveAccount:account2];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)2, @"Store should have two accounts.");
	XCTAssertEqualObjects(self.query.accounts[0], account1, @"First account should be account1.");
	XCTAssertEqualObjects(self.query.accounts[1], account2, @"First account should be account2.");
}

- (void)testSort2 {
	DCTTestAccount *account1 = [DCTTestAccount new];
	account1.accountDescription = @"2";
	[self.store saveAccount:account1];

	DCTTestAccount *account2 = [DCTTestAccount new];
	account2.accountDescription = @"1";
	[self.store saveAccount:account2];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)2, @"Store should have two accounts.");
	XCTAssertEqualObjects(self.query.accounts[0], account1, @"First account should be account2.");
	XCTAssertEqualObjects(self.query.accounts[1], account2, @"Second account should be account1.");
}

- (void)testMove {
	DCTTestAccount *account1 = [DCTTestAccount new];
	account1.accountDescription = @"1";
	[self.store saveAccount:account1];

	DCTTestAccount *account2 = [DCTTestAccount new];
	account2.accountDescription = @"2";
	[self.store saveAccount:account2];

	account1.accountDescription = @"3";
	[self.store saveAccount:account1];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)2, @"Store should have two accounts.");
	XCTAssertEqualObjects(self.query.accounts[0], account1, @"First account should be account2.");
	XCTAssertEqualObjects(self.query.accounts[1], account2, @"Second account should be account1.");
}

@end
