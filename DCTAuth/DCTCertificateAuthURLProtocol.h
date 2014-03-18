//
//  DCTCertificateAuthURLProtocol.h
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

@import Foundation;
@class DCTCertificateAccount;

@interface DCTCertificateAuthURLProtocol : NSURLProtocol

+ (NSString *)modifiedSchemeForScheme:(NSString *)scheme;
+ (NSString *)schemeForModifiedScheme:(NSString *)scheme;

+ (void)setAccount:(DCTCertificateAccount *)account forRequest:(NSMutableURLRequest *)request;
+ (DCTCertificateAccount *)accountForRequest:(NSURLRequest *)request;

@end
