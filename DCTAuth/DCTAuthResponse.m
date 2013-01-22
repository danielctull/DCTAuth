//
//  DCTAuthResponse.m
//  DCTAuth
//
//  Created by Daniel Tull on 22.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthResponse.h"
#import "NSString+DCTAuth.h"

@implementation DCTAuthResponse

- (id)initWithData:(NSData *)data URLResponse:(NSHTTPURLResponse *)response {
	self = [self init];
	if (!self) return nil;
	_data = data;
	_HTTPHeaders = response.allHeaderFields;
	return self;
}

- (id)initWithURL:(NSURL *)URL {
	self = [self init];
	if (!self) return nil;
	_URL = [URL copy];

	NSMutableDictionary *content = [NSMutableDictionary new];
	[content addEntriesFromDictionary:[[URL query] dctAuth_parameterDictionary]];
	[content addEntriesFromDictionary:[[URL fragment] dctAuth_parameterDictionary]];
	_contentObject = [content copy];
	
	return self;
}

@end
