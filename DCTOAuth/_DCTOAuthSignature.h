//
//  DTOAuthSignature.h
//  DCTConnectionKit
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthRequestMethod.h"

typedef enum {
	DCTOAuthSignatureTypeHMAC_SHA1 = 0
} DCTOAuthSignatureType;

@interface _DCTOAuthSignature : NSObject

- (id)initWithURL:(NSURL *)URL
	requestMethod:(DCTOAuthRequestMethod)requestMethod
	  consumerKey:(NSString *)consumerKey
   consumerSecret:(NSString *)consumerSecret
			token:(NSString *)token
	  secretToken:(NSString *)secretToken
	   parameters:(NSDictionary *)parameters;


@property (nonatomic, readonly) NSDictionary *parameters;

@property (nonatomic, assign) DCTOAuthSignatureType type;

- (NSString *)signedString;

@end
