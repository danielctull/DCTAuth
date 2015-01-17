//
//  DCTOAuth1Account.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"

@interface DCTOAuth1Account : DCTAuthAccount

- (instancetype)initWithType:(NSString *)type
			 requestTokenURL:(NSURL *)requestTokenURL
				authorizeURL:(NSURL *)authorizeURL
			  accessTokenURL:(NSURL *)accessTokenURL
				 consumerKey:(NSString *)consumerKey
			  consumerSecret:(NSString *)consumerSecret
			   signatureType:(DCTOAuthSignatureType)signatureType
	   parameterTransmission:(DCTOAuthParameterTransmission)parameterTransmission;

@end
