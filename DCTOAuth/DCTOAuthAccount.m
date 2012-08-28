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
#import <Security/Security.h>
#import "NSString+DCTOAuth.h"

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
							  clientSecret:(NSString *)clientSecret
									scopes:(NSArray *)scopes {
	
	return [[_DCTOAuth2Account alloc] initWithType:type
									  authorizeURL:authorizeURL
									accessTokenURL:accessTokenURL
										  clientID:clientID
									  clientSecret:clientSecret
											scopes:scopes];
}

- (NSURL *)callbackURL {
	
	if (_callbackURL) return _callbackURL;
	
	if (!_discoveredCallbackURL) {
		NSArray *types = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
		NSDictionary *type = [types lastObject];
		NSArray *schemes = [type objectForKey:@"CFBundleURLSchemes"];
		NSString *scheme = [NSString stringWithFormat:@"%@://%@", [schemes lastObject], self.identifier];
		_discoveredCallbackURL = [NSURL URLWithString:scheme];
	}
	
	return _discoveredCallbackURL;
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {}
- (void)renewCredentialsWithHandler:(void(^)(BOOL success, NSError *error))handler {}

@end

@implementation DCTOAuthAccount (Private)

- (void)_setAuthorized:(BOOL)authorized {
	[self willChangeValueForKey:@"authorized"];
	_authorized = authorized;
	[self didChangeValueForKey:@"authorized"];
}

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
	_accountDescription = [coder decodeObjectForKey:NSStringFromSelector(@selector(accountDescription))];
	_authorized = [coder decodeBoolForKey:NSStringFromSelector(@selector(isAuthorized))];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.type forKey:NSStringFromSelector(@selector(type))];
	[coder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
	[coder encodeObject:self.callbackURL forKey:NSStringFromSelector(@selector(callbackURL))];
	[coder encodeObject:self.accountDescription forKey:NSStringFromSelector(@selector(accountDescription))];
	[coder encodeBool:_authorized forKey:NSStringFromSelector(@selector(isAuthorized))];
}

- (void)_signURLRequest:(NSMutableURLRequest *)request oauthRequest:(DCTOAuthRequest *)oauthRequest {}

- (void)_willBeDeleted {
	[self _removeValueForSecureKey:nil];
}

- (void)_setValue:(NSString *)value forSecureKey:(NSString *)key {
	if (!value) return;
	if (!key) return;
	
	[self _removeValueForSecureKey:key];
	
	NSMutableDictionary *query = [self _queryForKey:key];
	[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
#ifdef TARGET_OS_IPHONE
	[query setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
#endif
	SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

- (NSString *)_valueForSecureKey:(NSString *)key {
	if (!key) return nil;
	
	NSMutableDictionary *query = [self _queryForKey:key];
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	CFTypeRef result = NULL;
	SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	return [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
}

- (void)_removeValueForSecureKey:(NSString *)key {
	NSMutableDictionary *query = [self _queryForKey:key];
    SecItemDelete((__bridge CFDictionaryRef)query);
}

- (NSMutableDictionary *)_queryForKey:(NSString *)key {
	NSMutableDictionary *query = [NSMutableDictionary new];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:[NSString stringWithFormat:@"DCTOAuth:%@", self.identifier] forKey:(__bridge id)kSecAttrService];
	if (key) [query setObject:key forKey:(__bridge id)kSecAttrAccount];
	return query;
}

@end
