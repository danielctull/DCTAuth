//
//  DCTAuthRequestMethod.h
//  DCTAuth
//
//  Created by Daniel Tull on 21.10.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

@import Foundation;

typedef enum : NSUInteger {
	DCTAuthRequestMethodGET,
	DCTAuthRequestMethodPOST,
	DCTAuthRequestMethodDELETE,
	DCTAuthRequestMethodHEAD,
	DCTAuthRequestMethodPUT
} DCTAuthRequestMethod;

NSString * NSStringFromDCTAuthRequestMethod(DCTAuthRequestMethod method);
