//
//  DCTAuthAccountStoreQuery.h
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;
@class DCTAuthAccountStore;
@protocol DCTAuthAccountStoreQueryDelegate;

extern const struct DCTAuthAccountStoreQueryAttributes {
	__unsafe_unretained NSString *predicate;
	__unsafe_unretained NSString *sortDescriptors;
	__unsafe_unretained NSString *accounts;
} DCTAuthAccountStoreQueryAttributes;

@interface DCTAuthAccountStoreQuery : NSObject

- (instancetype)initWithAccountStore:(DCTAuthAccountStore *)accountStore
						   predciate:(NSPredicate *)predicate
					 sortDescriptors:(NSArray *)sortDescriptors;

@property (nonatomic, readonly) DCTAuthAccountStore *accountStore;
@property (nonatomic, readonly) NSPredicate *predicate;
@property (nonatomic, readonly) NSArray *sortDescriptors;

@property (nonatomic, readonly) NSArray *accounts;
@property (nonatomic, weak) id<DCTAuthAccountStoreQueryDelegate> delegate;


@end
