//
//  DTOAuthController.h
//  DTOAuthController
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthRequest.h"

@interface DCTOAuthAccount : NSObject

- (id)initWithRequestTokenURL:(NSURL *)requestTokenURL
				 authorizeURL:(NSURL *)authorizeURL
				  callbackURL:(NSURL *)callbackURL
			   accessTokenURL:(NSURL *)accessTokenURL
				  consumerKey:(NSString *)consumerKey
			   consumerSecret:(NSString *)consumerSecret;

@property (nonatomic, readonly) NSURL *requestTokenURL;
@property (nonatomic, readonly) NSURL *accessTokenURL;
@property (nonatomic, readonly) NSURL *authorizeURL;
@property (nonatomic, readonly) NSURL *callbackURL;

@property (nonatomic, readonly) NSString *consumerKey;
@property (nonatomic, readonly) NSString *consumerSecret;

@property (nonatomic, copy, readonly) NSString *oauthToken;
@property (nonatomic, copy, readonly) NSString *oauthTokenSecret;
@property (nonatomic, copy, readonly) NSString *oauthVerifier;

- (void)performAuthenticationWithCompletion:(void(^)(NSDictionary *returnedValues))completion;

@end
