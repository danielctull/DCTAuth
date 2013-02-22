//
//  DCTOAuth1AccountCredential.m
//  DCTAuth
//
//  Created by Daniel Tull on 22/02/2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTOAuth1AccountCredential.h"

@implementation DCTOAuth1AccountCredential

- (id)initWithConsumerKey:(NSString *)consumerKey
		   consumerSecret:(NSString *)consumerSecret
			   oauthToken:(NSString *)oauthToken
		 oauthTokenSecret:(NSString *)oauthTokenSecret {

	if (consumerKey.length == 0) return nil;
	if (consumerSecret.length == 0) return nil;
	if (oauthToken.length == 0) return nil;
	if (oauthTokenSecret.length == 0) return nil;

	self = [super init];
	if (!self) return nil;
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	_oauthToken = [oauthToken copy];
	_oauthTokenSecret = [oauthTokenSecret copy];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (!self) return nil;
	_consumerKey = [coder decodeObjectForKey:@"consumerKey"];
	_consumerSecret = [coder decodeObjectForKey:@"consumerSecret"];
	_oauthToken = [coder decodeObjectForKey:@"oauthToken"];
	_oauthTokenSecret = [coder decodeObjectForKey:@"oauthTokenSecret"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.consumerKey forKey:@"consumerKey"];
	[coder encodeObject:self.consumerSecret forKey:@"consumerSecret"];
	[coder encodeObject:self.oauthToken forKey:@"oauthToken"];
	[coder encodeObject:self.oauthTokenSecret forKey:@"oauthTokenSecret"];
}

@end
