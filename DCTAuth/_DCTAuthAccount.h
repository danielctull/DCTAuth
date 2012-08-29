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

- (void)_willBeDeleted;

- (void)_setSecureValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)_secureValueForKey:(NSString *)key;
- (void)_removeSecureValueForKey:(NSString *)key;

@end
