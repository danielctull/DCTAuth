//
//  DCTOAuthTests.m
//  DCTAuthTests
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthTests.h"
#import "_DCTOAuthSignature.h"

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
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:[NSURL URLWithString:@"http://term.ie/oauth/example/request_token.php"]
																 HTTPMethod:@"GET"
															 consumerSecret:@"secret"
																secretToken:nil
																 parameters:@{ @"oauth_timestamp" : @"1345826992",
																				   @"oauth_nonce" : @"b4696000393d543688d556803942c454",
																				  @"consumer_key" : @"key" }];

	NSString *header = [signature authorizationHeader];
	NSString *expectedHeader = @"OAuth oauth_timestamp=\"1345826992\",oauth_nonce=\"b4696000393d543688d556803942c454\",oauth_version=\"1.0\",consumer_key=\"key\",oauth_signature_method=\"HMAC-SHA1\",oauth_signature=\"3zXsfFu6ltT9KF29wEsA61ojC4k%3D\"";
	STAssertTrue([header isEqualToString:expectedHeader], @"header: %@", header);

	//http://term.ie/oauth/example/request_token.php?oauth_version=1.0&oauth_nonce=b4696000393d543688d556803942c454&oauth_timestamp=1345826992&oauth_consumer_key=key&oauth_signature_method=HMAC-SHA1&oauth_signature=zztUSurGniiVrseOLpky6kWPC0Y%3D
	

}

@end
