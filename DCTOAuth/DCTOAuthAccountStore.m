//
//  DCTOAuthAccountStore.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccountStore.h"

@implementation DCTOAuthAccountStore

- (NSArray *)accounts {
	return nil;
}

- (NSArray *)accountsWithType:(NSString *)type {
	return nil;
}

- (DCTOAuthAccount *)accountWithIdentifier:(NSString *)identifier {
	return nil;
}

- (void)saveAccount:(DCTOAuthAccount *)account withCompletionHandler:(void(^)(BOOL success, NSError *error))completionHandler {
	
}

- (void)deleteAccount:(DCTOAuthAccount *)account withCompletionHandler:(void(^)(BOOL success, NSError *error))completionHandler {
	
}

@end
