//
//  DCTAuthAccountCredential.h
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

// Account credentials will always be stored securely.
// DCTAuthAccountStore currently stores credentials in
// the keychain. In the future, credentials may be stored
// in other ways.
@protocol DCTAuthAccountCredential <NSObject, NSCoding>
@end
