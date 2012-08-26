//
//  _ DCTOAuthAccount.h
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccount.h"
#import "DCTOAuthRequest.h"

@interface DCTOAuthAccount (Private)

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest;
- (id)initWithType:(NSString *)type;

@end
