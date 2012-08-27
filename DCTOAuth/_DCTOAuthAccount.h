//
//  _ DCTOAuthAccount.h
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccount.h"
#import "DCTOAuthRequest.h"

@interface DCTOAuthAccount (Private) <NSCoding>

- (void)_OAuthRequest:(DCTOAuthRequest *)OAuthRequest signURLRequest:(NSMutableURLRequest *)request;

- (id)initWithType:(NSString *)type;

- (void)_willBeDeleted;
- (void)_setValue:(NSString *)value forSecureKey:(NSString *)key;
- (NSString *)_valueForSecureKey:(NSString *)key;
- (void)_removeValueForSecureKey:(NSString *)key;

@end
