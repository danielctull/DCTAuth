//
//  _DCTOAuth2Credential.m
//  DCTAuth
//
//  Created by Daniel Tull on 23/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth2Credential.h"

@implementation _DCTOAuth2Credential

- (id)initWithClientID:(NSString *)clientID
		  clientSecret:(NSString *)clientSecret
				  code:(NSString *)code
		   accessToken:(NSString *)accessToken
		  refreshToken:(NSString *)refreshToken {
	
	if (clientID.length == 0) return nil;
	if (clientSecret.length == 0) return nil;
	if (code.length == 0) return nil;
	if (accessToken.length == 0) return nil;

	self = [super init];
	if (!self) return nil;
	_clientID = [clientID copy];
	_clientSecret = [clientSecret copy];
	_code = [code copy];
	_accessToken = [accessToken copy];
	_refreshToken = [refreshToken copy];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (!self) return nil;
	_clientID = [coder decodeObjectForKey:@"clientID"];
	_clientSecret = [coder decodeObjectForKey:@"clientSecret"];
	_code = [coder decodeObjectForKey:@"code"];
	_accessToken = [coder decodeObjectForKey:@"accessToken"];
	_refreshToken = [coder decodeObjectForKey:@"refreshToken"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.clientID forKey:@"clientID"];
	[coder encodeObject:self.clientSecret forKey:@"clientSecret"];
	[coder encodeObject:self.code forKey:@"code"];
	[coder encodeObject:self.accessToken forKey:@"accessToken"];
	[coder encodeObject:self.refreshToken forKey:@"refreshToken"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; clientID = %@; clientSecret = %@; accessToken = %@; refreshToken = %@>",
			NSStringFromClass([self class]),
			self,
			self.clientID,
			self.clientSecret,
			self.accessToken,
			self.refreshToken];
}

@end
