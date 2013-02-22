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
@property (nonatomic, strong) DCTBasicAuthAccountCredential *unauthorizedCredential;
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
	_unauthorizedCredential = [[DCTBasicAuthAccountCredential alloc] initWithPassword:password];
	
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

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authenticationURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

		if (response.statusCode == 200) {
			self.credential = self.unauthorizedCredential;
			self.unauthorizedCredential = nil;
		}

		if (handler == NULL) return;
		
		NSMutableDictionary *results = [NSMutableDictionary new];
		if (response.data) [results setObject:response.data forKey:@"data"];

		NSString *string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
		if (string) [results setObject:string forKey:@"dataString"];

		[results setObject:@(response.statusCode) forKey:@"statusCode"];

		handler([results copy], error);
	}];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)oauthRequest {

	DCTBasicAuthAccountCredential *credential = self.credential;
	if (!credential) credential = self.unauthorizedCredential;
	if (!credential) return;

	NSString *authorisationString = [NSString stringWithFormat:@"%@:%@", self.username, credential.password];

	NSData *authorisationData = [authorisationString dataUsingEncoding:NSUTF8StringEncoding];
	authorisationData = [authorisationData dctAuth_base64EncodedData];

	NSString *authorisationEncodedString = [[NSString alloc] initWithData:authorisationData encoding:NSUTF8StringEncoding];
	authorisationString = [NSString stringWithFormat:@"Basic %@", authorisationEncodedString];

	[request addValue:authorisationString forHTTPHeaderField:@"Authorization"];
}

@end
