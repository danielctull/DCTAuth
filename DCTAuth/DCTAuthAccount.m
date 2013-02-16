//
//  DCTAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount.h"
#import "DCTAuthAccountSubclass.h"
#import "_DCTOAuth1Account.h"
#import "_DCTOAuth2Account.h"
#import "_DCTBasicAuthAccount.h"
#import "NSString+DCTAuth.h"

@interface DCTAuthAccount ()
@property (nonatomic, readwrite, getter = isAuthorized) BOOL authorized;
@property (nonatomic, strong) NSURL *discoveredCallbackURL;
@end

@implementation DCTAuthAccount {
	__strong NSURL *_discoveredCallbackURL;
}

+ (DCTAuthAccount *)OAuthAccountWithType:(NSString *)type
						 requestTokenURL:(NSURL *)requestTokenURL
							authorizeURL:(NSURL *)authorizeURL
						  accessTokenURL:(NSURL *)accessTokenURL
							 consumerKey:(NSString *)consumerKey
						  consumerSecret:(NSString *)consumerSecret
						   signatureType:(DCTOAuthSignatureType)signatureType {
	
	return [[_DCTOAuth1Account alloc] initWithType:type
								   requestTokenURL:requestTokenURL
									  authorizeURL:authorizeURL
									accessTokenURL:accessTokenURL
									   consumerKey:consumerKey
									consumerSecret:consumerSecret
									 signatureType:signatureType];
}

+ (DCTAuthAccount *)OAuthAccountWithType:(NSString *)type
						  requestTokenURL:(NSURL *)requestTokenURL
							 authorizeURL:(NSURL *)authorizeURL
						   accessTokenURL:(NSURL *)accessTokenURL
							  consumerKey:(NSString *)consumerKey
						   consumerSecret:(NSString *)consumerSecret {
		
	return [self OAuthAccountWithType:type
					  requestTokenURL:requestTokenURL
						 authorizeURL:authorizeURL
					   accessTokenURL:accessTokenURL
						  consumerKey:consumerKey
					   consumerSecret:consumerSecret
						signatureType:DCTOAuthSignatureTypeHMAC_SHA1];
}

+ (DCTAuthAccount *)OAuth2AccountWithType:(NSString *)type
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

+ (DCTAuthAccount *)basicAuthAccountWithType:(NSString *)type
						   authenticationURL:(NSURL *)authenticationURL
									username:(NSString *)username
									password:(NSString *)password {

	return [[_DCTBasicAuthAccount alloc] initWithType:type
									authenticationURL:authenticationURL
											 username:username
											 password:password];
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
	_userInfo = [coder decodeObjectForKey:NSStringFromSelector(@selector(userInfo))];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.type forKey:NSStringFromSelector(@selector(type))];
	[coder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
	[coder encodeObject:self.callbackURL forKey:NSStringFromSelector(@selector(callbackURL))];
	[coder encodeObject:self.accountDescription forKey:NSStringFromSelector(@selector(accountDescription))];
	[coder encodeBool:self.authorized forKey:NSStringFromSelector(@selector(isAuthorized))];
	[coder encodeObject:self.userInfo forKey:NSStringFromSelector(@selector(userInfo))];
}

- (NSURL *)callbackURL {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
	if (_callbackURL) return _callbackURL;
#pragma clang diagnostic pop

	if (!self.discoveredCallbackURL) {
		NSArray *types = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
		NSDictionary *type = [types lastObject];
		NSArray *schemes = [type objectForKey:@"CFBundleURLSchemes"];
		NSString *scheme = [NSString stringWithFormat:@"%@://%i/", [schemes lastObject], [self.identifier hash]];
		self.discoveredCallbackURL = [NSURL URLWithString:scheme];
	}
	
	return self.discoveredCallbackURL;
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {}
- (void)cancelAuthentication {}

@end

@implementation DCTAuthAccount (SubclassMethods)
@dynamic authorized;

- (void)prepareForDeletion {}

@end
