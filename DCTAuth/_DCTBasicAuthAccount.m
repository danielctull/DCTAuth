//
//  _DCTBasicAuthAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTBasicAuthAccount.h"
#import "DCTAuthRequest.h"
#import "NSData+DCTAuth.h"

@interface _DCTBasicAuthAccount ()
@property (nonatomic, strong) NSURL *authenticationURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation _DCTBasicAuthAccount

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
	_username = [self secureValueForKey:@"_username"];
	_password = [self secureValueForKey:@"_password"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authenticationURL forKey:@"_authenticationURL"];
	[self setSecureValue:self.username forKey:@"_username"];
	[self setSecureValue:self.password forKey:@"_password"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {

	self.authorized = NO;

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authenticationURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *urlResponse, NSError *error) {

		self.authorized = (urlResponse.statusCode == 200);

		if (handler == NULL) return;
		
		NSMutableDictionary *results = [NSMutableDictionary new];
		if (data) [results setObject:data forKey:@"data"];

		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (string) [results setObject:string forKey:@"dataString"];

		[results setObject:@(urlResponse.statusCode) forKey:@"statusCode"];

		handler([results copy], error);
	}];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)oauthRequest {

	NSString *authorisationString = [NSString stringWithFormat:@"%@:%@", self.username, self.password];

	NSData *authorisationData = [authorisationString dataUsingEncoding:NSUTF8StringEncoding];
	authorisationData = [authorisationData dctAuth_base64EncodedData];

	NSString *authorisationEncodedString = [[NSString alloc] initWithData:authorisationData encoding:NSUTF8StringEncoding];
	authorisationString = [NSString stringWithFormat:@"Basic %@", authorisationEncodedString];

	[request addValue:authorisationString forHTTPHeaderField:@"Authorization"];
}

@end
