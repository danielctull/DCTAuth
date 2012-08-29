//
//  DCTOAuthAccount.h
//  DTOAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTAuthAccount : NSObject

+ (DCTAuthAccount *)OAuthAccountWithType:(NSString *)type
						  requestTokenURL:(NSURL *)requestTokenURL
							 authorizeURL:(NSURL *)authorizeURL
						   accessTokenURL:(NSURL *)accessTokenURL
							  consumerKey:(NSString *)consumerKey
						   consumerSecret:(NSString *)consumerSecret;

+ (DCTAuthAccount *)OAuth2AccountWithType:(NSString *)type
							  authorizeURL:(NSURL *)authorizeURL
							accessTokenURL:(NSURL *)accessTokenURL
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret
									scopes:(NSArray *)scopes;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly, getter = isAuthorized) BOOL authorized;

@property (nonatomic, copy) NSString *accountDescription;
@property (nonatomic, copy) NSURL *callbackURL;

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler;
//- (void)renewCredentialsWithHandler:(void(^)(BOOL success, NSError *error))handler;

@end
