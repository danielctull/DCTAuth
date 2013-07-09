//
//  _DCTOAuth2Account.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountSubclass.h"

@interface _DCTOAuth2Account : DCTAuthAccount <DCTAuthAccountSubclass>

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
		  clientID:(NSString *)clientID
	  clientSecret:(NSString *)clientSecret
			scopes:(NSArray *)scopes;

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
		  username:(NSString *)username
		  password:(NSString *)password
			scopes:(NSArray *)scopes;

@end
