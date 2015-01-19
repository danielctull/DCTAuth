//
//  DCTAuthAccountStoreQueryTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import XCTest;
@import DCTAuth;
#import "DCTTestAccount.h"

@interface DCTAuthAccountStoreQueryTests : XCTestCase
@property (nonatomic) DCTAuthAccountStore *store;
@property (nonatomic) DCTAuthAccountStoreQuery *query;
@end

@implementation DCTAuthAccountStoreQueryTests

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

- (void)testInsertion {
	DCTTestAccount *account = [DCTTestAccount new];
	[self.store saveAccount:account];
	XCTAssertEqual(self.query.accounts.count, (NSUInteger)1, @"Count should be 1.");
	XCTAssertEqualObjects([self.query.accounts firstObject], account, @"Account should be the given account.");
}

- (void)testInsertion2 {
	DCTTestAccount *account1 = [DCTTestAccount new];
	account1.accountDescription = @"1";
	[self.store saveAccount:account1];

	DCTTestAccount *account2 = [DCTTestAccount new];
	account2.accountDescription = @"2";
	[self.store saveAccount:account2];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)2, @"Query should have two accounts.");
	XCTAssertEqualObjects(self.query.accounts.firstObject, account1, @"Query's first account should be account1.");
	XCTAssertEqualObjects(self.query.accounts.lastObject, account2, @"Query's first account should be account2.");
}

- (void)testDeletion {
	DCTTestAccount *account = [DCTTestAccount new];
	[self.store saveAccount:account];
	[self.store deleteAccount:account];
	XCTAssertEqual(self.query.accounts.count, (NSUInteger)0, @"Should contain no accounts.");
}

- (void)testDeletion2 {
	DCTTestAccount *account1 = [DCTTestAccount new];
	account1.accountDescription = @"1";
	[self.store saveAccount:account1];

	DCTTestAccount *account2 = [DCTTestAccount new];
	account2.accountDescription = @"2";
	[self.store saveAccount:account2];

	[self.store deleteAccount:account1];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)1, @"Query should have one account.");
	XCTAssertEqualObjects(self.query.accounts.firstObject, account2, @"Query's only account should be account2.");
}

@end
