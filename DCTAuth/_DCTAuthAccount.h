//
//  _DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 17/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTAuthAccountCredential.h"

extern const struct DCTAuthAccountProperties {
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *accountDescription;
	__unsafe_unretained NSString *callbackURL;
	__unsafe_unretained NSString *userInfo;
	__unsafe_unretained NSString *saveUUID;
} DCTAuthAccountProperties;

@interface DCTAuthAccount ()
- (NSDictionary *)parametersForRequestType:(NSString *)requestType;
@property (nonatomic, copy) id<DCTAuthAccountCredential> (^credentialFetcher)();
@property (nonatomic, copy) NSString *saveUUID;
@end
