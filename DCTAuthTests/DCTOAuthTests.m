//
//  DCTOAuthTests.m
//  DCTAuthTests
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthTests.h"

@implementation DCTOAuthTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
/*
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://term.ie/oauth/example/request_token.php"]
															requestMethod:DCTAuthRequestMethodGET
															  consumerKey:@"key"
														   consumerSecret:@"secret"
															  secretToken:nil
															   parameters:@{ @"oauth_timestamp" : @"1345826992", @"oauth_nonce" : @"b4696000393d543688d556803942c454" }];

	STAssertEquals([signature signedString], @"zztUSurGniiVrseOLpky6kWPC0Y=", @"EQUAL OR NOT!");
*/

	//http://term.ie/oauth/example/request_token.php?oauth_version=1.0&oauth_nonce=b4696000393d543688d556803942c454&oauth_timestamp=1345826992&oauth_consumer_key=key&oauth_signature_method=HMAC-SHA1&oauth_signature=zztUSurGniiVrseOLpky6kWPC0Y%3D
	

}

@end
