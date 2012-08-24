//
//  DTOAuthSignature.m
//  DCTConnectionKit
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTOAuthSignature.h"
#import <CommonCrypto/CommonHMAC.h>
#import <resolv.h>

NSString * const DTOAuthSignatureTypeString[] = {
	@"HMAC-SHA1",
	@"PLAINTEXT"
};

@implementation DCTOAuthSignature

- (NSString *)method {
	return DTOAuthSignatureTypeString[DCTOAuthSignatureTypeHMAC_SHA1];
	
	// PLAIN TEXT NOT WORKING
	return DTOAuthSignatureTypeString[self.type];
}

- (NSString *)typeString {
	return self.method;
}

- (NSString *)signature {
		
	NSData *secretData = [self.secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *textData = [self.text dataUsingEncoding:NSUTF8StringEncoding];
	
	unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, textData.bytes, textData.length, result);
	
	NSData *theData = [NSData dataWithBytes:result length:20];
	NSData *base64EncodedData = [self _base64EncodedData:theData];
	NSString *string = [[NSString alloc] initWithData:base64EncodedData encoding:NSUTF8StringEncoding];
	return [self _URLEncodedString:string];
}

- (NSData *)_base64EncodedData:(NSData *)dataToEncode {
	
	NSData *encodedData = nil;
	
	NSUInteger dataToEncodeLength = dataToEncode.length;
	
	// Last +1 below to accommodate trailing '\0':
	NSUInteger encodedBufferLength = ((dataToEncodeLength + 2) / 3) * 4 + 1;
	
	char *encodedBuffer = malloc(encodedBufferLength);
	
	int encodedRealLength = b64_ntop(dataToEncode.bytes, dataToEncodeLength,
									 encodedBuffer, encodedBufferLength);
	
	if(encodedRealLength >= 0) {
		// In real life, you might not want the nul-termination byte, so you
		// might not want the '+ 1'.
		encodedData = [NSData dataWithBytesNoCopy:encodedBuffer
										   length:encodedRealLength + 1
									 freeWhenDone:YES];
	} else {
		free(encodedBuffer);
	}
	
	return encodedData;
}

- (NSString *)_URLEncodedString:(NSString *)string {
	
	return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
																				  (CFStringRef)objc_unretainedPointer(string),
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
}





@end
