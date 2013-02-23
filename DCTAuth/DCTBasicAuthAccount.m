//
//  _DCTBasicAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTBasicAuthAccount.h"
#import "DCTBasicAuthAccountCredential.h"
#import "DCTAuthRequest.h"
#import "NSData+DCTAuth.h"

@interface DCTBasicAuthAccount ()
@property (nonatomic, strong) NSURL *authenticationURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation DCTBasicAuthAccount

- (id)initWithType:(NSString *)type
 authenticationURL:(NSURL *)authenticationURL
		  username:(NSString *)username
		  password:(NSString *)password {

	self = [super initWithType:type];
	if (!self) return nil;

	_authenticationURL = [authenticationURL copy];
	_username = [username copy];
	_password = [password copy];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	_authenticationURL = [coder decodeObjectForKey:@"_authenticationURL"];
	_username = [coder decodeObjectForKey:@"_username"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authenticationURL forKey:@"_authenticationURL"];
	[coder encodeObject:self.username forKey:@"_username"];
}

- (void)authenticateWithHandler:(void(^)(NSArray *responses, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authenticationURL
																 parameters:nil];

	DCTBasicAuthAccountCredential *credential = self.credential;
	NSString *password = (self.password != nil) ? self.password : credential.password;
	NSString *authorisationString = [self authorizationStringForUsername:self.username password:password];
	request.HTTPHeaders = @{ @"Authorization" : authorisationString };

	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

		if (response.statusCode == 200)
			self.credential = [[DCTBasicAuthAccountCredential alloc] initWithPassword:password];

		if (handler != NULL) handler(@[response], error);
	}];
}

- (NSString *)authorizationStringForUsername:(NSString *)username password:(NSString *)password {
	NSString *authorisationString = [NSString stringWithFormat:@"%@:%@", username, password];
	NSData *authorisationData = [authorisationString dataUsingEncoding:NSUTF8StringEncoding];
	authorisationData = [authorisationData dctAuth_base64EncodedData];
	NSString *authorisationEncodedString = [[NSString alloc] initWithData:authorisationData encoding:NSUTF8StringEncoding];
	return [NSString stringWithFormat:@"Basic %@", authorisationEncodedString];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)oauthRequest {

	DCTBasicAuthAccountCredential *credential = self.credential;
	if (!credential) return;

	NSString *authorisationString = [self authorizationStringForUsername:self.username password:credential.password];
	[request addValue:authorisationString forHTTPHeaderField:@"Authorization"];
}

@end
