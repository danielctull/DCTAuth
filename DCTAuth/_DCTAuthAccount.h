//
//  _DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTAuthRequest.h"

@interface DCTAuthAccount (Private) <NSCoding>

- (void)_setAuthorized:(BOOL)authorized;
- (void)_signURLRequest:(NSMutableURLRequest *)request oauthRequest:(DCTAuthRequest *)oauthRequest;

- (id)initWithType:(NSString *)type;

- (void)_willBeDeleted;
- (void)_setValue:(NSString *)value forSecureKey:(NSString *)key;
- (NSString *)_valueForSecureKey:(NSString *)key;
- (void)_removeValueForSecureKey:(NSString *)key;

@end
