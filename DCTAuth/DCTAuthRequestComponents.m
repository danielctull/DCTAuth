//
//  DCTAuthRequestComponents.m
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequestComponents.h"
#import "DCTAuthRequestBody.h"

@interface DCTAuthRequestComponents ()
@property (nonatomic, readonly) NSURLRequest *originalRequest;
@end

@implementation DCTAuthRequestComponents

- (instancetype)initWithRequest:(NSURLRequest *)request {
	self = [super init];
	if (!self) return nil;
	_originalRequest = request;
	return self;
}

- (NSURLRequest *)request {

	NSMutableURLRequest *request = [self.originalRequest mutableCopy];

	request.HTTPMethod = NSStringFromDCTAuthRequestMethod(self.requestMethod);
	request.HTTPBody = [self.body HTTPBody];

	NSMutableDictionary *HTTPHeaderFields = [NSMutableDictionary new];
	[HTTPHeaderFields addEntriesFromDictionary:self.request.allHTTPHeaderFields];
	[HTTPHeaderFields addEntriesFromDictionary:self.body.HTTPHeaderFields];
	request.allHTTPHeaderFields = HTTPHeaderFields;

	return [request copy];
}

@end
