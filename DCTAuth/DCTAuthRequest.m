//
//  DCTAuthRequest.m
//  DCTAuth
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequest.h"
#import "DCTAuthAccountSubclass.h"
#import "_DCTAuthPlatform.h"
#import "_DCTAuthMultipartData.h"
#import "NSURL+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"
#import "_DCTAuthURLRequestPerformer.h"

const struct DCTAuthRequestProperties {
	__unsafe_unretained NSString *requestMethod;
	__unsafe_unretained NSString *URL;
	__unsafe_unretained NSString *parameters;
	__unsafe_unretained NSString *multipartDatas;
	__unsafe_unretained NSString *account;
} DCTAuthRequestProperties;

const struct DCTAuthRequestProperties DCTAuthRequestProperties = {
	.requestMethod = @"requestMethod",
	.URL = @"URL",
	.parameters = @"parameters",
	.multipartDatas = @"multipartDatas",
	.account = @"account"
};

NSString *const DCTAuthConnectionIncreasedNotification = @"DCTConnectionQueueActiveConnectionCountIncreasedNotification";
NSString *const DCTAuthConnectionDecreasedNotification = @"DCTConnectionQueueActiveConnectionCountDecreasedNotification";

NSString *const _DCTAuthRequestMethodString[] = {
	@"GET",
	@"POST",
	@"DELETE",
	@"HEAD"
};

NSString *const DCTAuthRequestContentLengthKey = @"Content-Length";

NSString *const DCTAuthRequestContentTypeKey = @"Content-Type";
NSString *const DCTAuthRequestContentTypeString[] = {
	@"application/x-www-form-urlencoded; charset=UTF-8",
	@"application/json; charset=UTF-8",
	@"application/x-plist; charset=UTF-8"
};

@interface DCTAuthRequest ()
@property (nonatomic, strong) NSMutableArray *multipartDatas;
@property (nonatomic, readwrite) NSDictionary *parameters;
@end

@implementation DCTAuthRequest

#pragma mark - DCTAuthRequest

- (id)initWithRequestMethod:(DCTAuthRequestMethod)requestMethod
						URL:(NSURL *)URL
				 parameters:(NSDictionary *)parameters {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_requestMethod = requestMethod;
	_parameters = [parameters copy];
	_multipartDatas = [NSMutableArray new];

	return self;
}

- (void)addMultiPartData:(NSData *)data withName:(NSString *)name type:(NSString *)type {
	_DCTAuthMultipartData *multipartData = [_DCTAuthMultipartData new];
	multipartData.data = data;
	multipartData.name = name;
	multipartData.type = type;
	[self.multipartDatas addObject:multipartData];

	if (self.parameters) {
		
		[self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
			_DCTAuthMultipartData *multipartData = [_DCTAuthMultipartData new];
			multipartData.data = [[object description] dataUsingEncoding:NSUTF8StringEncoding];
			multipartData.name = [key description];
			multipartData.type = @"text/plain";
			[self.multipartDatas addObject:multipartData];
		}];

		self.parameters = nil;
	}
}

/*
 TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"] parameters:nil requestMethod:TWRequestMethodPOST];
 NSData *myData = UIImagePNGRepresentation(img);
 [postRequest addMultiPartData:myData withName:@"media" type:@"image/png"];
 myData = [[NSString stringWithFormat:@"Any status text"] dataUsingEncoding:NSUTF8StringEncoding];
 [postRequest addMultiPartData:myData withName:@"status" type:@"text/plain"];*/

- (NSMutableURLRequest *)_URLRequest {

	NSMutableURLRequest *mutableRequest = [NSMutableURLRequest new];
	[mutableRequest setHTTPMethod:_DCTAuthRequestMethodString[self.requestMethod]];

	if (self.requestMethod == DCTAuthRequestMethodPOST)
		[self _setupPOSTRequest:mutableRequest];
	else
		[self _setupGETRequest:mutableRequest];

	[self.HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[mutableRequest setValue:obj forHTTPHeaderField:key];
	}];

	return mutableRequest;
}

- (void)_setupGETRequest:(NSMutableURLRequest *)request {
	[request setURL:[self.URL dctAuth_URLByAddingQueryParameters:self.parameters]];
}

- (NSData *)encodedBodyWithParameters:(NSDictionary *)parameters
						  contentType:(DCTAuthRequestContentType)contentType {

	NSData *body;

	if (contentType == DCTAuthRequestContentTypeForm)
		body = [parameters dctAuth_bodyFormDataUsingEncoding:NSUTF8StringEncoding];

	else if (contentType == DCTAuthRequestContentTypeJSON)
		body = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:NULL];

	else if (contentType == DCTAuthRequestContentTypePlist)
		body = [NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];

	return body;
}

