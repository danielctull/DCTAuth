//
//  NSURL+DCTAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSURL+DCTAuth.h"
#import "NSString+DCTAuth.h"
#import "NSDictionary+DCTAuth.h"

@implementation NSURL (DCTAuth)

- (NSURL *)dctAuth_URLByAddingUser:(NSString *)user password:(NSString *)password {
	return [self dctAuth_URLByAddingUser:user password:password queryParameters:nil];
}

- (NSURL *)dctAuth_URLByAddingQueryParameters:(NSDictionary *)parameters {
	return [self dctAuth_URLByAddingUser:nil password:nil queryParameters:parameters];
}

- (NSURL *)dctAuth_URLByAddingUser:(NSString *)user
						  password:(NSString *)password
				   queryParameters:(NSDictionary *)parameters {

	NSMutableString *URLString = [NSMutableString new];
	
	NSString *scheme = [self scheme];
	if (scheme) [URLString appendFormat:@"%@://", scheme];
	
	if ([user length] == 0) user = [self user];
	if ([password length] == 0) password = [self password];
	if ([user length] > 0 && [password length] > 0)
		[URLString appendFormat:@"%@:%@@", user, password];
	
	[URLString appendString:[self host]];
	
	NSNumber *port = [self port];
	if (port) [URLString appendFormat:@":%@", port];
	
	[URLString appendString:[self path]];


	
	NSMutableArray *queries = [NSMutableArray new];
	NSString *parametersQueryString = [parameters dctAuth_queryString];
	if ([parametersQueryString length] > 0) [queries addObject:parametersQueryString];
	
	NSString *queryString = [self query];
	if ([queryString length] > 0) [queries addObject:queryString];

	NSString *query = [queries componentsJoinedByString:@"&"];
	if ([query length] > 0) [URLString appendFormat:@"?%@", query];



	NSString *fragment = [self fragment];
	if (fragment) [URLString appendFormat:@"#%@", fragment];

	return [NSURL URLWithString:URLString];
}


@end
