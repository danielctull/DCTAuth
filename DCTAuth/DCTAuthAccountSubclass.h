//
//  DCTAuthAccountSubclass.h
//  DCTAuth
//
//  Created by Daniel Tull on 27.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "NSURL+DCTAuth.h"
#import "DCTAuthSecureStorage.h"

/** This is a protocol that should be adopted by DCTAuthAccount subclasses. */
@protocol DCTAuthAccountSubclass <NSObject>

/** A method to allow account subclasses to sign a URL request.

 DCTAuthAccount subclasses need to implment this method and use their credentials to modify
 the given mutable request so that it is authorized for the user's account. For example in the
 case of OAuth 1.0, the account adds a signed Authorization header to the request, with the
 correct OAuth parameters.

 @param request The request to be signed.
 @param authRequest The DCTAuthRequest object that is asking for the request to be signed.
 */
- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest;
@end


@interface DCTAuthAccount (SubclassMethods)

- (void)decodeWithSecureStorage:(DCTAuthSecureStorage *)secureStorage;
- (void)encodeWithSecureStorage:(DCTAuthSecureStorage *)secureStorage;

@property (nonatomic, readwrite, getter = isAuthorized) BOOL authorized;

- (void)prepareForDeletion;

@end
