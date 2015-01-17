//
//  DCTOAuthSignature.h
//  DCTAuth
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

@import Foundation;
#import "DCTOAuthSignatureType.h"

@interface DCTOAuthSignature : NSObject

- (instancetype)initWithURL:(NSURL *)URL
				 HTTPMethod:(NSString *)HTTPMethod
			 consumerSecret:(NSString *)consumerSecret
				secretToken:(NSString *)secretToken
					  items:(NSArray *)items
					   type:(DCTOAuthSignatureType)type;

- (instancetype)initWithURL:(NSURL *)URL
				 HTTPMethod:(NSString *)HTTPMethod
			 consumerSecret:(NSString *)consumerSecret
				secretToken:(NSString *)secretToken
					  items:(NSArray *)items
					   type:(DCTOAuthSignatureType)type
				  timestamp:(NSString *)timestamp
					  nonce:(NSString *)nonce;

@property (nonatomic, readonly) NSString *authorizationHeader;
@property (nonatomic, readonly) NSArray *authorizationItems;

@property (nonatomic, readonly) NSString *signatureBaseString;
@property (nonatomic, readonly) NSString *signatureString;

@end
