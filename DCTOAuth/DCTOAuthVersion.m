//
//  DCTOAuthVersion.m
//  DCTOAuth
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthVersion.h"

NSString * const DCTOAuthVersionString[] = {
	@"1.0",
	@"2.0"
};

NSString * NSStringFromDCTOAuthVersion(DCTOAuthVersion version) {
	return DCTOAuthVersionString[version];
}
