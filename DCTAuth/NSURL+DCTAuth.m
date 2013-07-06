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

static NSString * const _DCTAuthStartStringForComponentType[] = {
	@"", // 0
	@"", // kCFURLComponentScheme = 1
	@"", // kCFURLComponentNetLocation = 2
	@"", // kCFURLComponentPath = 3
	@"", // kCFURLComponentResourceSpecifier = 4
	@"", // kCFURLComponentUser = 5
	@":", // kCFURLComponentPassword = 6
	@"", // kCFURLComponentUserInfo = 7
	@"", // kCFURLComponentHost = 8
	@":", // kCFURLComponentPort = 9
	@"", // kCFURLComponentParameterString = 10
	@"?", // kCFURLComponentQuery = 11
	@"#" // kCFURLComponentFragment = 12
};

static NSString * const _DCTAuthEndStringForComponentType[] = {
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

	if ([NSURLComponents class]) {
		NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
		components.percentEncodedUser = user;
		components.percentEncodedPassword = password;
		return components.URL;
	}

	NSURL *URL = [self dctAuth_URLByReplacingComponentType:kCFURLComponentUser withString:user];
	return [URL dctAuth_URLByReplacingComponentType:kCFURLComponentPassword withString:password];
}

- (NSURL *)dctAuth_URLByAddingQueryParameters:(NSDictionary *)parameters {

	NSDictionary *existingQuery = [[self query] dctAuth_parameterDictionary];
	NSMutableDictionary *queryParameters = [NSMutableDictionary new];
	[queryParameters addEntriesFromDictionary:existingQuery];
	[queryParameters addEntriesFromDictionary:parameters];
	NSString *query = [queryParameters dctAuth_queryString];

	if ([NSURLComponents class]) {
		NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
		components.percentEncodedQuery = query;
		return components.URL;
	}

	return [self dctAuth_URLByReplacingComponentType:kCFURLComponentQuery
										  withString:query];
}

- (NSURL *)dctAuth_URLByRemovingComponentType:(CFURLComponentType)componentType {
	NSString *URLString = [self absoluteString];
	NSRange range = [self dctAuth_rangeForComponent:componentType fullRange:NULL];
	if (range.location == NSNotFound) return self;
	NSString *start = _DCTAuthStartStringForComponentType[componentType];
	NSString *end = _DCTAuthEndStringForComponentType[componentType];
	range.location -= start.length;
	range.length += start.length + end.length;
	URLString = [URLString stringByReplacingCharactersInRange:range withString:@""];
	return [NSURL URLWithString:URLString];
}

- (NSURL *)dctAuth_URLByReplacingComponentType:(CFURLComponentType)componentType
									withString:(NSString *)string {

	if ([string length] == 0) return self;

	NSRange fullRange;
	NSRange range = [self dctAuth_rangeForComponent:componentType fullRange:&fullRange];
	if (range.location == NSNotFound) {
		string = [_DCTAuthStartStringForComponentType[componentType] stringByAppendingString:string];
		string = [string stringByAppendingString:_DCTAuthEndStringForComponentType[componentType]];
		range = fullRange;
	}

	NSString *URLString = [self absoluteString];
	URLString = [URLString stringByReplacingCharactersInRange:range withString:string];
	return [NSURL URLWithString:URLString];
}

- (NSRange)dctAuth_rangeForComponent:(CFURLComponentType)component fullRange:(NSRange*)fullRange {
	CFURLRef cfURL = CFURLCopyAbsoluteURL((__bridge CFURLRef)self);
	CFRange cfFullRange = CFRangeMake(0, 0);
	CFRange cfRange = CFURLGetByteRangeForComponent(cfURL, component, &cfFullRange);
	CFRelease(cfURL);
	if (fullRange != NULL) *fullRange = DCTAuthMakeNSRangeFromCFRange(cfFullRange);
	return DCTAuthMakeNSRangeFromCFRange(cfRange);
}

@end
