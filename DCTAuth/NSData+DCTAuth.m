//
//  NSData+DCTAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSData+DCTAuth.h"

@implementation NSData (DCTAuth)

- (NSString *)dctAuth_base64EncodedString {
	
	if ([self respondsToSelector:@selector(base64EncodedDataWithOptions:)])
		return [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	return [self base64Encoding];
#pragma clang diagnostic pop
}

@end
