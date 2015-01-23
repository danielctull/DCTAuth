//
//  DCTAuthContent.m
//  DCTAuth
//
//  Created by Daniel Tull on 23.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthContent.h"
#import "NSString+DCTAuth.h"

@implementation DCTAuthContent

- (instancetype)initWithRequest:(NSURLRequest *)request {
	self = [super init];
	if (!self) return nil;

	_HTTPBody = request.HTTPBody;
	_contentType = request.allHTTPHeaderFields[@"Content-Type"];

	if (_contentType) {
		NSArray *contentTypeStrings = [DCTAuthContent contentTypeStrings];
		NSString *contentTypeString = [_contentType stringByReplacingOccurrencesOfString:@" " withString:@""];
		NSArray *components = [contentTypeString componentsSeparatedByString:@";"];
		for (NSString *contentType in components) {

			if ([contentType hasPrefix:@"charset="]) {
				NSString *charset = [contentType stringByReplacingCharactersInRange:NSMakeRange(0, 8) withString:@""];
				if (charset.length == 0) {

				} else {
					CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)charset);
					_encoding = CFStringConvertEncodingToNSStringEncoding(encoding);
				}
			} else {
				if ([contentTypeStrings containsObject:contentType]) {
					_type = [contentTypeStrings indexOfObject:contentType];
				}
			}
		}

		switch (_type) {
			case DCTAuthContentTypeForm: {

				NSString *contentString = [[NSString alloc] initWithData:_HTTPBody encoding:_encoding];
				NSArray *itemStrings = [contentString componentsSeparatedByString:@"&"];
				NSMutableArray *items = [NSMutableArray new];
				for (NSString *itemString in itemStrings) {
					NSArray *itemStringStrings = [itemString componentsSeparatedByString:@"="];
					if (itemStringStrings.count == 2) {
						NSString *encodedKey = [itemStringStrings firstObject];
						NSString *encodedValue = [itemStringStrings lastObject];
						NSString *key = [encodedKey dctAuth_bodyFormDecodedString];
						NSString *value = [encodedValue dctAuth_bodyFormDecodedString];
						NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
						[items addObject:item];
					}
				}
				_items = [items copy];

				break;
			}

			case DCTAuthContentTypeJSON: {

				NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:_HTTPBody options:(NSJSONReadingOptions)0 error:NULL];
				NSMutableArray *items = [NSMutableArray new];
				[JSON enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
					NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
					[items addObject:item];
				}];
				_items = [items copy];
				break;
			}
		}

	}

	return self;
}

- (instancetype)initWithEncoding:(NSStringEncoding)encoding
							type:(DCTAuthContentType)type
						   items:(NSArray *)items {
	self = [self init];
	if (!self) return nil;
	_type = type;
	_items = [items copy];
	_encoding = encoding;

	NSString *contentType = [[DCTAuthContent contentTypeStrings] objectAtIndex:type];
	NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName((CFStringEncoding)encoding);
	_contentType = [NSString stringWithFormat:@"%@; charset=%@", contentType, charset];

	switch (type) {
		case DCTAuthContentTypeForm: {

			NSMutableArray *parameterStrings = [NSMutableArray new];
			for (NSURLQueryItem *item in items) {
				NSString *encodedKey = [item.name dctAuth_bodyFormEncodedString];
				NSString *encodedValue = [item.value dctAuth_bodyFormEncodedString];
				NSString *parameterString = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
				[parameterStrings addObject:parameterString];
			}

			NSString *bodyFormString = [parameterStrings componentsJoinedByString:@"&"];
			_HTTPBody = [bodyFormString dataUsingEncoding:encoding];

			break;
		}

		case DCTAuthContentTypeJSON: {

			NSMutableDictionary *JSON = [NSMutableDictionary new];
			for (NSURLQueryItem *item in items) {
				if (item.name && item.value) {
					JSON[item.name] = item.value;
				}
			}

			_HTTPBody = [NSJSONSerialization dataWithJSONObject:JSON options:(NSJSONWritingOptions)0 error:NULL];

			break;
		}
	}

	return self;
}

+ (NSArray *)contentTypeStrings {
	static NSArray *contentTypeStrings;
	static dispatch_once_t contentTypeStringsToken;
	dispatch_once(&contentTypeStringsToken, ^{
		contentTypeStrings = @[
			@"application/x-www-form-urlencoded",
			@"application/json"
		];
	});
	return contentTypeStrings;
}

@end
