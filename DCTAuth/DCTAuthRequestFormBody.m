//
//  DCTAuthRequestFormBody.m
//  DCTAuth
//
//  Created by Daniel Tull on 24.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequestFormBody.h"

@implementation DCTAuthRequestFormBody
@synthesize HTTPBody = _HTTPBody;
@synthesize HTTPHeaderFields = _HTTPHeaderFields;

- (instancetype)initWithEncoding:(NSStringEncoding)encoding
					  dictionary:(NSDictionary *)dictionary {

	NSParameterAssert(dictionary);

	self = [super init];
	if (!self) return nil;

	_dictionary = [dictionary copy];
	_encoding = encoding;

	NSMutableArray *encodedItems = [NSMutableArray new];
	for (NSURLQueryItem *item in items) {
		NSString *name = [item.name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
		NSString *value = [item.value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
		NSURLQueryItem *encodedItem = [NSURLQueryItem queryItemWithName:name value:value];
		[encodedItems addObject:encodedItem];
	}

	NSURLComponents *components = [NSURLComponents componentsWithString:@"htttp://host.com"];
	components.queryItems = encodedItems;
	_HTTPBody = [components.percentEncodedQuery dataUsingEncoding:encoding];

	CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
	NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(cfEncoding);
	_contentType = [NSString stringWithFormat:@"%@; charset=%@", _contentType, charset];


	_HTTPBody =




	return self;

}

@end
