//
//  DCTCertificateCredential.h
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccountCredential.h"

@interface DCTCertificateCredential : NSObject <DCTAuthAccountCredential>

- (instancetype)initWithCertificate:(NSData *)certificate
						   password:(NSString *)password;

@property (nonatomic, readonly) NSData *certificate;
@property (nonatomic, readonly) NSString *password;

@end
