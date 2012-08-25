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

@implementation DCTOAuthRequest {
	__strong DCTOAuthSignature *_signature;
}

- (id)initWithURL:(NSURL *)URL
    requestMethod:(DCTOAuthRequestMethod)requestMethod
       parameters:(NSDictionary *)parameters
		signature:(DCTOAuthSignature *)signature {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_signature = signature;
	_requestMethod = requestMethod;
	
	return self;
}

- (NSURLRequest *)signedURLRequest {
	
	NSMutableArray *parameters = [NSMutableArray new];
	[_signature.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [key dctOAuthController_URLEncodedString];
        NSString *encodedValue = [value dctOAuthController_URLEncodedString];
		NSString *string = [NSString stringWithFormat:@"%@=\"%@\"", encodedKey, encodedValue];
		[parameters addObject:string];
	}];
	
	NSString *string = [NSString stringWithFormat:@"oauth_signature=\"%@\"", [_signature signedString]];
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
