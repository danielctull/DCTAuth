//
//  DCTAuth.h
//  DCTAuth
//
//  Created by Daniel Tull on 25/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTAuthAccount.h"
#import "DCTAuthAccountStore.h"
#import "DCTAuthRequest.h"

/** DCTAuth is a library to handle multiple authentication types for services 
 that use OAuth, OAuth 2.0 and basic authentication.
 */
@interface DCTAuth : NSObject 
/** Applications should call this method when they get opened with a URL
 to handle OAuth and OAuth 2.0 callbacks. This would be 
 application:handleOpenURL and
 application:openURL:sourceApplication:annotation: on iOS. 
 @param URL The URL that was called to open the application.
 @return YES if the URL was handled; NO if it wasn't handled.
 */
+ (BOOL)handleURL:(NSURL *)URL;

+ (void)setURLOpener:(BOOL(^)(NSURL *URL))opener;

@end
