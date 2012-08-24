//
//  DCTOAuthRequest.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthRequest.h"
#import "_DCTOAuthRequestMethod.h"

@implementation DCTOAuthRequest {
	__strong NSURL *_URL;
	__strong DCTOAuthSignature *_signature;
	DCTOAuthRequestMethod _method;
}

- (id)initWithURL:(NSURL *)URL
		   method:(DCTOAuthRequestMethod)method
		signature:(DCTOAuthSignature *)signature {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_signature = signature;
	_method = method;
	
	return self;
}

- (NSURLRequest *)signedRequest {
	
	NSMutableArray *parameters = [NSMutableArray new];
	[_signature.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		NSString *string = [NSString stringWithFormat:@"%@=\"%@\"", [self _URLEncodedString:key], [self _URLEncodedString:value]];
		[parameters addObject:string];
	}];
	
	NSString *string = [NSString stringWithFormat:@"oauth_signature=\"%@\"", [_signature signedString]];
	[parameters addObject:string];
	NSString *parameterString = [parameters componentsJoinedByString:@","];
		
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_URL];
	[request setHTTPMethod:DCTOAuthRequestMethodString[_method]];
	[request setAllHTTPHeaderFields:@{ @"Authorization" : [NSString stringWithFormat:@"OAuth %@", parameterString]}];
	return request;
}

- (NSString *)_URLEncodedString:(NSString *)string {
	
	return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
																				  (CFStringRef)objc_unretainedPointer(string),
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
}

@end
