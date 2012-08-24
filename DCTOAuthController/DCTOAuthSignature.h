//
//  DTOAuthSignature.h
//  DCTConnectionKit
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DCTOAuthSignatureTypeHMAC_SHA1 = 0
} DCTOAuthSignatureType;

@interface DCTOAuthSignature : NSObject

@property (nonatomic, assign) DCTOAuthSignatureType type;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly) NSString *signature;
@property (nonatomic, readonly) NSString *method;

- (NSString *)typeString;
@end
