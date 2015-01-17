//
//  DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

@import Foundation;
@class DCTAuthResponse;
@protocol DCTAuthAccountCredential;

extern const struct DCTAuthAccountProperties {
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *accountDescription;
	__unsafe_unretained NSString *callbackURL;
	__unsafe_unretained NSString *shouldSendCallbackURL;
	__unsafe_unretained NSString *userInfo;
	__unsafe_unretained NSString *saveUUID;
	__unsafe_unretained NSString *extraItems;
} DCTAuthAccountProperties;



extern const struct DCTOAuth2RequestType {
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *authorize;
	__unsafe_unretained NSString *refresh;
	__unsafe_unretained NSString *signing;
} DCTOAuth2RequestType;



/** 
 *  A DCTAuthAccount object encapsulates information about a user account
 *  stored in the database. You can create and retrieve accounts using an 
 *  DCTAuthAccountStore object. The DCTAuthAccountStore object provides an 
 *  interface to the persistent database. All account objects belong to a 
 *  single DCTAuthAccountStore object.
 */
@interface DCTAuthAccount : NSObject <NSCoding>

/// @name Accessing Properties

/**
 *  The type of service account, which is user defined at the creation of an account.
 *
 *  Once set for an account, it will always be the same and can be used to lookup accounts
 *  for a particular service. It is currently not used for any other purpose.
 *
 *  @see -[DCTAuthAccountStore accountsWithType:]
 */
@property (nonatomic, readonly) NSString *type;

/**
 *  A unique identifier for this account.
 *
 *  This identifier is random and assigned when the account is created.
 *
 *  Use the -[DCTAuthAccountStore accountWithIdentifier:] method to get an account with the specified identifier.
 *
 *  @see -[DCTAuthAccountStore accountWithIdentifier:]
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 *  Shows if the account is authorized.
 *
 *  @see authenticateWithHandler: 
 */
@property (nonatomic, readonly, getter = isAuthorized) BOOL authorized;

@property (nonatomic) id<DCTAuthAccountCredential> credential;

/** 
 *  A human-readable description of the account.
 */
@property (nonatomic, copy) NSString *accountDescription;

/// @name Authentication

/** 
 *  The URL the OAuth authorization process will call back to.
 *
 *  Facebook expects the URL to have a callback URL of fb[App ID]://authorize/ for the website or
 *  fb[App ID]://authorize for authorizing against their iOS app.
 *
 *  @see shouldSendCallbackURL
 */
@property (nonatomic, copy) NSURL *callbackURL;

/**
 *  When authenticating, if this is yes the callbackURL will be sent in requests.
 *
 *  Defaults to NO.
 */
@property (nonatomic) BOOL shouldSendCallbackURL;

/**
 *  Authenticate the account.
 *
 *  Different subclasses will authenticate differently, in the case of OAuth and OAuth 2.0, this
 *  will cause Safari to open for the user to login.
 *
 *  @param handler This handler is called when the authentication succeeds or fails. In the case
 *  of multiple resquests, the reponses dictionary will contain the responses of each stage of
 *  authentication. This means the responses can contain values, even if the authentication fails.
 *  You should check the error value to see if there was an error.
 *
 *  @see [DCTAuth handleURL:]
 *  @see reauthenticateWithHandler:
 */
- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler;


/** 
 *  This will cause the account to refresh its credentials if it supports it, eg OAuth2.
 *  Otherwise this calls the handler with a nil response and an error, you should probably then
 *  call -authenticateWithHandler.
 *
 *  For included account types, this method  never require user input and never attempt
 *  to open a WebView. For your own DCTAuthAccount subclasses, you should adhere to the same principles
 *  and use this as a headless method.
 *
 *  If you use -[DCTAuthRequest performRequestWithHandler:] it will automatically call this method
 *  if there is an error and if it succeds, will attempt to perform the request again before 
 *  calling its completion handler.
 * 
 *  @see authenticateWithHandler:
 */
- (void)reauthenticateWithHandler:(void(^)(DCTAuthResponse *response, NSError *error))handler;

- (void)cancelAuthentication;

/// @name Extra Parameters

- (NSArray *)itemsForRequestType:(NSString *)requestType;

/** Allows users to set extra NSQueryItems for a particular request type.
 *
 *  Currently the OAuth 2 accounts are the only ones to make use of these extra items. (See the DCTOAuth2RequestType struct) 
 */
- (void)setItems:(NSArray *)items forRequestType:(NSString *)requestType;

@property (nonatomic, copy) NSDictionary *userInfo;

/// @name Method for subclasses to call

/** 
 *  Initializer for DCTAuthAccount, subclasses should call this method to initialize.
 *
 *  @param type The type of the account.
 *  @return The newly initialized object.
 *  @see type 
 */
- (instancetype)initWithType:(NSString *)type __attribute((objc_requires_super));

@end
