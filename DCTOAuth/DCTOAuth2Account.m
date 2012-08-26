//
//  DCTOAuth2Account.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuth2Account.h"
#import "_DCTOAuthAccount.h"

@implementation DCTOAuth2Account

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
	   redirectURL:(NSURL *)redirectURL
	accessTokenURL:(NSURL *)accessTokenURL
		  clientID:(NSString *)clientID
	  clientSecret:(NSString *)clientSecret {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	
	
	return self;
}

@end
