//
//  DCTOAuthSignature.h
//  DCTAuth
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"

@interface DCTOAuthSignature : NSObject

- (instancetype)initWithURL:(NSURL *)URL
				 HTTPMethod:(NSString *)HTTPMethod
			 consumerSecret:(NSString *)consumerSecret
				secretToken:(NSString *)secretToken
				 parameters:(NSDictionary *)parameters
					   type:(DCTOAuthSignatureType)type;

@property (nonatomic, readonly) NSString *authorizationHeader;
@property (nonatomic, readonly) NSString *signatureBaseString;
@property (nonatomic, readonly) NSString *signatureString;

@end
