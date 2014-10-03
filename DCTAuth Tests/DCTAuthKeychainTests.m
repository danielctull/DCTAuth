//
//  DCTAuthKeychainTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 18/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthKeychainAccess.h"
#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE

@interface DCTAuthKeychainTests : XCTestCase
@end

@implementation DCTAuthKeychainTests

- (void)testDataStorage {

	NSData *data = [@"Input string" dataUsingEncoding:NSUTF8StringEncoding];
	NSString *account = @"Daniel";
	NSString *storeName = @"Store";
	DCTAuthKeychainAccessType type = DCTAuthKeychainAccessTypeAccount;

	[DCTAuthKeychainAccess addData:data forAccountIdentifier:account storeName:storeName type:type accessGroup:@"group" synchronizable:NO];

	NSData *data2 = [DCTAuthKeychainAccess dataForAccountIdentifier:account storeName:storeName type:type accessGroup:@"group" synchronizable:NO];
	XCTAssertEqualObjects(data, data2, @"Data in is not the same as data out");

	NSData *data3 = [DCTAuthKeychainAccess dataForAccountIdentifier:account storeName:storeName type:DCTAuthKeychainAccessTypeCredential accessGroup:@"group" synchronizable:NO];
	XCTAssertFalse([data isEqualToData:data3], @"Credential data is same as account data");
}

@end

#endif
