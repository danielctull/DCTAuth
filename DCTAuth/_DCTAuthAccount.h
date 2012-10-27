//
//  _DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTAuthRequest.h"

@interface DCTAuthAccount (Private)

- (void)_setAuthorized:(BOOL)authorized;

- (void)_willBeDeleted;

@end
