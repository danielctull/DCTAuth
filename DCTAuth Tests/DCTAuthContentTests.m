//
//  DCTAuthContentTypeTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 30.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

@import XCTest;
#import "DCTAuthContent.h"

@interface DCTAuthContentTests : XCTestCase
@end

@implementation DCTAuthContentTests

- (void)test {
	NSURL *URL = [NSURL URLWithString:@"http://host.net"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	request.HTTPMethod = @"POST";
	request.HTTPBody = [@"key=value" dataUsingEncoding:NSUTF8StringEncoding];
	[request addValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

	DCTAuthContent *content = [[DCTAuthContent alloc] initWithRequest:request];

	XCTAssertEqual(content.type, DCTAuthContentTypeForm, @"Should be a form type.");
	XCTAssertEqual(content.encoding, (NSStringEncoding)NSUTF8StringEncoding, @"Should be a UTF-8 encoding.");
	XCTAssertEqual(content.items.count, (NSUInteger)1, @"Content should have one item.");

	NSURLQueryItem *item = content.items[0];

	XCTAssertEqualObjects(item.name, @"key", @"Item's name should be key.");
	XCTAssertEqualObjects(item.value, @"value", @"Item's value should be value.");
}

@end
