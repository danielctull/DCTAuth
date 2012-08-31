//
//  DCTAuth.m
//  DCTAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTAuth.h"
#import "_DCTAuthURLOpener.h"
@implementation DCTAuth

+ (BOOL)handleURL:(NSURL *)URL {
	return [[_DCTAuthURLOpener sharedURLOpener] handleURL:URL];
}

@end
