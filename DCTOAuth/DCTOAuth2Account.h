//
//  DCTOAuth2Account.h
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccount.h"

@interface DCTOAuth2Account : DCTOAuthAccount

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
	   redirectURL:(NSURL *)redirectURL
	accessTokenURL:(NSURL *)accessTokenURL
		  clientID:(NSString *)clientID
	  clientSecret:(NSString *)clientSecret;

@end
