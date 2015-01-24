//
//  DCTAuthRequestJSONBody.m
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequestJSONBody.h"

@implementation DCTAuthRequestJSONBody
@synthesize HTTPBody = _HTTPBody;

- (instancetype)initWithJSONObject:(id<NSCopying>)JSON {

	NSParameterAssert(JSON);

	self = [super init];
	if (!self) return nil;

	_JSON = JSON;
	_HTTPBody = [NSJSONSerialization dataWithJSONObject:JSON options:(NSJSONWritingOptions)0 error:NULL];
	if (!_HTTPBody) {
		return nil;
	}

	return self;
}

#pragma mark - DCTAuthRequestBody

- (NSDictionary *)HTTPHeaderFields {
	return @{
		@"Content-Type" : @"application/json",
		@"Content-Length" : @(self.HTTPBody.length)
	};
}

@end
