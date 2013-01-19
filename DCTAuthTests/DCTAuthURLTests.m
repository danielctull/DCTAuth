//
//  DCTAuthURLTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 09/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthURLTests.h"
#import "NSURL+DCTAuth.h"

@implementation DCTAuthURLTests

- (void)testAddQuery1 {
	NSURL *URL = [NSURL URLWithString:@"http://danieltull.co.uk/path/to/page"];
	URL = [URL dctAuth_URLByAddingQueryParameters:@{ @"key" : @"value" }];
	NSString *expected = @"http://danieltull.co.uk/path/to/page?key=value";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testAddQuery2 {
	NSURL *URL = [NSURL URLWithString:@"http://danieltull.co.uk/path/to/page/"];
	URL = [URL dctAuth_URLByAddingQueryParameters:@{ @"key" : @"value" }];
	NSString *expected = @"http://danieltull.co.uk/path/to/page/?key=value";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testAddQuery3 {
	NSURL *URL = [NSURL URLWithString:@"http://danieltull.co.uk?key=oldvalue"];
	URL = [URL dctAuth_URLByAddingQueryParameters:@{ @"key" : @"value" }];
	NSString *expected = @"http://danieltull.co.uk?key=value";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testAddQuery4 {
	NSURL *URL = [NSURL URLWithString:@"http://danieltull.co.uk?key1=value1"];
	URL = [URL dctAuth_URLByAddingQueryParameters:@{ @"key" : @"value" }];
	NSString *expected1 = @"http://danieltull.co.uk?key1=value1&key=value";
	NSString *expected2 = @"http://danieltull.co.uk?key=value&key1=value1";
	BOOL expected1True = [[URL absoluteString] isEqualToString:expected1];
	BOOL expected2True = [[URL absoluteString] isEqualToString:expected2];
	STAssertTrue((expected1True || expected2True), @"%@ should be either %@ or %@", URL, expected1, expected2);
}

- (void)testSetUserPassword1 {
	NSURL *URL = [NSURL URLWithString:@"http://danieltull.co.uk"];
	URL = [URL dctAuth_URLBySettingUser:@"user" password:@"password"];
	NSString *expected = @"http://user:password@danieltull.co.uk";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testSetUserPassword2 {
	NSURL *URL = [NSURL URLWithString:@"http://user:password@danieltull.co.uk"];
	URL = [URL dctAuth_URLBySettingUser:@"user1" password:@"password1"];
	NSString *expected = @"http://user1:password1@danieltull.co.uk";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testRemoveQuery {
	NSURL *URL = [NSURL URLWithString:@"http://www.danieltull.co.uk?key=value"];
	URL = [URL dctAuth_URLByRemovingComponentType:kCFURLComponentQuery];
	NSString *expected = @"http://www.danieltull.co.uk";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testRemoveQueryWithFragment {
	NSURL *URL = [NSURL URLWithString:@"http://www.danieltull.co.uk?key=value#fragment"];
	URL = [URL dctAuth_URLByRemovingComponentType:kCFURLComponentQuery];
	NSString *expected = @"http://www.danieltull.co.uk#fragment";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testRemoveFragment {
	NSURL *URL = [NSURL URLWithString:@"http://www.danieltull.co.uk#fragment"];
	URL = [URL dctAuth_URLByRemovingComponentType:kCFURLComponentFragment];
	NSString *expected = @"http://www.danieltull.co.uk";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

- (void)testRemoveFragmentWithQuery {
	NSURL *URL = [NSURL URLWithString:@"http://www.danieltull.co.uk?key=value#fragment"];
	URL = [URL dctAuth_URLByRemovingComponentType:kCFURLComponentFragment];
	NSString *expected = @"http://www.danieltull.co.uk?key=value";
	STAssertTrue([[URL absoluteString] isEqualToString:expected], @"%@ should be %@", URL, expected);
}

@end
