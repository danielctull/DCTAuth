//
//  DCTOAuth1Account.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTOAuthSignatureType.h"
#import "DCTOAuth1ParameterTransmission.h"
#import "DCTOAuth1Credential.h"

@interface DCTOAuth1Account : DCTAuthAccount

/**
 *  Creates an account using OAuth using a HMAC-SHA1 signature type and Authorization header transmission.
 *
 *  @param type The type of the account.
 *  @param requestTokenURL The URL to retrieve the OAuth request token.
 *  @param authorizeURL The URL to perform the OAuth authorization.
 *  @param accessTokenURL The URL to retrieve the OAuth access token.
 *  @param consumerKey The consumer key for the app.
 *  @param consumerSecret The consumer secret for the app.
 *
 *  @return Newly initialized account.
 */
- (instancetype)initWithType:(NSString *)type
			 requestTokenURL:(NSURL *)requestTokenURL
				authorizeURL:(NSURL *)authorizeURL
			  accessTokenURL:(NSURL *)accessTokenURL
				 consumerKey:(NSString *)consumerKey
			  consumerSecret:(NSString *)consumerSecret;

/**
 *  Creates an account using OAuth.
 *
 *  @param type The type of the account.
 *  @param requestTokenURL The URL to retrieve the OAuth request token.
 *  @param authorizeURL The URL to perform the OAuth authorization.
 *  @param accessTokenURL The URL to retrieve the OAuth access token.
 *  @param consumerKey The consumer key for the app.
 *  @param consumerSecret The consumer secret for the app.
 *  @param signatureType The signature type to use, either DCTOAuthSignatureTypeHMAC_SHA1 or DCTOAuthSignatureTypePlaintext.
 *  @param parameterTransmission The transmission type , either DCTOAuth1ParameterTransmissionAuthorizationHeader or DCTOAuth1ParameterTransmissionURLQuery.
 *
 *  @return Newly initialized account.
 */
- (instancetype)initWithType:(NSString *)type
			 requestTokenURL:(NSURL *)requestTokenURL
				authorizeURL:(NSURL *)authorizeURL
			  accessTokenURL:(NSURL *)accessTokenURL
				 consumerKey:(NSString *)consumerKey
			  consumerSecret:(NSString *)consumerSecret
			   signatureType:(DCTOAuthSignatureType)signatureType
	   parameterTransmission:(DCTOAuth1ParameterTransmission)parameterTransmission;

/** The request token URL. */
@property (nonatomic, readonly) NSURL *requestTokenURL;

/** The authorization URL. */
@property (nonatomic, readonly) NSURL *authorizeURL;

/** The access token URL. */
@property (nonatomic, readonly) NSURL *accessTokenURL;

/** The consumer key. */
@property (nonatomic, readonly) NSString *consumerKey;

/** The consumer secret. */
@property (nonatomic, readonly) NSString *consumerSecret;

/** The signature type. */
@property (nonatomic, readonly) DCTOAuthSignatureType signatureType;

/** The method of transmission for the paramters. */
@property (nonatomic, readonly) DCTOAuth1ParameterTransmission parameterTransmission;

/** The credential for the account. */
@property (nonatomic) DCTOAuth1Credential *credential;

@end
