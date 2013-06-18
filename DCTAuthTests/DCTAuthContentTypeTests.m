//
//  DCTAuthContentTypeTests.m
//  DCTAuth
//
//  Created by Daniel Tull on 30.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthContentTypeTests.h"
#import "_DCTAuthContentType.h"

@implementation DCTAuthContentTypeTests

- (void)testInitWithString {
	NSString *content_type = @"text/html; charset=UTF-8";
	_DCTAuthContentType *contentType = [[_DCTAuthContentType alloc] initWithString:content_type];
	XCTAssertTrue(contentType.contentType == DCTAuthContentTypeTextHTML, @"%i should be %i", contentType.contentType, DCTAuthContentTypeTextHTML);
	XCTAssertTrue(contentType.stringEncoding == NSUTF8StringEncoding, @"%i should be %i", contentType.stringEncoding, NSUTF8StringEncoding);
	XCTAssertTrue([contentType.string isEqualToString:content_type], @"%@ should be %@", contentType.string, content_type);
}

- (void)testInitWithContentType {
	DCTAuthContentTypeType type = DCTAuthContentTypeJSON;
	_DCTAuthContentType *contentType = [[_DCTAuthContentType alloc] initWithContentType:DCTAuthContentTypeJSON];
	XCTAssertTrue(contentType.contentType == type, @"%i should be %i", contentType.contentType, type);
	XCTAssertTrue(contentType.stringEncoding == NSUTF8StringEncoding, @"%i should be %i", contentType.stringEncoding, NSUTF8StringEncoding);
	XCTAssertTrue([contentType.string isEqualToString:@"application/json"], @"%@ should be %@", contentType.string, @"application/json");
}

- (void)testInitWithContentTypeParameters {

	NSDictionary *parameters = @{ @"charset" : @"UTF-8" };
	DCTAuthContentTypeType type = DCTAuthContentTypeTextHTML;
	NSString *expectedString = @"text/html; charset=UTF-8";
	NSStringEncoding encoding = NSUTF8StringEncoding;
	_DCTAuthContentType *contentType = [[_DCTAuthContentType alloc] initWithContentType:type parameters:parameters];
	XCTAssertTrue(contentType.contentType == type, @"%i should be %i", contentType.contentType, type);
	XCTAssertTrue(contentType.stringEncoding == encoding, @"%i should be %i", contentType.stringEncoding, encoding);
	XCTAssertTrue([contentType.string isEqualToString:expectedString], @"%@ should be %@", contentType.string, expectedString);

	parameters = @{ @"key" : @"value" };
	type = DCTAuthContentTypePlist;
	expectedString = @"application/plist; key=value";
	encoding = NSUTF8StringEncoding;
	contentType = [[_DCTAuthContentType alloc] initWithContentType:type parameters:parameters];
	XCTAssertTrue(contentType.contentType == type, @"%i should be %i", contentType.contentType, type);
	XCTAssertTrue(contentType.stringEncoding == encoding, @"%i should be %i", contentType.stringEncoding, encoding);
	XCTAssertTrue([contentType.string isEqualToString:expectedString], @"%@ should be %@", contentType.string, expectedString);

	parameters = @{ @"charset" : @"UTF-8" };
	type = DCTAuthContentTypeTextHTML;
	expectedString = @"text/html; charset=UTF-8";
	encoding = NSUTF8StringEncoding;
	contentType = [[_DCTAuthContentType alloc] initWithContentType:type parameters:parameters];
	XCTAssertTrue(contentType.contentType == type, @"%i should be %i", contentType.contentType, type);
	XCTAssertTrue(contentType.stringEncoding == encoding, @"%i should be %i", contentType.stringEncoding, encoding);
	XCTAssertTrue([contentType.string isEqualToString:expectedString], @"%@ should be %@", contentType.string, expectedString);

	encoding = NSASCIIStringEncoding;
	parameters = @{ DCTAuthContentTypeParameterCharset : @(encoding) };
	type = DCTAuthContentTypePlist;
	expectedString = @"application/plist; charset=us-ascii";
	contentType = [[_DCTAuthContentType alloc] initWithContentType:type parameters:parameters];
	XCTAssertTrue(contentType.contentType == type, @"%i should be %i", contentType.contentType, type);
	XCTAssertTrue(contentType.stringEncoding == encoding, @"%i should be %i", contentType.stringEncoding, encoding);
	XCTAssertTrue([contentType.string isEqualToString:expectedString], @"%@ should be %@", contentType.string, expectedString);
}

@end
