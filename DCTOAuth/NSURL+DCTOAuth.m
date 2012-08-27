//
//  NSURL+DCTOAuth.m
//  DCTOAuth
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "NSURL+DCTOAuth.h"
#import "NSString+DCTOAuth.h"
#import "NSDictionary+DCTOAuth.h"

@implementation NSURL (DCTOAuth)

- (NSURL *)dctOAuth_URLByAddingQueryParameters:(NSDictionary *)parameters {
	
	NSMutableString *URLString = [NSMutableString new];
	
	NSString *scheme = [self scheme];
	if (scheme) [URLString appendFormat:@"%@://", scheme];
	
	NSString *user = [self user];
	NSString *password = [self password];
	if ([user length] > 0 && [password length] > 0)
		[URLString appendFormat:@"%@:%@@@", user, password];
	
	[URLString appendString:[self host]];
	
	NSNumber *port = [self port];
	if (port) [URLString appendFormat:@":%@", port];
	
	[URLString appendString:[self path]];
	
	NSMutableDictionary *queryParameters = [NSMutableDictionary new];
	NSDictionary *query = [[self query] dctOAuth_parameterDictionary];
	[queryParameters addEntriesFromDictionary:query];
	[queryParameters addEntriesFromDictionary:parameters];
	NSString *queryString = [queryParameters dctOAuth_queryString];
	if (queryString) [URLString appendFormat:@"?%@", queryString];
	
	return [NSURL URLWithString:URLString];
}


@end
