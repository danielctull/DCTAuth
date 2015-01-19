//
//  DCTAuthAccountStoreQueryPredicateTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import XCTest;
@import DCTAuth;
#import "DCTTestAccount.h"

static NSString *const DCTAuthAccountStoreQueryPredicateTestsString = @"A";
static NSString *const DCTAuthAccountStoreQueryPredicateTestsNotString = @"B";

@interface DCTAuthAccountStoreQueryPredicateTests : XCTestCase
@property (nonatomic) DCTAuthAccountStore *store;
@property (nonatomic) DCTAuthAccountStoreQuery *query;
@end

@implementation DCTAuthAccountStoreQueryPredicateTests

- (void)setUp {
	[super setUp];
	self.store = [DCTAuthAccountStore accountStoreWithName:[[NSUUID UUID] UUIDString]];
	NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:DCTAuthAccountProperties.accountDescription ascending:YES]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", DCTAuthAccountProperties.accountDescription, DCTAuthAccountStoreQueryPredicateTestsString];
	self.query = [[DCTAuthAccountStoreQuery alloc] initWithAccountStore:self.store predciate:predicate sortDescriptors:sortDescriptors];
}

- (void)tearDown {
	self.store = nil;
	[super tearDown];
}

- (void)testInsertion {
	DCTTestAccount *account = [DCTTestAccount new];
	account.accountDescription = DCTAuthAccountStoreQueryPredicateTestsString;
	[self.store saveAccount:account];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)1, @"Count should be 1.");
	XCTAssertEqualObjects([self.query.accounts firstObject], account, @"Account should be the given account.");
}

- (void)testNotInsertion {
	DCTTestAccount *account = [DCTTestAccount new];
	account.accountDescription = DCTAuthAccountStoreQueryPredicateTestsNotString;
	[self.store saveAccount:account];

	XCTAssertEqual(self.query.accounts.count, (NSUInteger)0, @"Count should be 0.");
}

@end
