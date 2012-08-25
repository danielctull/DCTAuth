//
//  NSString+DCTOAuthController.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSString+DCTOAuthController.h"

@implementation NSString (DCTOAuthController)

- (NSString *)dctOAuthController_URLEncodedString {
	
	return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
																				  (CFStringRef)objc_unretainedPointer(self),
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
}

@end
