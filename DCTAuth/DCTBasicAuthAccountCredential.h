//
//  DCTBasicAuthAccountCredential.h
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccountCredential.h"

@interface DCTBasicAuthAccountCredential : NSObject <DCTAuthAccountCredential>

- (id)initWithPassword:(NSString *)password;

@end
