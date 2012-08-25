//
//  DCTOAuthVersion.h
//  DCTOAuth
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	DCTOAuthVersion1_0,
	DCTOAuthVersion2_0
} DCTOAuthVersion;

NSString * NSStringFromDCTOAuthVersion(DCTOAuthVersion version);
