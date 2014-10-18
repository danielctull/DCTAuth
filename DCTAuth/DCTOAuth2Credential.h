//
//  DCTOAuth2Credential.h
//  DCTAuth
//
//  Created by Daniel Tull on 23/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountCredential.h"

typedef NS_ENUM(NSInteger, DCTOAuth2CredentialType) {
	DCTOAuth2CredentialTypeParamter,
	DCTOAuth2CredentialTypeBearer
};

@interface DCTOAuth2Credential : NSObject <DCTAuthAccountCredential>

- (instancetype)initWithClientID:(NSString *)clientID
					clientSecret:(NSString *)clientSecret
						password:(NSString *)password
					 accessToken:(NSString *)accessToken
					refreshToken:(NSString *)refreshToken
							type:(DCTOAuth2CredentialType)type;

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSString *clientSecret;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *refreshToken;
@property (nonatomic, readonly) DCTOAuth2CredentialType type;

@end
