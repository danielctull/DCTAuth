//
//  DCTAuthKeychainTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 18/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTAuthKeychainAccess.h"
#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE

@interface DCTAuthKeychainTests : XCTestCase
@end

@implementation DCTAuthKeychainTests

- (void)testDataStorage {

	NSData *data = [@"Input string" dataUsingEncoding:NSUTF8StringEncoding];
	NSString *account = @"Daniel";
	NSString *storeName = @"Store";
	_DCTAuthKeychainAccessType type = _DCTAuthKeychainAccessTypeAccount;

	[_DCTAuthKeychainAccess addData:data forAccountIdentifier:account storeName:storeName type:type];

	NSData *data2 = [_DCTAuthKeychainAccess dataForAccountIdentifier:account storeName:storeName type:type];
	XCTAssertEqualObjects(data, data2, @"Data in is not the same as data out");

	NSData *data3 = [_DCTAuthKeychainAccess dataForAccountIdentifier:account storeName:storeName type:_DCTAuthKeychainAccessTypeCredential];
	XCTAssertFalse([data isEqualToData:data3], @"Credential data is same as account data");
}

@end

#endif
