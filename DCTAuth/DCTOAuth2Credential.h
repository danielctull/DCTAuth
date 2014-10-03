//
//  DCTOAuth2Credential.h
//  DCTAuth
//
//  Created by Daniel Tull on 23/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountCredential.h"

@interface DCTOAuth2Credential : NSObject <DCTAuthAccountCredential>

- (instancetype)initWithClientID:(NSString *)clientID
					clientSecret:(NSString *)clientSecret
						password:(NSString *)password
					 accessToken:(NSString *)accessToken
					refreshToken:(NSString *)refreshToken;

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSString *clientSecret;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *refreshToken;

@end
