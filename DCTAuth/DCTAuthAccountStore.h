//
//  DCTAuthAccountStore.h
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"

@interface DCTAuthAccountStore : NSObject

@property(nonatomic, readonly) NSArray *accounts;

- (NSArray *)accountsWithType:(NSString *)type;
- (DCTAuthAccount *)accountWithIdentifier:(NSString *)identifier;

- (void)saveAccount:(DCTAuthAccount *)account;
- (void)deleteAccount:(DCTAuthAccount *)account;

@end
