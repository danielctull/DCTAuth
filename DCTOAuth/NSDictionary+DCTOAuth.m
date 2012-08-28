//
//  NSDictionary+DCTOAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSDictionary+DCTOAuth.h"
#import "NSString+DCTOAuth.h"

@implementation NSDictionary (DCTOAuth)

- (NSString *)dctOAuth_queryString {
	
	if ([self count] == 0) return nil;
	
	NSMutableArray *parameterStrings = [NSMutableArray new];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		NSString *encodedKey = [[key description] dctOAuth_URLEncodedString];
		NSString *encodedValue = [[value description] dctOAuth_URLEncodedString];
		NSString *parameterString = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
		[parameterStrings addObject:parameterString];
	}];
	return [parameterStrings componentsJoinedByString:@"&"];
}

- (NSData *)dctOAuth_bodyFormDataUsingEncoding:(NSStringEncoding)encoding {
	
	if ([self count] == 0) return nil;
	
	NSMutableArray *parameterStrings = [NSMutableArray new];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		NSString *parameterString = [NSString stringWithFormat:@"%@=%@", key, value];
		[parameterStrings addObject:parameterString];
	}];
	NSString *bodyFormString = [parameterStrings componentsJoinedByString:@"&"];
	return [bodyFormString dataUsingEncoding:encoding];
}

@end
