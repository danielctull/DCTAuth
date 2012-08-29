//
//  NSURL+DCTAuth.h
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (DCTAuth)

- (NSURL *)dctAuth_URLByAddingQueryParameters:(NSDictionary *)parameters;

@end
