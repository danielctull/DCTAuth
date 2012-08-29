//
//  _DCTOAuthSignature.h
//  DCTAuth
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthRequest.h"

typedef enum {
	_DCTOAuthSignatureTypeHMAC_SHA1 = 0
} _DCTOAuthSignatureType;

@interface _DCTOAuthSignature : NSObject

- (id)initWithURL:(NSURL *)URL
	   HTTPMethod:(NSString *)HTTPMethod
   consumerSecret:(NSString *)consumerSecret
	  secretToken:(NSString *)secretToken
	   parameters:(NSDictionary *)parameters;

@property (nonatomic, assign) _DCTOAuthSignatureType type;

- (NSString *)authorizationHeader;

@end
