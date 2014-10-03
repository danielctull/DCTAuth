//
//  DCTBasicAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTBasicAuthAccount.h"
#import "DCTBasicAuthCredential.h"
#import "DCTAuthRequest.h"
#import "NSData+DCTAuth.h"

static const struct DCTBasicAuthAccountProperties {
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *authenticationURL;
} DCTBasicAuthAccountProperties;

static const struct DCTBasicAuthAccountProperties DCTBasicAuthAccountProperties = {
	.username = @"username",
	.authenticationURL = @"authenticationURL",
};

@interface DCTBasicAuthAccount ()
@property (nonatomic, strong) NSURL *authenticationURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation DCTBasicAuthAccount

- (instancetype)initWithType:(NSString *)type
 authenticationURL:(NSURL *)authenticationURL
		  username:(NSString *)username
		  password:(NSString *)password {

	self = [self initWithType:type];
	if (!self) return nil;

	_authenticationURL = [authenticationURL copy];
	_username = [username copy];
	_password = [password copy];
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	_authenticationURL = [coder decodeObjectForKey:DCTBasicAuthAccountProperties.authenticationURL];
	_username = [coder decodeObjectForKey:DCTBasicAuthAccountProperties.username];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authenticationURL forKey:DCTBasicAuthAccountProperties.authenticationURL];
	[coder encodeObject:self.username forKey:DCTBasicAuthAccountProperties.username];
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authenticationURL
																 parameters:nil];

	DCTBasicAuthCredential *credential = self.credential;
	NSString *password = (self.password != nil) ? self.password : credential.password;
	NSString *authorisationString = [self authorizationStringForUsername:self.username password:password];
	request.HTTPHeaders = @{ @"Authorization" : authorisationString };

	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

		if (response.statusCode == 200)
			self.credential = [[DCTBasicAuthCredential alloc] initWithPassword:password];

		NSArray *array = response ? @[response] : nil;
		if (handler != NULL) handler(array, error);
	}];
}

- (NSString *)authorizationStringForUsername:(NSString *)username password:(NSString *)password {
	NSString *authorisationString = [NSString stringWithFormat:@"%@:%@", username, password];
	NSData *authorisationData = [authorisationString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *authorisationEncodedString = [authorisationData dctAuth_base64EncodedString];
	return [NSString stringWithFormat:@"Basic %@", authorisationEncodedString];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)oauthRequest {

	DCTBasicAuthCredential *credential = self.credential;
	if (!credential) return;

	NSString *authorisationString = [self authorizationStringForUsername:self.username password:credential.password];
	[request addValue:authorisationString forHTTPHeaderField:@"Authorization"];
}

@end
