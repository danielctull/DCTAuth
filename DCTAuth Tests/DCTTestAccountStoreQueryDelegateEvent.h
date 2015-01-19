//
//  DCTTestAccountStoreQueryDelegateEvent.h
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;
@import DCTAuth;

typedef NS_ENUM(NSInteger, DCTTestAccountStoreQueryDelegateEventType) {
	DCTTestAccountStoreQueryDelegateEventTypeInsert,
	DCTTestAccountStoreQueryDelegateEventTypeRemove,
	DCTTestAccountStoreQueryDelegateEventTypeMove,
	DCTTestAccountStoreQueryDelegateEventTypeUpdate
};

@interface DCTTestAccountStoreQueryDelegateEvent : NSObject

- (instancetype)initWithAccountStoreQuery:(DCTAuthAccountStoreQuery *)query
								  account:(DCTAuthAccount *)account
									 type:(DCTTestAccountStoreQueryDelegateEventType)type
								fromIndex:(NSUInteger)fromIndex
								  toIndex:(NSUInteger)toIndex;

@property (nonatomic, readonly) DCTAuthAccountStoreQuery *query;
@property (nonatomic, readonly) DCTAuthAccount *account;
@property (nonatomic, readonly) DCTTestAccountStoreQueryDelegateEventType type;
@property (nonatomic, readonly) NSUInteger fromIndex;
@property (nonatomic, readonly) NSUInteger toIndex;

@end
