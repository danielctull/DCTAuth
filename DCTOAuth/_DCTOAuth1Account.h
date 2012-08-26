//
//  DCTOAuth1Account.h
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccount.h"

@interface _DCTOAuth1Account : DCTOAuthAccount

- (id)initWithType:(NSString *)type
   requestTokenURL:(NSURL *)requestTokenURL
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
	   consumerKey:(NSString *)consumerKey
	consumerSecret:(NSString *)consumerSecret;

@property (nonatomic, readonly) NSURL *requestTokenURL;
@property (nonatomic, readonly) NSURL *accessTokenURL;
@property (nonatomic, readonly) NSURL *authorizeURL;

@property (nonatomic, readonly) NSString *consumerKey;
@property (nonatomic, readonly) NSString *consumerSecret;

@property (nonatomic, copy, readonly) NSString *oauthToken;
@property (nonatomic, copy, readonly) NSString *oauthTokenSecret;
@property (nonatomic, copy, readonly) NSString *oauthVerifier;

@end
