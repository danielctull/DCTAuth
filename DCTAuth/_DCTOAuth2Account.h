//
//  DCTOAuth2Account.h
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"

@interface _DCTOAuth2Account : DCTAuthAccount

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
		  clientID:(NSString *)clientID
	  clientSecret:(NSString *)clientSecret
			scopes:(NSArray *)scopes;

@end
