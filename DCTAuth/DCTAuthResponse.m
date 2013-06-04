//
//  DCTAuthResponse.m
//  DCTAuth
//
//  Created by Daniel Tull on 22.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthResponse.h"
#import "NSString+DCTAuth.h"
#import "_DCTAuthPlatform.h"

const struct DCTAuthResponseProperties {
	__unsafe_unretained NSString *data;
	__unsafe_unretained NSString *URLResponse;
} DCTAuthResponseProperties;

const struct DCTAuthResponseProperties DCTAuthResponseProperties = {
	.data = @"data",
	.URLResponse = @"URLResponse"
};

@implementation DCTAuthResponse

- (id)initWithData:(NSData *)data URLResponse:(NSHTTPURLResponse *)URLResponse {
	self = [self init];
	if (!self) return nil;
	_data = data;
	_URLResponse = [URLResponse copy];
	_HTTPHeaders = URLResponse.allHeaderFields;
	_statusCode = URLResponse.statusCode;
	_contentObject = [self objectFromData:data MIMEType:URLResponse.MIMEType];
	return self;
}

- (id)objectFromData:(NSData *)data MIMEType:(NSString *)contentType {

	if ([contentType isEqualToString:@"application/x-www-form-urlencoded"])
		return [self dictionaryFromFormData:data];

	if ([@[@"application/json", @"text/json", @"application/javascript", @"text/javascript"] containsObject:contentType])
		return [self dictionaryFromJSONData:data];

	if ([contentType isEqualToString:@"application/x-plist"])
		return [self dictionaryFromPlistData:data];

	if ([@[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"] containsObject:contentType])
		return [_DCTAuthPlatform imageFromData:data];

	return [self dictionaryFromFormData:data];
}

- (NSDictionary *)dictionaryFromFormData:(NSData *)data {
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return [string dctAuth_parameterDictionary];
}

- (NSDictionary *)dictionaryFromJSONData:(NSData *)data {
	if (!data) return nil;
	return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
}

- (NSDictionary *)dictionaryFromPlistData:(NSData *)data {
	if (!data) return nil;
	return [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
}

- (id)initWithURL:(NSURL *)URL {
	self = [self init];
	if (!self) return nil;
	_URL = [URL copy];
	_statusCode = 200;
	
	NSMutableDictionary *content = [NSMutableDictionary new];
	[content addEntriesFromDictionary:[[URL query] dctAuth_parameterDictionary]];
	[content addEntriesFromDictionary:[[URL fragment] dctAuth_parameterDictionary]];
	_contentObject = [content copy];
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p>\n%@",
			NSStringFromClass([self class]),
			self,
			[self responseDescription]];
}

- (NSString *)responseDescription {

	NSString *URLString = @"";
	if (self.URL) URLString = [NSString stringWithFormat:@"\n%@", [self.URL absoluteString]];

	NSMutableString *headerString = [NSMutableString new];
	[self.HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		[headerString appendFormat:@"\n%@: %@", key, value];
	}];

	NSString *bodyString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
	if (bodyString.length > 0) bodyString = [NSString stringWithFormat:@"\n\n%@", bodyString];
	else bodyString = [self.contentObject description];

	return [NSString stringWithFormat:@"HTTP/1.1 %@ %@%@%@\n\n",
			@(self.statusCode),
			[[NSHTTPURLResponse localizedStringForStatusCode:self.statusCode] capitalizedString],
			headerString,
			bodyString];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	NSData *data = [coder decodeObjectForKey:DCTAuthResponseProperties.data];
	NSHTTPURLResponse *URLResponse = [coder decodeObjectForKey:DCTAuthResponseProperties.URLResponse];
	return [self initWithData:data URLResponse:URLResponse];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.data forKey:DCTAuthResponseProperties.data];
	[coder encodeObject:self.URLResponse forKey:DCTAuthResponseProperties.URLResponse];
}

@end
