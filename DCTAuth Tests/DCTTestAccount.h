//
//  DCTTestAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 19.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import DCTAuth;

extern const struct DCTTestAccountAttributes {
	__unsafe_unretained NSString *name;
} DCTTestAccountAttributes;

@interface DCTTestAccount : DCTAuthAccount

- (instancetype)initWithName:(NSString *)name;
@property (nonatomic, readonly) NSString *name;

@end
