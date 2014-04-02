//
//  NSDictionary+DCTAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSDictionary+DCTAuth.h"
#import "NSString+DCTAuth.h"

@implementation NSDictionary (DCTAuth)

- (NSString *)dctAuth_queryString {
	
	if ([self count] == 0) return nil;
	
	NSMutableArray *parameterStrings = [NSMutableArray new];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {

		key = [key description];

		if ([object isKindOfClass:[NSArray class]]) {
			for (id value in object) {
				NSString *parameterString = [NSString stringWithFormat:@"%@=%@", key, [value description]];
				[parameterStrings addObject:parameterString];
			}
		} else {
			NSString *parameterString = [NSString stringWithFormat:@"%@=%@", key, [object description]];
			[parameterStrings addObject:parameterString];
		}

	}];

	return [parameterStrings componentsJoinedByString:@"&"];
}

- (NSData *)dctAuth_bodyFormDataUsingEncoding:(NSStringEncoding)encoding {
	
	if ([self count] == 0) return nil;
	
	NSMutableArray *parameterStrings = [NSMutableArray new];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		NSString *encodedKey = [[key description] dctAuth_bodyFormEncodedString];
		NSString *encodedValue = [[value description] dctAuth_bodyFormEncodedString];
		NSString *parameterString = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
		[parameterStrings addObject:parameterString];
	}];
	NSString *bodyFormString = [parameterStrings componentsJoinedByString:@"&"];
	return [bodyFormString dataUsingEncoding:encoding];
}

@end
