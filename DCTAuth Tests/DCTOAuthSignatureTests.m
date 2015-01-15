//
//  DCTOAuthTests.m
//  DCTAuthTests
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthSignature.h"
#import <XCTest/XCTest.h>

@interface DCTOAuthSignatureTests : XCTestCase
@end

@implementation DCTOAuthSignatureTests

- (void)testHMAC_SHA1Signature {
	NSURL *URL = [NSURL URLWithString:@"http://host.net/resource"];
	NSURLQueryItem *oauthItem = [NSURLQueryItem queryItemWithName:@"oauth_token" value:@"token"];
	NSURLQueryItem *consumerKeyItem = [NSURLQueryItem queryItemWithName:@"oauth_consumer_key" value:@"consumer_key"];
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:URL
															   HTTPMethod:@"GET"
														   consumerSecret:@"consumer_secret"
															  secretToken:@"token_secret"
																	items:@[oauthItem, consumerKeyItem]
																	 type:DCTOAuthSignatureTypeHMAC_SHA1
																timestamp:@"1358592821"
																	nonce:@"qwerty"];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	XCTAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"Vo3AveMDxJ2uH1CXUY69YfUzpQI=";
	XCTAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should be %@", signatureString, expectedSignatureString);
}

- (void)testHMAC_SHA1SignatureWithQuery {
	NSURL *URL = [NSURL URLWithString:@"http://host.net/resource?key1=value1&key2=value2"];
	NSURLQueryItem *oauthItem = [NSURLQueryItem queryItemWithName:@"oauth_token" value:@"token"];
	NSURLQueryItem *consumerKeyItem = [NSURLQueryItem queryItemWithName:@"oauth_consumer_key" value:@"consumer_key"];
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:URL
															   HTTPMethod:@"GET"
														   consumerSecret:@"consumer_secret"
															  secretToken:@"token_secret"
																	items:@[oauthItem, consumerKeyItem]
																	 type:DCTOAuthSignatureTypeHMAC_SHA1
																timestamp:@"1358592821"
																	nonce:@"qwerty"];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&key1%3Dvalue1%26key2%3Dvalue2%26oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	XCTAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"NuOpOgRWpCjaqa5EMc79ReuwFTk=";
	XCTAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should be %@", signatureString, expectedSignatureString);
}

- (void)testHMAC_SHA1SignatureWithFragment {
	NSURL *URL = [NSURL URLWithString:@"http://host.net/resource#fragment"];
	NSURLQueryItem *oauthItem = [NSURLQueryItem queryItemWithName:@"oauth_token" value:@"token"];
	NSURLQueryItem *consumerKeyItem = [NSURLQueryItem queryItemWithName:@"oauth_consumer_key" value:@"consumer_key"];
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:URL
															   HTTPMethod:@"GET"
														   consumerSecret:@"consumer_secret"
															  secretToken:@"token_secret"
																	items:@[oauthItem, consumerKeyItem]
																	 type:DCTOAuthSignatureTypeHMAC_SHA1
																timestamp:@"1358592821"
																	nonce:@"qwerty"];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	XCTAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"Vo3AveMDxJ2uH1CXUY69YfUzpQI=";
	XCTAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should to %@", signatureString, expectedSignatureString);
}

- (void)testHMAC_SHA1SignatureWithQueryAndFragment {
	NSURL *URL = [NSURL URLWithString:@"http://host.net/resource?key1=value1&key2=value2#fragment"];
	NSURLQueryItem *oauthItem = [NSURLQueryItem queryItemWithName:@"oauth_token" value:@"token"];
	NSURLQueryItem *consumerKeyItem = [NSURLQueryItem queryItemWithName:@"oauth_consumer_key" value:@"consumer_key"];
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:URL
															   HTTPMethod:@"GET"
														   consumerSecret:@"consumer_secret"
															  secretToken:@"token_secret"
																	items:@[oauthItem, consumerKeyItem]
																	 type:DCTOAuthSignatureTypeHMAC_SHA1
																timestamp:@"1358592821"
																	nonce:@"qwerty"];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&key1%3Dvalue1%26key2%3Dvalue2%26oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	XCTAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"NuOpOgRWpCjaqa5EMc79ReuwFTk=";
	XCTAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should be %@", signatureString, expectedSignatureString);
}

@end
