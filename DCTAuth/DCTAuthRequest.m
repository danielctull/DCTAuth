//
//  DCTAuthRequest.m
//  DCTAuth
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequest.h"
#import "_DCTAuthAccount.h"
#import "_DCTAuthPlatform.h"
#import "_DCTAuthMultipartData.h"
#import "NSURL+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"

NSString *const DCTAuthConnectionIncreasedNotification = @"DCTConnectionQueueActiveConnectionCountIncreasedNotification";
NSString *const DCTAuthConnectionDecreasedNotification = @"DCTConnectionQueueActiveConnectionCountDecreasedNotification";

NSString * const DCTAuthRequestMethodString[] = {
	@"GET",
	@"POST",
	@"DELETE"
};

NSString * NSStringFromDCTAuthRequestMethod(DCTAuthRequestMethod method) {
	return DCTAuthRequestMethodString[method];
}

@implementation DCTAuthRequest {
	__strong NSMutableArray *_multipartDatas;
}

- (id)initWithRequestMethod:(DCTAuthRequestMethod)requestMethod
						URL:(NSURL *)URL
				 parameters:(NSDictionary *)parameters {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_requestMethod = requestMethod;
	_parameters = parameters;
	_multipartDatas = [NSMutableArray new];

	return self;
}

- (void)addMultiPartData:(NSData *)data withName:(NSString *)name type:(NSString *)type {
	_DCTAuthMultipartData *multipartData = [_DCTAuthMultipartData new];
	multipartData.data = data;
	multipartData.name = name;
	multipartData.type = type;
	[_multipartDatas addObject:multipartData];

	if (self.parameters) {
		
		[self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
			_DCTAuthMultipartData *multipartData = [_DCTAuthMultipartData new];
			multipartData.data = [[object description] dataUsingEncoding:NSUTF8StringEncoding];
			multipartData.name = [key description];
			multipartData.type = @"text/plain";
			[_multipartDatas addObject:multipartData];
		}];

		_parameters = nil;
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
	[mutableRequest setHTTPMethod:NSStringFromDCTAuthRequestMethod(self.requestMethod)];
	
	if (self.requestMethod == DCTAuthRequestMethodGET)
		[self _setupGETRequest:mutableRequest];

	else if (self.requestMethod == DCTAuthRequestMethodDELETE)
		[self _setupDELETERequest:mutableRequest];

	else if (self.requestMethod == DCTAuthRequestMethodPOST)
		[self _setupPOSTRequest:mutableRequest];
	
	return mutableRequest;
}

- (void)_setupGETRequest:(NSMutableURLRequest *)request {
	[request setURL:[self.URL dctAuth_URLByAddingQueryParameters:self.parameters]];
}

- (void)_setupDELETERequest:(NSMutableURLRequest *)request {
	[request setURL:[self.URL dctAuth_URLByAddingQueryParameters:self.parameters]];
}

- (void)_setupPOSTRequest:(NSMutableURLRequest *)request {
	[request setURL:self.URL];

	if ([_multipartDatas count] == 0) {
		[request setHTTPBody:[self.parameters dctAuth_bodyFormDataUsingEncoding:NSUTF8StringEncoding]];
		[request setValue:[NSString stringWithFormat:@"%d", [[request HTTPBody] length]] forHTTPHeaderField:@"Content-Length"];
		return;
	}

	NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];

	NSMutableData *body = [NSMutableData new];
	[_multipartDatas enumerateObjectsUsingBlock:^(_DCTAuthMultipartData *multipartData, NSUInteger i, BOOL *stop) {
		[body appendData:[multipartData dataWithBoundary:boundary]];
	}];
	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	[request setHTTPBody:body];
	[request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
}

- (NSURLRequest *)signedURLRequest {

	if (![self.account conformsToProtocol:@protocol(DCTAuthAccountSubclass)])
		return [[self _URLRequest] copy];

	NSMutableURLRequest *request = [self _URLRequest];
	[(id<DCTAuthAccountSubclass>)self.account signURLRequest:request forAuthRequest:self];
	return [request copy];
}

- (void)performRequestWithHandler:(void(^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))handler {

	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:DCTAuthConnectionIncreasedNotification object:self];

	id object = [_DCTAuthPlatform beginBackgroundTaskWithExpirationHandler:NULL];
    [NSURLConnection sendAsynchronousRequest:[self signedURLRequest]
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

		[_DCTAuthPlatform endBackgroundTask:object];
		[defaultCenter postNotificationName:DCTAuthConnectionDecreasedNotification object:self];

        if (handler == NULL) return;
        
        NSHTTPURLResponse *HTTPURLResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
            HTTPURLResponse = (NSHTTPURLResponse *)response;
        
        handler(data, HTTPURLResponse, error);
	}];
}

@end
