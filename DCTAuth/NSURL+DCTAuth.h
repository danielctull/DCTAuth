//
//  NSURL+DCTAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Set of categories to aid the creation of DCTAuthAccount subclasses.
 */
@interface NSURL (DCTAuth)

/** Sets the user and password components of the URL.
 @param user The username to use.
 @param password The password.
 @return A modified NSURL with the user and password components altered.
 */
- (NSURL *)dctAuth_URLBySettingUser:(NSString *)user password:(NSString *)password;

/** Adds the parameters to the query component of the URL.
 
 It will not remove existing query parameters, however if the same
 keys exist then the newer value will be used.
 
 @param parameters The parameters to add.
 @return A modified NSURL with the query component altered.
 */
- (NSURL *)dctAuth_URLByAddingQueryParameters:(NSDictionary *)parameters;

/** Adds the parameters to the query component of the URL.
 
 It will not remove existing query parameters, however if the same
 keys exist then the newer value will be used.
 
 @param componentType The component to remove.
 @return A modified NSURL with the component removed.
 */
- (NSURL *)dctAuth_URLByRemovingComponentType:(CFURLComponentType)componentType;

@end
