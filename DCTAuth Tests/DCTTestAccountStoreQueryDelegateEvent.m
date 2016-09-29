//
//  DCTTestAccountStoreQueryDelegateEvent.m
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "DCTTestAccountStoreQueryDelegateEvent.h"

static NSString *const DCTTestAccountStoreQueryDelegateEventTypeString[] = {
	@"Insert",
	@"Remove",
	@"Move",
	@"Update"
};

@implementation DCTTestAccountStoreQueryDelegateEvent

- (instancetype)initWithAccountStoreQuery:(DCTAuthAccountStoreQuery *)query
								  account:(DCTAuthAccount *)account
									 type:(DCTTestAccountStoreQueryDelegateEventType)type
								fromIndex:(NSUInteger)fromIndex
								  toIndex:(NSUInteger)toIndex {
	self = [super init];
	if (!self) return nil;
	_query = query;
	_account = account;
	_type = type;
	_fromIndex = fromIndex;
	_toIndex = toIndex;
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; type = %@; from = %@; to = %@>",
			NSStringFromClass([self class]),
			(void *)self,
			DCTTestAccountStoreQueryDelegateEventTypeString[self.type],
			@(self.fromIndex),
			@(self.toIndex)];
}

@end
