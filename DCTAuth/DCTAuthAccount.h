//
//  DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountCredential.h"

typedef enum {
	DCTOAuthSignatureTypeHMAC_SHA1 = 0,
	DCTOAuthSignatureTypePlaintext
} DCTOAuthSignatureType;

/** A DCTAuthAccount object encapsulates information about a user account stored in the database. You can create and retrieve accounts using an DCTAuthAccountStore object. The DCTAuthAccountStore object provides an interface to the persistent database. All account objects belong to a single DCTAuthAccountStore object.
 */
@interface DCTAuthAccount : NSObject <NSCoding>

/// @name Creating accounts

/** Creates an account using OAuth using a HMAC-SHA1 signature type.
 @param type The type of the account.
 @param requestTokenURL The URL to retrieve the OAuth request token.
 @param authorizeURL The URL to perform the OAuth authorization.
 @param accessTokenURL The URL to retrieve the OAuth access token.
 @param consumerKey The consumer key for the app.
 @param consumerSecret The consumer secret for the app.
 @return Newly initialized account.
 */
+ (DCTAuthAccount *)OAuthAccountWithType:(NSString *)type
						 requestTokenURL:(NSURL *)requestTokenURL
							authorizeURL:(NSURL *)authorizeURL
						  accessTokenURL:(NSURL *)accessTokenURL
							 consumerKey:(NSString *)consumerKey
						  consumerSecret:(NSString *)consumerSecret;

/** Creates an account using OAuth.
 @param type The type of the account.
 @param requestTokenURL The URL to retrieve the OAuth request token.
 @param authorizeURL The URL to perform the OAuth authorization.
 @param accessTokenURL The URL to retrieve the OAuth access token.
 @param consumerKey The consumer key for the app.
 @param consumerSecret The consumer secret for the app.
 @param signatureType The signature type to use, either DCTOAuthSignatureTypeHMAC_SHA1 or DCTOAuthSignatureTypePlaintext.
 @return Newly initialized account.
 */
+ (DCTAuthAccount *)OAuthAccountWithType:(NSString *)type
						 requestTokenURL:(NSURL *)requestTokenURL
							authorizeURL:(NSURL *)authorizeURL
						  accessTokenURL:(NSURL *)accessTokenURL
							 consumerKey:(NSString *)consumerKey
						  consumerSecret:(NSString *)consumerSecret
						   signatureType:(DCTOAuthSignatureType)signatureType;


/** Creates an account using OAuth 2.0.
 
 If nil is provided for accessTokenURL and clientSecret, the returned account
 will authenticate using the "implicit" method, where the access token
 is returned from the authorize step. See the
 [draft for the OAuth 2.0 Authorization Framework](http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-1.3.2)
 for more information.

 @param type The type of the account.
 @param authorizeURL The URL to perform the OAuth 2.0 authorization.
 @param accessTokenURL The URL to retrieve the OAuth 2.0 access token or nil.
 @param clientID The client ID for the app.
 @param clientSecret The client secret for the app or nil.
 @param scopes The desired OAuth 2.0 scopes, if any, for this acccount.
 @return Newly initialized account.
 */
+ (DCTAuthAccount *)OAuth2AccountWithType:(NSString *)type
							  authorizeURL:(NSURL *)authorizeURL
							accessTokenURL:(NSURL *)accessTokenURL
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret
									scopes:(NSArray *)scopes;

/** Creates an account using basic authentication. 
 @param type The type of the account.
 @param authenticationURL The URL to authenticate to.
 @param username The username for this account.
 @param password The password for this account.
 @return Newly initialized account.
 */
+ (DCTAuthAccount *)basicAuthAccountWithType:(NSString *)type
						   authenticationURL:(NSURL *)authenticationURL
									username:(NSString *)username
									password:(NSString *)password;

/// @name Accessing Properties

/** The type of service account, which is user defined at the creation of an account.
 
 Once set for an account, it will always be the same and can be used to lookup accounts
 for a particular service. It is currently not used for any other purpose.
 
 @see -[DCTAuthAccountStore accountsWithType:]
 */
@property (nonatomic, readonly) NSString *type;

/** A unique identifier for this account.
 
 This identifier is random and assigned when the account is created.
 
 Use the -[DCTAuthAccountStore accountWithIdentifier:] method to get an account with the specified identifier.
 
 @see -[DCTAuthAccountStore accountWithIdentifier:]
 */
@property (nonatomic, readonly) NSString *identifier;

/** Shows if the account is authorized.
 
 @see authenticateWithHandler: */
@property (nonatomic, readonly, getter = isAuthorized) BOOL authorized;

@property (nonatomic, strong) id<DCTAuthAccountCredential> credential;

/** A human-readable description of the account. */
@property (nonatomic, copy) NSString *accountDescription;

/// @name Authentication

/** The URL the OAuth authorization process will call back to.
 
 If a callbackURL isn't supplied, and one is needed, it is generated using one of the URL types in the
 Info.plist. This sometimes works, though many services expect you to pass the same callback URL you specify
 in the application information on their site.
 
 As a note, Twitter, Readability work fine with the generated callbackURL.
 
 Facebook expects the URL to have a callback URL of fb[App ID]://authorize/ for the website or 
 fb[App ID]://authorize for authorizing against their iOS app.
 */
@property (nonatomic, copy) NSURL *callbackURL;

/** Authenticate the account. 
 
 Different subclasses will authenticate differently, in the case of OAuth and OAuth 2.0, this
 will cause Safari to open for the user to login. 
 
 @param handler This handler is called when the authentication succeeds or fails. In the case 
 of multiple resquests, the reponses dictionary will contain the responses of each stage of 
 authentication. This means the responses can contain values, even if the authentication fails.
 You should check the error value to see if there was an error. 

 @see [DCTAuth handleURL:] */
- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler;

- (void)cancelAuthentication;

@property (nonatomic, copy) NSDictionary *userInfo;

//- (void)renewCredentialsWithHandler:(void(^)(BOOL success, NSError *error))handler;

/// @name Method for subclasses to call

/** Initializer for DCTAuthAccount, subclasses should call this method to initialize.
 @param type The type of the account.
 @return The newly initialized object.
 @see type */
- (id)initWithType:(NSString *)type __attribute((objc_requires_super));

@end

@class DCTAuthRequest;
