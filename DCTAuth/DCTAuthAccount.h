//
//  DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A DCTAuthAccount object encapsulates information about a user account stored in the database. You can create and retrieve accounts using an DCTAuthAccountStore object. The DCTAuthAccountStore object provides an interface to the persistent database. All account objects belong to a single DCTAuthAccountStore object.
 */
@interface DCTAuthAccount : NSObject

/**  */
+ (DCTAuthAccount *)OAuthAccountWithType:(NSString *)type
						  requestTokenURL:(NSURL *)requestTokenURL
							 authorizeURL:(NSURL *)authorizeURL
						   accessTokenURL:(NSURL *)accessTokenURL
							  consumerKey:(NSString *)consumerKey
						   consumerSecret:(NSString *)consumerSecret;

/**  */
+ (DCTAuthAccount *)OAuth2AccountWithType:(NSString *)type
							  authorizeURL:(NSURL *)authorizeURL
							accessTokenURL:(NSURL *)accessTokenURL
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret
									scopes:(NSArray *)scopes;

/**  */
+ (DCTAuthAccount *)basicAuthAccountWithType:(NSString *)type
						   authenticationURL:(NSURL *)authenticationURL
									username:(NSString *)username
									password:(NSString *)password;

/** The type of service account. */
@property (nonatomic, readonly) NSString *type;

/** A unique identifier for this account.
 
 Use the -[DCTAuthAccountStore accountWithIdentifier:] method to get an account with the specified identifier.
 
 @see -[DCTAuthAccountStore accountWithIdentifier:]
 */
@property (nonatomic, readonly) NSString *identifier;

/** */
@property (nonatomic, readonly, getter = isAuthorized) BOOL authorized;

/** A human-readable description of the account. */
@property (nonatomic, copy) NSString *accountDescription;

/** */
@property (nonatomic, copy) NSURL *callbackURL;

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler;
//- (void)renewCredentialsWithHandler:(void(^)(BOOL success, NSError *error))handler;

- (id)initWithType:(NSString *)type;

@end

@class DCTAuthRequest;
@protocol DCTAuthAccountSubclass <NSObject>
- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest;
@end
