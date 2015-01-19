//
//  DCTAuthAccountStoreQueryDelegate.h
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;
#import "DCTAuthAccount.h"
@class DCTAuthAccountStoreQuery;


@protocol DCTAuthAccountStoreQueryDelegate <NSObject>

- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didInsertAccount:(DCTAuthAccount *)account atIndex:(NSUInteger)index;
- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didRemoveAccount:(DCTAuthAccount *)account fromIndex:(NSUInteger)index;
- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didMoveAccount:(DCTAuthAccount *)account fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)accountStoreQuery:(DCTAuthAccountStoreQuery *)query didUpdateAccount:(DCTAuthAccount *)account atIndex:(NSUInteger)index;

@end
