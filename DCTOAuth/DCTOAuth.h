//
//  DCTOAuth.h
//  DCTOAuthController
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthAccount.h"
#import "DCTOAuthAccountStore.h"
#import "DCTOAuthRequest.h"

@interface DCTOAuth
+ (BOOL)handleURL:(NSURL *)URL;
@end
