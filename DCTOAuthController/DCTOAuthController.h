//
//  DTOAuthController.h
//  DTOAuthController
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTOAuthController : NSObject

- (id)initWithRequestTokenURL:(NSURL *)requestTokenURL
			   accessTokenURL:(NSURL *)accessTokenURL
				 authorizeURL:(NSURL *)authorizeURL
				  callbackURL:(NSURL *)callbackURL
				  consumerKey:(NSString *)consumerKey
			   consumerSecret:(NSString *)consumerSecret;

@property (nonatomic, readonly) NSURL *requestTokenURL;
@property (nonatomic, readonly) NSURL *accessTokenURL;
@property (nonatomic, readonly) NSURL *authorizeURL;
@property (nonatomic, readonly) NSURL *callbackURL;

@property (nonatomic, readonly) NSString *consumerKey;
@property (nonatomic, readonly) NSString *consumerSecret;

@property (nonatomic, readonly) NSString *oauthToken;
@property (nonatomic, readonly) NSString *oauthTokenSecret;
@property (nonatomic, readonly) NSString *accessToken;

@end
