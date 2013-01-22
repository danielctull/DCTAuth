//
//  DCTAuthResponse.m
//  DCTAuth
//
//  Created by Daniel Tull on 22.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthResponse.h"

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
	
	return self;
}

@end
