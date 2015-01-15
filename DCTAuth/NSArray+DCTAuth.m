//
//  NSArray+DCTAuth.m
//  DCTAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSArray+DCTAuth.h"
#import "NSString+DCTAuth.h"

@implementation NSArray (DCTAuth)

- (NSData *)dctAuth_formDataUsingEncoding:(NSStringEncoding)encoding {
	
	if ([self count] == 0) return nil;

	NSMutableArray *parameterStrings = [NSMutableArray new];
	for (NSURLQueryItem *item in self) {
		NSString *encodedKey = [item.name dctAuth_bodyFormEncodedString];
		NSString *encodedValue = [item.value dctAuth_bodyFormEncodedString];
		NSString *parameterString = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
		[parameterStrings addObject:parameterString];
	}
	
	NSString *bodyFormString = [parameterStrings componentsJoinedByString:@"&"];
	return [bodyFormString dataUsingEncoding:encoding];
}

- (NSData *)dctAuth_JSONDataUsingEncoding:(NSStringEncoding)encoding {
	NSDictionary *dictionary = [self dctAuth_lossyDictionary];
	return [NSJSONSerialization dataWithJSONObject:dictionary options:(NSJSONWritingOptions)0 error:NULL];
}

- (NSData *)dctAuth_plistDataUsingEncoding:(NSStringEncoding)encoding {
	NSDictionary *dictionary = [self dctAuth_lossyDictionary];
	return [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
}

- (NSDictionary *)dctAuth_lossyDictionary {
	NSMutableDictionary *JSON = [NSMutableDictionary new];
	for (NSURLQueryItem *item in self) {
		if (item.name && item.value) {
			JSON[item.name] = item.value;
		}
	}
	return JSON;
}

@end
