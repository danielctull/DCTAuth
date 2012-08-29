//
//  _DCTBasicAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTBasicAuthAccount.h"
#import "_DCTAuthAccount.h"
#import "NSData+DCTAuth.h"

@implementation _DCTBasicAuthAccount {
	__strong NSURL *_authenticationURL;
	__strong NSString *_username;
	__strong NSString *_password;
}

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
	_username = [self _secureValueForKey:@"_username"];
	_password = [self _secureValueForKey:@"_password"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:_authenticationURL forKey:@"_authenticationURL"];
	[self _setSecureValue:_username forKey:@"_username"];
	[self _setSecureValue:_password forKey:@"_password"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithURL:_authenticationURL
													requestMethod:DCTAuthRequestMethodGET
													   parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

		if (handler == NULL) return;

		handler(@{ @"data" : responseData, @"statusCode" : @(urlResponse.statusCode) });
	}];
}

- (void)_signURLRequest:(NSMutableURLRequest *)request authRequest:(DCTAuthRequest *)oauthRequest {

	NSString *authorisationString = [NSString stringWithFormat:@"%@:%@", _username, _password];

	NSData *authorisationData = [authorisationString dataUsingEncoding:NSUTF8StringEncoding];
	authorisationData = [authorisationData dctAuth_base64EncodedData];

	NSString *authorisationEncodedString = [[NSString alloc] initWithData:authorisationData encoding:NSUTF8StringEncoding];
	authorisationString = [NSString stringWithFormat:@"Basic %@", authorisationEncodedString];

	[request addValue:authorisationString forHTTPHeaderField:@"Authorization"];
}

@end
