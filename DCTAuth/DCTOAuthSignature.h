//
//  DCTOAuthSignature.h
//  DCTAuth
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequest.h"

@interface DCTOAuthSignature : NSObject

- (instancetype)initWithURL:(NSURL *)URL
	   HTTPMethod:(NSString *)HTTPMethod
   consumerSecret:(NSString *)consumerSecret
	  secretToken:(NSString *)secretToken
	   parameters:(NSDictionary *)parameters
			 type:(DCTOAuthSignatureType)type;

@property (nonatomic, readonly) DCTOAuthSignatureType type;

- (NSString *)authorizationHeader;

- (NSString *)signatureBaseString;
- (NSString *)signatureString;

@end
