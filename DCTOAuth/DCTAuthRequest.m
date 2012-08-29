//
//  DCTOAuthRequest.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthRequest.h"
#import "_DCTAuthAccount.h"
#import "NSURL+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"

NSString * const DCTAuthRequestMethodString[] = {
	@"GET",
	@"POST"
};

NSString * NSStringFromDCTAuthRequestMethod(DCTAuthRequestMethod method) {
	return DCTAuthRequestMethodString[method];
}

@implementation DCTAuthRequest

- (id)initWithURL:(NSURL *)URL
    requestMethod:(DCTAuthRequestMethod)requestMethod
       parameters:(NSDictionary *)parameters {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_requestMethod = requestMethod;
	_parameters = parameters;

	return self;
}

- (NSMutableURLRequest *)_URLRequest {
	
	NSMutableURLRequest *mutableRequest = [NSMutableURLRequest new];
	[mutableRequest setHTTPMethod:NSStringFromDCTAuthRequestMethod(self.requestMethod)];
	
	if (self.requestMethod == DCTAuthRequestMethodGET)
		[mutableRequest setURL:[self.URL dctAuth_URLByAddingQueryParameters:self.parameters]];
	
	else if (self.requestMethod == DCTAuthRequestMethodPOST) {
		[mutableRequest setURL:self.URL];
		[mutableRequest setHTTPBody:[self.parameters dctAuth_bodyFormDataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return mutableRequest;
}

- (NSURLRequest *)signedURLRequest {
	NSMutableURLRequest *request = [self _URLRequest];
	[self.account _signURLRequest:request oauthRequest:self];
	return request;
}

- (void)performRequestWithHandler:(void(^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))handler {
	
    [NSURLConnection sendAsynchronousRequest:[self signedURLRequest]
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
        if (handler == NULL) return;
        
        NSHTTPURLResponse *HTTPURLResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
            HTTPURLResponse = (NSHTTPURLResponse *)response;
        
        handler(data, HTTPURLResponse, error);
	}];
}

@end
