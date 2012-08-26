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

@implementation DCTOAuthAccount {
	__strong NSURL *_discoveredCallbackURL;
}

+ (DCTOAuthAccount *)OAuthAccountWithType:(NSString *)type
						  requestTokenURL:(NSURL *)requestTokenURL
							 authorizeURL:(NSURL *)authorizeURL
						   accessTokenURL:(NSURL *)accessTokenURL
							  consumerKey:(NSString *)consumerKey
						   consumerSecret:(NSString *)consumerSecret {
		
	return [[_DCTOAuth1Account alloc] initWithType:type
								  requestTokenURL:requestTokenURL
									 authorizeURL:authorizeURL
								   accessTokenURL:accessTokenURL
									  consumerKey:consumerKey
								   consumerSecret:consumerSecret];
}

+ (DCTOAuthAccount *)OAuth2AccountWithType:(NSString *)type
							  authorizeURL:(NSURL *)authorizeURL
							accessTokenURL:(NSURL *)accessTokenURL
								  clientID:(NSString *)clientID
							  clientSecret:(NSString *)clientSecret {
	
	return [[_DCTOAuth2Account alloc] initWithType:type
									  authorizeURL:authorizeURL
									accessTokenURL:accessTokenURL
										  clientID:clientID
									  clientSecret:clientSecret];
}

- (NSURL *)callbackURL {
	
	if (_callbackURL) return _callbackURL;
	
	if (!_discoveredCallbackURL) {
		NSArray *types = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
		NSDictionary *type = [types lastObject];
		NSArray *schemes = [type objectForKey:@"CFBundleURLSchemes"];
		NSString *scheme = [NSString stringWithFormat:@"%@://", [schemes lastObject]];
		_discoveredCallbackURL = [NSURL URLWithString:scheme];
	}
	
	return _discoveredCallbackURL;
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
	_callbackURL = [coder decodeObjectForKey:NSStringFromSelector(@selector(callbackURL))];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.type forKey:NSStringFromSelector(@selector(type))];
	[coder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
	[coder encodeObject:self.callbackURL forKey:NSStringFromSelector(@selector(callbackURL))];
}

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest {
	return nil;
}

@end
