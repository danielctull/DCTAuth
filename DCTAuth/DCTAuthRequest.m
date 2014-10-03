//
//  DCTAuthRequest.m
//  DCTAuth
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequest.h"
#import "DCTAuthAccountSubclass.h"
#import "DCTAuthPlatform.h"
#import "DCTAuthMultipartData.h"
#import "NSDictionary+DCTAuth.h"
#import "NSString+DCTAuth.h"
#import "_DCTAuthURLRequestPerformer.h"

static const struct DCTAuthRequestProperties {
	__unsafe_unretained NSString *requestMethod;
	__unsafe_unretained NSString *URL;
	__unsafe_unretained NSString *parameters;
	__unsafe_unretained NSString *multipartDatas;
	__unsafe_unretained NSString *account;
} DCTAuthRequestProperties;

static const struct DCTAuthRequestProperties DCTAuthRequestProperties = {
	.requestMethod = @"requestMethod",
	.URL = @"URL",
	.parameters = @"parameters",
	.multipartDatas = @"multipartDatas",
	.account = @"account"
};

static NSString *const DCTAuthConnectionIncreasedNotification = @"DCTConnectionQueueActiveConnectionCountIncreasedNotification";
static NSString *const DCTAuthConnectionDecreasedNotification = @"DCTConnectionQueueActiveConnectionCountDecreasedNotification";

static NSString *const _DCTAuthRequestMethodString[] = {
	@"GET",
	@"POST",
	@"DELETE",
	@"HEAD",
	@"PUT"
};

NSUInteger const DCTAuthRequestMethodCount = DCTAuthRequestMethodPUT + 1;

static NSString *const DCTAuthRequestContentLengthKey = @"Content-Length";

static NSString *const DCTAuthRequestContentTypeKey = @"Content-Type";
static NSString *const DCTAuthRequestContentTypeString[] = {
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

+ (NSString *)stringForRequestMethod:(DCTAuthRequestMethod)requestMethod {
	return _DCTAuthRequestMethodString[requestMethod];
}

- (instancetype)initWithRequestMethod:(DCTAuthRequestMethod)requestMethod
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
	DCTAuthMultipartData *multipartData = [DCTAuthMultipartData new];
	multipartData.data = data;
	multipartData.name = name;
	multipartData.type = type;
	[self.multipartDatas addObject:multipartData];

	if (self.parameters) {
		
		[self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
			DCTAuthMultipartData *multipartData = [DCTAuthMultipartData new];
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

	if ([self shouldSetupPOSTRequest])
		[self _setupPOSTRequest:mutableRequest];
	else
		[self _setupGETRequest:mutableRequest];

	[self.HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		
		if (![key isKindOfClass:[NSString class]]) key = [key description];
		if (![object isKindOfClass:[NSString class]]) object = [object description];
		
		[mutableRequest setValue:object forHTTPHeaderField:key];
	}];

	return mutableRequest;
}

- (BOOL)shouldSetupPOSTRequest {
	return (self.requestMethod == DCTAuthRequestMethodPOST || self.requestMethod == DCTAuthRequestMethodPUT);
}

- (void)_setupGETRequest:(NSMutableURLRequest *)request {

	NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:self.URL resolvingAgainstBaseURL:YES];
	NSDictionary *exitingParameters = [URLComponents.query dctAuth_parameterDictionary];
	NSMutableDictionary *queryParameters = [NSMutableDictionary new];
	[queryParameters addEntriesFromDictionary:exitingParameters];
	[queryParameters addEntriesFromDictionary:self.parameters];
	URLComponents.query = [queryParameters dctAuth_queryString];

	[request setURL:URLComponents.URL];
}

- (NSData *)encodedBodyWithParameters:(NSDictionary *)parameters
						  contentType:(DCTAuthRequestContentType)contentType {

	NSData *body;

	if (contentType == DCTAuthRequestContentTypeForm)
		body = [parameters dctAuth_bodyFormDataUsingEncoding:NSUTF8StringEncoding];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
	else if (contentType == DCTAuthRequestContentTypeJSON)
		body = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:NULL];
#pragma clang diagnostic pop

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
	[self.multipartDatas enumerateObjectsUsingBlock:^(DCTAuthMultipartData *multipartData, NSUInteger i, BOOL *stop) {
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

- (void)performRequestWithHandler:(DCTAuthRequestHandler)originalHandler {

	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:DCTAuthConnectionIncreasedNotification object:self];

	_DCTAuthURLRequestPerformer *URLRequestPerformer = [_DCTAuthURLRequestPerformer sharedURLRequestPerformer];
	NSURLRequest *URLRequest = [self signedURLRequest];

	id object = [DCTAuthPlatform beginBackgroundTaskWithExpirationHandler:NULL];

	void (^handler)(DCTAuthResponse *response, NSError *error) = ^(DCTAuthResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[defaultCenter postNotificationName:DCTAuthConnectionDecreasedNotification object:self];
			if (originalHandler) originalHandler(response, error);
			[DCTAuthPlatform endBackgroundTask:object];
		});
	};

	[URLRequestPerformer performRequest:URLRequest withHandler:^(DCTAuthResponse *originalResponse, NSError *originalError) {

		if (!originalError || !self.account) {
			handler(originalResponse, originalError);
			return;
		}

		[self.account reauthenticateWithHandler:^(DCTAuthResponse *response, NSError *error) {

			if (error) {
				handler(originalResponse, originalError);
				return;
			}

			[URLRequestPerformer performRequest:[self signedURLRequest] withHandler:handler];
		}];
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
		NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
		queryString = [NSString stringWithFormat:@"\nQuery: ?%@", URLComponents.query];
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

- (instancetype)initWithCoder:(NSCoder *)coder {
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