- (void)_setupPOSTRequest:(NSMutableURLRequest *)request {
	[request setURL:self.URL];

	if ([self.multipartDatas count] == 0) {
		[request setHTTPBody:[self encodedBodyWithParameters:self.parameters contentType:self.contentType]];
		NSString *contentLength = [@([[request HTTPBody] length]) stringValue];
		[request setValue:contentLength forHTTPHeaderField:DCTAuthRequestContentLengthKey];
		NSString *contentType = DCTAuthRequestContentTypeString[self.contentType];
		[request addValue:contentType forHTTPHeaderField:DCTAuthRequestContentTypeKey];
		return;
	}

	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];

	NSMutableData *body = [NSMutableData new];
	[self.multipartDatas enumerateObjectsUsingBlock:^(_DCTAuthMultipartData *multipartData, NSUInteger i, BOOL *stop) {
		[body appendData:[multipartData dataWithBoundary:boundary]];
	}];
	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	[request setHTTPBody:body];
	[request setValue:[NSString stringWithFormat:@"%@", @([body length])] forHTTPHeaderField:@"Content-Length"];
}

- (NSURLRequest *)signedURLRequest {

	if (![self.account conformsToProtocol:@protocol(DCTAuthAccountSubclass)])
		return [[self _URLRequest] copy];

	NSMutableURLRequest *request = [self _URLRequest];
	[(id<DCTAuthAccountSubclass>)self.account signURLRequest:request forAuthRequest:self];
	return [request copy];
}

- (void)performRequestWithHandler:(DCTAuthRequestHandler)handler {

	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:DCTAuthConnectionIncreasedNotification object:self];

	_DCTAuthURLRequestPerformer *URLRequestPerformer = [_DCTAuthURLRequestPerformer sharedURLRequestPerformer];
	NSURLRequest *URLRequest = [self signedURLRequest];

	id object = [_DCTAuthPlatform beginBackgroundTaskWithExpirationHandler:NULL];
	[URLRequestPerformer performRequest:URLRequest withHandler:^(DCTAuthResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[defaultCenter postNotificationName:DCTAuthConnectionDecreasedNotification object:self];
			if (handler != NULL) handler(response, error);
			[_DCTAuthPlatform endBackgroundTask:object];
		});
	}];
}

- (NSString *)description {
	NSURLRequest *request = [self signedURLRequest];
	NSData *body = [request HTTPBody];
	NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
	if (bodyString.length > 0) bodyString = [NSString stringWithFormat:@"\n\n%@", bodyString];
	else bodyString = @"";

	NSString *queryString = @"";
	if (self.requestMethod == DCTAuthRequestMethodGET && self.parameters.count > 0) {
		NSURL *URL = [self.URL dctAuth_URLByAddingQueryParameters:self.parameters];
		queryString = [NSString stringWithFormat:@"\nQuery: ?%@", [URL query]];
	}

	return [NSString stringWithFormat:@"<%@: %p>\n%@ %@ \nHost: %@%@%@%@\n\n",
			NSStringFromClass([self class]),
			self,
			_DCTAuthRequestMethodString[self.requestMethod],
			[self.URL path],
			[self.URL host],
			queryString,
			[self headerDescription:request],
			bodyString];
}

- (NSString *)headerDescription:(NSURLRequest *)request {
	NSDictionary *headers = [request allHTTPHeaderFields];
	
	NSMutableString *string = [NSMutableString new];
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		[string appendFormat:@"\n%@: %@", key, value];
	}];
	return [string copy];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_requestMethod = [coder decodeIntegerForKey:DCTAuthRequestProperties.requestMethod];
	_URL = [[coder decodeObjectForKey:DCTAuthRequestProperties.URL] copy];
	_parameters = [[coder decodeObjectForKey:DCTAuthRequestProperties.parameters] copy];
	_multipartDatas = [[coder decodeObjectForKey:DCTAuthRequestProperties.multipartDatas] copy];
	_account = [coder decodeObjectForKey:DCTAuthRequestProperties.account];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:self.requestMethod forKey:DCTAuthRequestProperties.requestMethod];
	[coder encodeObject:self.URL forKey:DCTAuthRequestProperties.URL];
	[coder encodeObject:self.parameters forKey:DCTAuthRequestProperties.parameters];
	[coder encodeObject:self.multipartDatas forKey:DCTAuthRequestProperties.multipartDatas];
	[coder encodeObject:self.account forKey:DCTAuthRequestProperties.account];
}

@end
