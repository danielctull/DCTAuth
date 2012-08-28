//
//  DCTOAuthRequest.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthRequest.h"
#import "_DCTOAuthAccount.h"
#import "NSURL+DCTOAuth.h"
#import "NSDictionary+DCTOAuth.h"

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

- (NSMutableURLRequest *)_URLRequest {
	
	NSMutableURLRequest *mutableRequest = [NSMutableURLRequest new];
	[mutableRequest setHTTPMethod:NSStringFromDCTOAuthRequestMethod(self.requestMethod)];
	
	if (self.requestMethod == DCTOAuthRequestMethodGET)
		[mutableRequest setURL:[self.URL dctOAuth_URLByAddingQueryParameters:self.parameters]];
	
	else if (self.requestMethod == DCTOAuthRequestMethodPOST) {
		[mutableRequest setURL:self.URL];
		[mutableRequest setHTTPBody:[self.parameters dctOAuth_bodyFormDataUsingEncoding:NSUTF8StringEncoding]];
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
