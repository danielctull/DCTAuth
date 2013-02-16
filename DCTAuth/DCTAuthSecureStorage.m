//
//  DCTAuthSecureStorage.m
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthSecureStorage.h"

NSString *const DCTAuthSecureStorageKeys = @"DCTAuthSecureStorageKeys";

@interface DCTAuthSecureStorage ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation DCTAuthSecureStorage

- (id)initWithAccount:(DCTAuthAccount *)account {
	self = [self init];
	if (!self) return nil;

	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (!self) return nil;

	NSArray *keys = [coder decodeObjectForKey:DCTAuthSecureStorageKeys];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:keys.count];
	[keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
		id object = [coder decodeObjectForKey:key];
		[dictionary setObject:object forKey:key];
	}];
	_dictionary = [dictionary copy];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.dictionary.allKeys	forKey:DCTAuthSecureStorageKeys];
	[self.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[coder encodeObject:object forKey:key];
	}];

}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
	[self.dictionary setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
	return [self.dictionary objectForKey:key];
}


@end
