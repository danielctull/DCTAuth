//
//  DCTAuthAccount+Private.h
//  DCTAuth
//
//  Created by Daniel Tull on 17/06/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTAuthAccountCredential.h"
#import "DCTAuthAccountStore.h"

@interface DCTAuthAccount ()
//@property (nonatomic, copy) id<DCTAuthAccountCredential> (^credentialFetcher)();
@property (nonatomic, copy) NSString *saveUUID;
@property (nonatomic, weak) DCTAuthAccountStore *accountStore;
@end
