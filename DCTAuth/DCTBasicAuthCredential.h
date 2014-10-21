//
//  DCTBasicAuthCredential.h
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountCredential.h"

@interface DCTBasicAuthCredential : NSObject <DCTAuthAccountCredential>

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

@property (nonatomic, readonly) NSString *authorizationHeader;

@end
