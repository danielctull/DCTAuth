//
//  NSURL+DCTAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSURL+DCTAuth.h"
#import "NSString+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"

NSRange DCTAuthMakeNSRangeFromCFRange(CFRange range) {
	return NSMakeRange(range.location == kCFNotFound ? NSNotFound : range.location, range.length);
}

NSString * const _DCTAuthStartStringForComponentType[] = {
	@"", // 0
	@"", // kCFURLComponentScheme = 1
	@"", // kCFURLComponentNetLocation = 2
	@"", // kCFURLComponentPath = 3
	@"", // kCFURLComponentResourceSpecifier = 4
	@"", // kCFURLComponentUser = 5
	@":", // kCFURLComponentPassword = 6
	@"", // kCFURLComponentUserInfo = 7
	@"", // kCFURLComponentHost = 8
	@"", // kCFURLComponentPort = 9
	@"", // kCFURLComponentParameterString = 10
	@"?", // kCFURLComponentQuery = 11
	@"#" // kCFURLComponentFragment = 12
};

NSString * const _DCTAuthEndStringForComponentType[] = {
	@"", // 0
	@"://", // kCFURLComponentScheme = 1
	@"", // kCFURLComponentNetLocation = 2
	@"", // kCFURLComponentPath = 3
	@"", // kCFURLComponentResourceSpecifier = 4
	@"@", // kCFURLComponentUser = 5
	@"", // kCFURLComponentPassword = 6
	@"", // kCFURLComponentUserInfo = 7
	@"", // kCFURLComponentHost = 8
	@"", // kCFURLComponentPort = 9
	@"", // kCFURLComponentParameterString = 10
	@"", // kCFURLComponentQuery = 11
	@"" // kCFURLComponentFragment = 12
};

@implementation NSURL (DCTAuth)

- (NSURL *)dctAuth_URLBySettingUser:(NSString *)user password:(NSString *)password {
	NSURL *URL = [self dctAuth_URLByReplacingComponentType:kCFURLComponentUser withString:user];
	return [URL dctAuth_URLByReplacingComponentType:kCFURLComponentPassword withString:password];
}

- (NSURL *)dctAuth_URLByAddingQueryParameters:(NSDictionary *)parameters {

	NSDictionary *existingQuery = [[self query] dctAuth_parameterDictionary];
	NSMutableDictionary *query = [NSMutableDictionary new];
	[query addEntriesFromDictionary:existingQuery];
	[query addEntriesFromDictionary:parameters];
	return [self dctAuth_URLByReplacingComponentType:kCFURLComponentQuery
										  withString:[query dctAuth_queryString]];
}

- (NSURL *)dctAuth_URLByReplacingComponentType:(CFURLComponentType)componentType
									withString:(NSString *)string {

	CFURLRef cfURL = (__bridge CFURLRef)self;
	CFRange cfFullRange = CFRangeMake(0, 0);
	CFRange cfRange = CFURLGetByteRangeForComponent(cfURL, componentType, &cfFullRange);

	if (cfRange.location == kCFNotFound) {
		string = [_DCTAuthStartStringForComponentType[componentType] stringByAppendingString:string];
		string = [string stringByAppendingString:_DCTAuthEndStringForComponentType[componentType]];
		cfRange = cfFullRange;
	}

	NSString *URLString = [self absoluteString];
	NSRange range = DCTAuthMakeNSRangeFromCFRange(cfRange);
	URLString = [URLString stringByReplacingCharactersInRange:range withString:string];
	return [NSURL URLWithString:URLString];
}

@end
