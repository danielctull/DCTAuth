//
//  _DCTAuthPasswordProvider.h
//  DCTAuth
//
//  Created by Daniel Tull on 16.02.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"

@interface _DCTAuthPasswordProvider : NSObject

+ (instancetype)sharedPasswordProvider;

@property (nonatomic, copy) NSString *(^passwordProvider)(DCTAuthAccount *account);

- (void)passwordForAccount:(DCTAuthAccount *)account handler:(void(^)(NSString *))handler;

@end
