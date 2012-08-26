//
//  DCTOAuthAccount.m
//  DTOAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTOAuthAccount.h"
#import "_DCTOAuthAccount.h"
#import "_DCTOAuth1Account.h"
#import "_DCTOAuth2Account.h"

@implementation DCTOAuthAccount

+ (DCTOAuthAccount *)OAuthAccountWithType:(NSString *)type
						  requestTokenURL:(NSURL *)requestTokenURL
							 authorizeURL:(NSURL *)authorizeURL
							  callbackURL:(NSURL *)callbackURL
						   accessTokenURL:(NSURL *)accessTokenURL
							  consumerKey:(NSString *)consumerKey
						   consumerSecret:(NSString *)consumerSecret {
		
	return [[_DCTOAuth1Account alloc] initWithType:type
								  requestTokenURL:requestTokenURL
									 authorizeURL:authorizeURL
									  callbackURL:callbackURL
								   accessTokenURL:accessTokenURL
									  consumerKey:consumerKey
								   consumerSecret:consumerSecret];
}

+ (DCTOAuthAccount *)OAuth2AccountWithType:(NSString *)type
							  authorizeURL:(NSURL *)authorizeURL
							   redirectURL:(NSURL *)redirectURL
							accessTokenURL:(NSURL *)accessTokenURL
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret {
	
	return [[_DCTOAuth2Account alloc] initWithType:type
									 authorizeURL:authorizeURL
									  redirectURL:redirectURL
								   accessTokenURL:accessTokenURL
										 clientID:clientID
									 clientSecret:clientSecret];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {}
- (void)renewCredentialsWithHandler:(void(^)(BOOL success, NSError *error))handler {}

@end

@implementation DCTOAuthAccount (Private)

- (id)initWithType:(NSString *)type {
	self = [super init];
	if (!self) return nil;
	_type = [type copy];
	_identifier = [[[NSProcessInfo processInfo] globallyUniqueString] copy];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_type = [coder decodeObjectForKey:NSStringFromSelector(@selector(type))];
	_identifier = [coder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.type forKey:NSStringFromSelector(@selector(type))];
	[coder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
}

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest {
	return nil;
}

@end
