//
//  DCTOAuthRequest.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthRequest.h"
#import "_DCTOAuthAccount.h"
#import "NSString+DCTOAuth.h"

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
	
	NSURL *URL = self.URL;
	
	if (self.parameters) {
		NSMutableArray *parameterStrings = [NSMutableArray new];
		[self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
			NSString *encodedKey = [key dctOAuth_URLEncodedString];
			NSString *encodedValue = [value dctOAuth_URLEncodedString];
			NSString *parameterString = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
			[parameterStrings addObject:parameterString];
		}];
		
		NSString *URLString = [NSString stringWithFormat:@"%@?%@", [URL absoluteString], [parameterStrings componentsJoinedByString:@"&"]];
		URL = [NSURL URLWithString:URLString];
	}
	
	NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
	[mutableRequest setHTTPMethod:NSStringFromDCTOAuthRequestMethod(self.requestMethod)];
	return mutableRequest;
}

- (NSURLRequest *)signedURLRequest {
	NSMutableURLRequest *request = [self _URLRequest];
	[self.account _signURLRequest:request];
	return request;
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
