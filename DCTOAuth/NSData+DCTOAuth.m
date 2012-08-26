//
//  NSData+DCTOAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSData+DCTOAuth.h"
#import <resolv.h>

@implementation NSData (DCTOAuth)

- (NSData *)dctOAuth_base64EncodedData {
	
	NSData *encodedData = nil;
	NSData *dataToEncode = self;
	
	NSUInteger dataToEncodeLength = dataToEncode.length;
	
	// Last +1 below to accommodate trailing '\0':
	NSUInteger encodedBufferLength = ((dataToEncodeLength + 2) / 3) * 4 + 1;
	
	char *encodedBuffer = malloc(encodedBufferLength);
	
	int encodedRealLength = b64_ntop(dataToEncode.bytes, dataToEncodeLength, encodedBuffer, encodedBufferLength);
	
	if(encodedRealLength >= 0) {
		// In real life, you might not want the nul-termination byte, so you
		// might not want the '+ 1'.
		encodedData = [NSData dataWithBytes:encodedBuffer
									 length:encodedRealLength/* + 1 */];
	}
	
	free(encodedBuffer);
	
	return encodedData;
}

@end
