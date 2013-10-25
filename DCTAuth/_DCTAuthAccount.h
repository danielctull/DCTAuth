//
//  _DCTAuthAccount.h
//  DCTAuth
//
//  Created by Daniel Tull on 17/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTAuthAccountCredential.h"

@interface DCTAuthAccount ()
- (NSDictionary *)parametersForRequestType:(NSString *)requestType;
@property (nonatomic, copy) id<DCTAuthAccountCredential> (^credentialFetcher)();
@end
