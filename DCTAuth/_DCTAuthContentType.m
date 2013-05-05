//
//  DCTAuthContentType.m
//  DCTAuth
//
//  Created by Daniel Tull on 30.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTAuthContentType.h"

NSString *const DCTAuthContentTypeParameterCharset = @"charset";

@implementation _DCTAuthContentType

- (id)initWithString:(NSString *)string {
	self = [self init];
	if (!self) return nil;
	_string = [string copy];

	string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSArray *components = [string componentsSeparatedByString:@";"];
	[components enumerateObjectsUsingBlock:^(id object, NSUInteger i, BOOL *stop) {

		if (i == 0) {
			self->_contentType = [[self class] contentTypeForString:object];
			return;
		}

		NSArray *keyValue = [object componentsSeparatedByString:@"="];
		if (keyValue.count != 2) return;

		if ([keyValue[0] isEqualToString:DCTAuthContentTypeParameterCharset])
			self->_stringEncoding = [[self class] encodingForString:keyValue[1]];
	}];

	return self;
}

- (id)initWithContentType:(DCTAuthContentTypeType)contentType {
	return [self initWithContentType:contentType parameters:nil];
}

- (id)initWithContentType:(DCTAuthContentTypeType)contentType parameters:(NSDictionary *)parameters {
	self = [self init];
	if (!self) return nil;
	_contentType = contentType;
	_stringEncoding = NSUTF8StringEncoding;
	NSMutableString *string = [NSMutableString new];
	[string appendString:[[self class] stringForContentType:contentType]];
	[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {

		if ([key isEqualToString:DCTAuthContentTypeParameterCharset]) {
			if ([value isKindOfClass:[NSNumber class]]) {
				self->_stringEncoding = [value unsignedIntegerValue];
				value = [[self class] stringForEncoding:self->_stringEncoding];
			} else if ([value isKindOfClass:[NSString class]])
				self->_stringEncoding = [[self class] encodingForString:value];
		}

		[string appendFormat:@"; %@=%@", key, value];
	}];
	_string = [string copy];
	return self;
}

+ (NSArray *)contentTypeStrings {
	static NSArray *contentTypeStrings;
	static dispatch_once_t contentTypeStringsToken;
	dispatch_once(&contentTypeStringsToken, ^{
		contentTypeStrings = @[
			@"",
			@"text/plain",
			@"text/html",
			@"application/json",
			@"application/plist",
			@"application/xml",
			@"",
			@""
		];
	});
	return contentTypeStrings;
}

+ (DCTAuthContentTypeType)contentTypeForString:(NSString *)string {
	return [[self contentTypeStrings] indexOfObject:string];
}

+ (NSString *)stringForContentType:(DCTAuthContentTypeType)contentType {
	return [[self contentTypeStrings] objectAtIndex:contentType];
}

+ (NSString *)stringForEncoding:(NSStringEncoding)encoding {
	CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
	return (__bridge_transfer NSString *)CFStringConvertEncodingToIANACharSetName(cfEncoding);
}

+ (NSStringEncoding)encodingForString:(NSString *)string {
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), string);
	if (string.length == 0) return NSUTF8StringEncoding;
	CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)string);
	return CFStringConvertEncodingToNSStringEncoding(encoding);
}

@end
