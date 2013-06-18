//
//  DCTBasicAuthAccountCredential.h
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountCredential.h"

@interface _DCTBasicAuthCredential : NSObject <DCTAuthAccountCredential>

- (id)initWithPassword:(NSString *)password;
@property (nonatomic, readonly) NSString *password;

@end
