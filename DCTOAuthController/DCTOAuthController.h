//
//  DTOAuthController.h
//  DTOAuthController
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthRequestMethod.h"
#import "DCTOAuthSignature.h"

@interface DCTOAuthController : NSObject

- (id)initWithRequestTokenURL:(NSURL *)requestTokenURL
			   accessTokenURL:(NSURL *)accessTokenURL
				 authorizeURL:(NSURL *)authorizeURL
				  callbackURL:(NSURL *)callbackURL
				  consumerKey:(NSString *)consumerKey
			   consumerSecret:(NSString *)consumerSecret;

@property (nonatomic, copy, readonly) NSURL *requestTokenURL;
@property (nonatomic, copy, readonly) NSURL *accessTokenURL;
@property (nonatomic, copy, readonly) NSURL *authorizeURL;
@property (nonatomic, copy, readonly) NSURL *callbackURL;

@property (nonatomic, copy, readonly) NSString *consumerKey;
@property (nonatomic, copy, readonly) NSString *consumerSecret;

@property (nonatomic, copy, readonly) NSString *oauthToken;
@property (nonatomic, copy, readonly) NSString *oauthTokenSecret;
@property (nonatomic, copy, readonly) NSString *oauthVerifier;

- (void)fetchAccessTokenCompletion:(void(^)(NSDictionary *returnedValues))completion;

@end
