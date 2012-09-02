//
//  _DCTAuthMultipartData.m
//  DCTAuth
//
//  Created by Daniel Tull on 02/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTAuthMultipartData.h"

@implementation _DCTAuthMultipartData

- (NSData *)dataWithBoundary:(NSString *)boundary {
	NSMutableData *body = [NSMutableData new];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", self.name] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", self.type] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:self.data];
	[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	return [body copy];
}

@end
