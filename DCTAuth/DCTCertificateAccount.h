//
//  DCTCertificateAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountSubclass.h"

@interface DCTCertificateAccount : DCTAuthAccount <DCTAuthAccountSubclass>

- (instancetype)initWithType:(NSString *)type
		   authenticationURL:(NSURL *)authenticationURL
				 certificate:(NSData *)certificate
					password:(NSString *)password;

- (NSURLCredential *)URLCredential;

@end
