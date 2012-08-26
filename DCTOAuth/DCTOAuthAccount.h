//
//  DCTOAuthAccount.h
//  DTOAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTOAuthAccount : NSObject

+ (DCTOAuthAccount *)OAuthAccountWithType:(NSString *)type
						  requestTokenURL:(NSURL *)requestTokenURL
							 authorizeURL:(NSURL *)authorizeURL
							  callbackURL:(NSURL *)callbackURL
						   accessTokenURL:(NSURL *)accessTokenURL
							  consumerKey:(NSString *)consumerKey
						   consumerSecret:(NSString *)consumerSecret;

+ (DCTOAuthAccount *)OAuth2AccountWithType:(NSString *)type
							  authorizeURL:(NSURL *)authorizeURL
							   redirectURL:(NSURL *)redirectURL
							accessTokenURL:(NSURL *)accessTokenURL
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *identifier;

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler;
- (void)renewCredentialsWithHandler:(void(^)(BOOL success, NSError *error))handler;

@end
