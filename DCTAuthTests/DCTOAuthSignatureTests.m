//
//  DCTOAuthTests.m
//  DCTAuthTests
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthSignatureTests.h"
#import "_DCTOAuthSignature.h"

@implementation DCTOAuthSignatureTests

- (void)testHMAC_SHA1Signature {
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://host.net/resource"]
																 HTTPMethod:@"GET"
															 consumerSecret:@"consumer_secret"
																secretToken:@"token_secret"
																 parameters:@{ @"oauth_timestamp" : @"1358592821",
																				   @"oauth_token" : @"token",
																				   @"oauth_nonce" : @"qwerty",
																			@"oauth_consumer_key" : @"consumer_key" }
																	   type:DCTOAuthSignatureTypeHMAC_SHA1];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	STAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"Vo3AveMDxJ2uH1CXUY69YfUzpQI=";
	STAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should be %@", signatureString, expectedSignatureString);
}

- (void)testHMAC_SHA1SignatureWithQuery {
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://host.net/resource?key1=value1&key2=value2"]
																 HTTPMethod:@"GET"
															 consumerSecret:@"consumer_secret"
																secretToken:@"token_secret"
																 parameters:@{ @"oauth_timestamp" : @"1358592821",
									 @"oauth_token" : @"token",
									 @"oauth_nonce" : @"qwerty",
									 @"oauth_consumer_key" : @"consumer_key" }
																	   type:DCTOAuthSignatureTypeHMAC_SHA1];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&key1%3Dvalue1%26key2%3Dvalue2%26oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	STAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"NuOpOgRWpCjaqa5EMc79ReuwFTk=";
	STAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should be %@", signatureString, expectedSignatureString);
}

- (void)testHMAC_SHA1SignatureWithFragment {
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://host.net/resource#fragment"]
																 HTTPMethod:@"GET"
															 consumerSecret:@"consumer_secret"
																secretToken:@"token_secret"
																 parameters:@{ @"oauth_timestamp" : @"1358592821",
									 @"oauth_token" : @"token",
									 @"oauth_nonce" : @"qwerty",
									 @"oauth_consumer_key" : @"consumer_key" }
																	   type:DCTOAuthSignatureTypeHMAC_SHA1];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	STAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"Vo3AveMDxJ2uH1CXUY69YfUzpQI=";
	STAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should to %@", signatureString, expectedSignatureString);
}

- (void)testHMAC_SHA1SignatureWithQueryAndFragment {
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://host.net/resource?key1=value1&key2=value2#fragment"]
																 HTTPMethod:@"GET"
															 consumerSecret:@"consumer_secret"
																secretToken:@"token_secret"
																 parameters:@{ @"oauth_timestamp" : @"1358592821",
									 @"oauth_token" : @"token",
									 @"oauth_nonce" : @"qwerty",
									 @"oauth_consumer_key" : @"consumer_key" }
																	   type:DCTOAuthSignatureTypeHMAC_SHA1];

	NSString *signatureBaseString = [signature signatureBaseString];
	NSString *expectedSignatureBaseString = @"GET&http%3A%2F%2Fhost.net%2Fresource&key1%3Dvalue1%26key2%3Dvalue2%26oauth_consumer_key%3Dconsumer_key%26oauth_nonce%3Dqwerty%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1358592821%26oauth_token%3Dtoken%26oauth_version%3D1.0";
	STAssertTrue([signatureBaseString isEqualToString:expectedSignatureBaseString], @"%@ should be %@", signatureBaseString, expectedSignatureBaseString);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"NuOpOgRWpCjaqa5EMc79ReuwFTk=";
	STAssertTrue([signatureString isEqualToString:expectedSignatureString], @"%@ should be %@", signatureString, expectedSignatureString);
}

@end
