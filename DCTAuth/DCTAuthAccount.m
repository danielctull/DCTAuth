//
//  DCTAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "_DCTAuthAccount.h"
#import "_DCTAuthAccountStore.h"
#import "_DCTOAuth1Account.h"
#import "_DCTOAuth2Account.h"
#import "_DCTBasicAuthAccount.h"
#import "NSString+DCTAuth.h"
#import "DCTAuthAccountSubclass.h"

const struct DCTAuthAccountProperties DCTAuthAccountProperties = {
	.type = @"type",
	.identifier = @"identifier",
	.accountDescription = @"accountDescription",
	.callbackURL = @"callbackURL",
	.userInfo = @"userInfo",
	.saveUUID = @"saveUUID"
};

@interface DCTAuthAccount ()
@property (nonatomic, strong) id<DCTAuthAccountCredential> internalCredential;
@property (nonatomic, copy) NSURL *discoveredCallbackURL;
@property (nonatomic) NSMutableDictionary *extraParameters;
@end

@implementation DCTAuthAccount

+ (instancetype)OAuthAccountWithType:(NSString *)type
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

+ (instancetype)OAuthAccountWithType:(NSString *)type
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

+ (instancetype)OAuth2AccountWithType:(NSString *)type
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

+ (instancetype)OAuth2AccountWithType:(NSString *)type
						 authorizeURL:(NSURL *)authorizeURL
							 username:(NSString *)username
							 password:(NSString *)password
							   scopes:(NSArray *)scopes {

	return [[_DCTOAuth2Account alloc] initWithType:type
									  authorizeURL:authorizeURL
										  username:username
										  password:password
											scopes:scopes];
}

+ (instancetype)basicAuthAccountWithType:(NSString *)type
					   authenticationURL:(NSURL *)authenticationURL
								username:(NSString *)username
								password:(NSString *)password {

	return [[_DCTBasicAuthAccount alloc] initWithType:type
									authenticationURL:authenticationURL
											 username:username
											 password:password];
}

- (instancetype)init {
	self = [super init];
	if (!self) return nil;
	_extraParameters = [NSMutableDictionary new];
	return self;
}

- (instancetype)initWithType:(NSString *)type {
	self = [self init];
	if (!self) return nil;
	_type = [type copy];
	_identifier = [[[NSProcessInfo processInfo] globallyUniqueString] copy];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_type = [coder decodeObjectForKey:DCTAuthAccountProperties.type];
	_identifier = [coder decodeObjectForKey:DCTAuthAccountProperties.identifier];
	_callbackURL = [coder decodeObjectForKey:DCTAuthAccountProperties.callbackURL];
	_accountDescription = [coder decodeObjectForKey:DCTAuthAccountProperties.accountDescription];
	_userInfo = [coder decodeObjectForKey:DCTAuthAccountProperties.userInfo];
	_saveUUID = [coder decodeObjectForKey:DCTAuthAccountProperties.saveUUID];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.type forKey:DCTAuthAccountProperties.type];
	[coder encodeObject:self.identifier forKey:DCTAuthAccountProperties.identifier];
	[coder encodeObject:self.callbackURL forKey:DCTAuthAccountProperties.callbackURL];
	[coder encodeObject:self.accountDescription forKey:DCTAuthAccountProperties.accountDescription];
	[coder encodeObject:self.userInfo forKey:DCTAuthAccountProperties.userInfo];
	[coder encodeObject:self.saveUUID forKey:DCTAuthAccountProperties.saveUUID];
}

- (void)setParameters:(NSDictionary *)parameters forRequestType:(NSString *)requestType {
	NSAssert([parameters isKindOfClass:[NSDictionary class]], @"Needs to be a dictionary");
	[self.extraParameters setObject:[parameters copy] forKey:requestType];
}

- (NSDictionary *)parametersForRequestType:(NSString *)requestType {
	return [self.extraParameters objectForKey:requestType];
}

- (BOOL)isAuthorized {
	return (self.credential != nil);
}

- (id<DCTAuthAccountCredential>)credential {

	if (self.internalCredential)
		return self.internalCredential;

	return [self.accountStore retrieveCredentialForAccount:self];
}

- (void)setCredential:(id<DCTAuthAccountCredential>)credential {

	if (self.accountStore)
		[self.accountStore saveCredential:credential forAccount:self];
	else
		self.internalCredential = credential;
}

- (void)setAccountStore:(DCTAuthAccountStore *)accountStore {

	_accountStore = accountStore;

	if (self.internalCredential) {
		[accountStore saveCredential:self.internalCredential forAccount:self];
		self.internalCredential = nil;
	}
}

- (NSURL *)callbackURL {

	if (_callbackURL) return _callbackURL;

	if (!self.discoveredCallbackURL) {
		NSArray *types = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
		NSDictionary *type = [types lastObject];
		NSArray *schemes = [type objectForKey:@"CFBundleURLSchemes"];
		NSString *scheme = [NSString stringWithFormat:@"%@://%@/", [schemes lastObject], @([self.identifier hash])];
		self.discoveredCallbackURL = [NSURL URLWithString:scheme];
	}
	
	return self.discoveredCallbackURL;
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {}

- (void)reauthenticateWithHandler:(void (^)(DCTAuthResponse *, NSError *))handler {
	NSError *error = [NSError errorWithDomain:@"DCTAuth" code:0 userInfo:@{
		NSLocalizedDescriptionKey : @"Reauthentication not supported for this account type."
	}];
	handler(nil, error);
}

- (void)cancelAuthentication {}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; type = %@; identifier = %@; credential = %@>",
			NSStringFromClass([self class]),
			self,
			self.type,
			self.identifier,
			self.credential];
}

@end
