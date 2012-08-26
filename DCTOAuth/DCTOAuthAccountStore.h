//
//  DCTOAuthAccountStore.h
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTOAuthAccount.h"

@interface DCTOAuthAccountStore : NSObject

@property(nonatomic, readonly) NSArray *accounts;
- (NSArray *)accountsWithType:(NSString *)type;
- (DCTOAuthAccount *)accountWithIdentifier:(NSString *)identifier;

- (void)saveAccount:(DCTOAuthAccount *)account withCompletionHandler:(void(^)(BOOL success, NSError *error))completionHandler;
- (void)deleteAccount:(DCTOAuthAccount *)account withCompletionHandler:(void(^)(BOOL success, NSError *error))completionHandler;

@end
