//
//  DCTOAuthRequest.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthRequest.h"
#import "_DCTOAuthAccount.h"

NSString * const DCTOAuthRequestMethodString[] = {
	@"GET",
	@"POST"
};

NSString * NSStringFromDCTOAuthRequestMethod(DCTOAuthRequestMethod method) {
	return DCTOAuthRequestMethodString[method];
}

@implementation DCTOAuthRequest

- (id)initWithURL:(NSURL *)URL
    requestMethod:(DCTOAuthRequestMethod)requestMethod
       parameters:(NSDictionary *)parameters {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_requestMethod = requestMethod;
	_parameters = parameters;

	return self;
}

- (NSURLRequest *)signedURLRequest {

	NSURLRequest *request = [self.account _signedURLRequestFromOAuthRequest:self];
	if (request) return request;
		
	NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:_URL];
	[mutableRequest setHTTPMethod:NSStringFromDCTOAuthRequestMethod(self.requestMethod)];
	return [mutableRequest copy];
}

- (void)performRequestWithHandler:(void(^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))handler {

    [NSURLConnection sendAsynchronousRequest:[self signedURLRequest] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (handler == NULL) return;
        
        NSHTTPURLResponse *HTTPURLResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
            HTTPURLResponse = (NSHTTPURLResponse *)response;
        
        handler(data, HTTPURLResponse, error);
	}];
}

@end
