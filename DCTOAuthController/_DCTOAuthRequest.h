//
//  _DCTOAuthRequest.h
//  DCTOAuthController
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthRequest.h"

@interface DCTOAuthRequest (Private)

- (id)initWithURL:(NSURL *)URL
    requestMethod:(DCTOAuthRequestMethod)requestMethod
       parameters:(NSDictionary *)parameters
		signature:(DCTOAuthSignature *)signature;

@end
