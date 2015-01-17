//
//  DCTAuthAccountStoreProperties.h
//  DCTAuth
//
//  Created by Daniel Tull on 17.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;

extern const struct DCTAuthAccountStoreProperties {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *accessGroup;
	__unsafe_unretained NSString *synchronizable;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *accounts;
} DCTAuthAccountStoreProperties;
