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

- (void)testExample {
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://term.ie/oauth/example/request_token.php"]
																 HTTPMethod:@"GET"
															 consumerSecret:@"secret"
																secretToken:nil
																 parameters:@{ @"oauth_timestamp" : @"1345826992",
																				   @"oauth_nonce" : @"b4696000393d543688d556803942c454",
																				  @"consumer_key" : @"key" }
																	   type:DCTOAuthSignatureTypeHMAC_SHA1];

	NSString *header = [signature authorizationHeader];
	NSString *expectedHeader = @"OAuth oauth_timestamp=\"1345826992\",oauth_nonce=\"b4696000393d543688d556803942c454\",oauth_version=\"1.0\",consumer_key=\"key\",oauth_signature_method=\"HMAC-SHA1\",oauth_signature=\"3zXsfFu6ltT9KF29wEsA61ojC4k%3D\"";
	
	STAssertTrue([header isEqualToString:expectedHeader], @"%@ is not expected header.", header);

	//http://term.ie/oauth/example/request_token.php?oauth_version=1.0&oauth_nonce=b4696000393d543688d556803942c454&oauth_timestamp=1345826992&oauth_consumer_key=key&oauth_signature_method=HMAC-SHA1&oauth_signature=zztUSurGniiVrseOLpky6kWPC0Y%3D
}

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
	STAssertEqualObjects(signatureBaseString, expectedSignatureBaseString, nil);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"Vo3AveMDxJ2uH1CXUY69YfUzpQI=";
	STAssertEqualObjects(signatureString, expectedSignatureString, nil);
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
	STAssertEqualObjects(signatureBaseString, expectedSignatureBaseString, nil);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"NuOpOgRWpCjaqa5EMc79ReuwFTk=";
	STAssertEqualObjects(signatureString, expectedSignatureString, nil);
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
	STAssertEqualObjects(signatureBaseString, expectedSignatureBaseString, nil);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"Vo3AveMDxJ2uH1CXUY69YfUzpQI=";
	STAssertEqualObjects(signatureString, expectedSignatureString, nil);
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
	STAssertEqualObjects(signatureBaseString, expectedSignatureBaseString, nil);

	NSString *signatureString = [signature signatureString];
	NSString *expectedSignatureString = @"NuOpOgRWpCjaqa5EMc79ReuwFTk=";
	STAssertEqualObjects(signatureString, expectedSignatureString, nil);
}

@end
