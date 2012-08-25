//
//  DCTOAuthRequest.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthRequest.h"
#import "_DCTOAuthRequestMethod.h"
#import "NSString+DCTOAuthController.h"
#import "DCTOAuthSignature.h"

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

	if (!self.account) {
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_URL];
		[request setHTTPMethod:DCTOAuthRequestMethodString[self.requestMethod]];
		return [request copy];
	}
	
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:self.URL
															requestMethod:self.requestMethod
															  consumerKey:self.account.consumerKey
														   consumerSecret:self.account.consumerSecret
																	token:self.account.oauthToken
															  secretToken:self.account.oauthTokenSecret
															   parameters:self.parameters];

	NSMutableArray *parameters = [NSMutableArray new];
	[signature.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [key dctOAuthController_URLEncodedString];
        NSString *encodedValue = [value dctOAuthController_URLEncodedString];
		NSString *string = [NSString stringWithFormat:@"%@=\"%@\"", encodedKey, encodedValue];
		[parameters addObject:string];
	}];
	
	NSString *string = [NSString stringWithFormat:@"oauth_signature=\"%@\"", [signature signedString]];
	[parameters addObject:string];
	NSString *parameterString = [parameters componentsJoinedByString:@","];
		
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_URL];
	[request setHTTPMethod:DCTOAuthRequestMethodString[self.requestMethod]];
	[request setAllHTTPHeaderFields:@{ @"Authorization" : [NSString stringWithFormat:@"OAuth %@", parameterString]}];
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
