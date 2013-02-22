//
//  _DCTBasicAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountSubclass.h"

@interface DCTBasicAuthAccount : DCTAuthAccount <DCTAuthAccountSubclass>

- (id)initWithType:(NSString *)type
 authenticationURL:(NSURL *)authenticationURL
		  username:(NSString *)username
		  password:(NSString *)password;

@end
