//
//  DCTAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTAuthAccount+Private.h"
#import "DCTAuthAccountStore+Private.h"
#import "NSString+DCTAuth.h"

const struct DCTAuthAccountProperties DCTAuthAccountProperties = {
	.type = @"type",
	.identifier = @"identifier",
	.accountDescription = @"accountDescription",
	.callbackURL = @"callbackURL",
	.shouldSendCallbackURL = @"shouldSendCallbackURL",
	.userInfo = @"userInfo",
	.saveUUID = @"saveUUID",
	.extraItems = @"extraItems"
};



const struct DCTOAuth2RequestType DCTOAuth2RequestType = {
	.accessToken = @"DCTOAuth2AccountAccessTokenRequestType",
	.authorize = @"DCTOAuth2AccountAuthorizeRequestType",
	.refresh = @"DCTOAuth2AccountRefreshRequestType",
	.signing = @"DCTOAuth2AccountSigningRequestType"
};



@interface DCTAbstractAuthAccount ()
@property (nonatomic, strong) id<DCTAuthAccountCredential> internalCredential;
@property (nonatomic, copy) NSURL *discoveredCallbackURL;
@property (nonatomic) NSMutableDictionary *extraItems;
@end

@implementation DCTAbstractAuthAccount

- (instancetype)init {
	self = [super init];
	if (!self) return nil;
	_extraItems = [NSMutableDictionary new];
	_shouldSendCallbackURL = YES;
	return self;
}

- (instancetype)initWithType:(NSString *)type {
	self = [self init];
	if (!self) return nil;
	_type = [type copy];
	_identifier = [[NSUUID UUID] UUIDString];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (!self) return nil;
	_type = [coder decodeObjectForKey:DCTAuthAccountProperties.type];
	_identifier = [coder decodeObjectForKey:DCTAuthAccountProperties.identifier];
	_callbackURL = [coder decodeObjectForKey:DCTAuthAccountProperties.callbackURL];
	_shouldSendCallbackURL = [coder decodeBoolForKey:DCTAuthAccountProperties.shouldSendCallbackURL];
	_accountDescription = [coder decodeObjectForKey:DCTAuthAccountProperties.accountDescription];
	_userInfo = [coder decodeObjectForKey:DCTAuthAccountProperties.userInfo];
	_saveUUID = [coder decodeObjectForKey:DCTAuthAccountProperties.saveUUID];

	_extraItems = [coder decodeObjectOfClass:[NSArray class] forKey:DCTAuthAccountProperties.extraItems];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.type forKey:DCTAuthAccountProperties.type];
	[coder encodeObject:self.identifier forKey:DCTAuthAccountProperties.identifier];
	[coder encodeObject:self.callbackURL forKey:DCTAuthAccountProperties.callbackURL];
	[coder encodeBool:self.shouldSendCallbackURL forKey:DCTAuthAccountProperties.shouldSendCallbackURL];
	[coder encodeObject:self.accountDescription forKey:DCTAuthAccountProperties.accountDescription];
	[coder encodeObject:self.userInfo forKey:DCTAuthAccountProperties.userInfo];
	[coder encodeObject:self.saveUUID forKey:DCTAuthAccountProperties.saveUUID];
	[coder encodeObject:self.extraItems forKey:DCTAuthAccountProperties.extraItems];
}

- (void)setItems:(NSArray *)items forRequestType:(NSString *)requestType {
	[self.extraItems setObject:[items copy] forKey:requestType];
}

- (NSArray *)itemsForRequestType:(NSString *)requestType {
	return [self.extraItems objectForKey:requestType];
}

- (BOOL)isAuthorized {
	return (self.credential != nil);
}

- (id<DCTAuthAccountCredential>)credential {

	if (self.internalCredential)
		return self.internalCredential;

	NSAssert([self conformsToProtocol:@protocol(DCTAuthAccountSubclass)], @"Should be a subclass.");
	DCTAuthAccount *account = (DCTAuthAccount *)self;
	return [self.accountStore retrieveCredentialForAccount:account];
}

- (void)setCredential:(id<DCTAuthAccountCredential>)credential {

	if (self.accountStore) {
		NSAssert([self conformsToProtocol:@protocol(DCTAuthAccountSubclass)], @"Should be a subclass.");
		DCTAuthAccount *account = (DCTAuthAccount *)self;
		[self.accountStore saveCredential:credential forAccount:account];
	} else {
		self.internalCredential = credential;
	}
}

- (void)setAccountStore:(DCTAuthAccountStore *)accountStore {

	_accountStore = accountStore;

	if (self.internalCredential) {
		NSAssert([self conformsToProtocol:@protocol(DCTAuthAccountSubclass)], @"Should be a subclass.");
		DCTAuthAccount *account = (DCTAuthAccount *)self;
		[accountStore saveCredential:self.internalCredential forAccount:account];
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

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; type = %@; identifier = %@; credential = %@>",
			NSStringFromClass([self class]),
			self,
			self.type,
			self.identifier,
			self.credential];
}

@end
