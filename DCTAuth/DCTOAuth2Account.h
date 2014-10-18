//
//  DCTOAuth2Account.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"

@interface DCTOAuth2Account : DCTAuthAccount

- (instancetype)initWithType:(NSString *)type
				authorizeURL:(NSURL *)authorizeURL
			  accessTokenURL:(NSURL *)accessTokenURL
					clientID:(NSString *)clientID
				clientSecret:(NSString *)clientSecret
					  scopes:(NSArray *)scopes;

- (instancetype)initWithType:(NSString *)type
				authorizeURL:(NSURL *)authorizeURL
					clientID:(NSString *)clientID
				clientSecret:(NSString *)clientSecret
					username:(NSString *)username
					password:(NSString *)password
					  scopes:(NSArray *)scopes;

@end
