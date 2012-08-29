//
//  DCTOAuthRequest.h
//  DCTOAuthController
//
//  Created by Daniel Tull on 24.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"

typedef enum : NSUInteger {
	DCTAuthRequestMethodGET,
	DCTAuthRequestMethodPOST
} DCTAuthRequestMethod;

NSString * NSStringFromDCTOAuthRequestMethod(DCTAuthRequestMethod method);


@interface DCTAuthRequest : NSObject

- (id)initWithURL:(NSURL *)URL requestMethod:(DCTAuthRequestMethod)requestMethod parameters:(NSDictionary *)parameters;

@property(nonatomic, readonly) NSURL *URL;
@property(nonatomic, readonly) DCTAuthRequestMethod requestMethod;
@property(nonatomic, readonly) NSDictionary *parameters;

@property(nonatomic, strong) DCTAuthAccount *account;
//- (void)addMultiPartData:(NSData *)data withName:(NSString *)name type:(NSString *)type;

- (NSURLRequest *)signedURLRequest;
- (void)performRequestWithHandler:(void(^)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))handler;

@end
