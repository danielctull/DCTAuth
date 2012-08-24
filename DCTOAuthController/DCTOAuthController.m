//
//  DTOAuthController.m
//  DTOAuthController
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTOAuthController.h"
#import "DCTOAuthURLProtocol.h"
#import "DCTOAuthSignature.h"

@implementation DCTOAuthController {
	
}

- (id)initWithRequestTokenURL:(NSURL *)requestTokenURL
			   accessTokenURL:(NSURL *)accessTokenURL
				 authorizeURL:(NSURL *)authorizeURL
				  callbackURL:(NSURL *)callbackURL
				  consumerKey:(NSString *)consumerKey
			   consumerSecret:(NSString *)consumerSecret {
	
	self = [super init];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_callbackURL = [callbackURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	
	[DCTOAuthURLProtocol registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		
	}];
	
	return self;
}

- (void)_go {
	
	NSURLRequest *request = [NSURLRequest requestWithURL:nil];
	
	
}












@end
