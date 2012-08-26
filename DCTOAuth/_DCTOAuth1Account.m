//
//  DCTOAuth1Account.m
//  DCTOAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth1Account.h"
#import "_DCTOAuthAccount.h"
#import "DCTOAuthRequest.h"
#import "_DCTOAuthSignature.h"
#import "NSString+DCTOAuth.h"
#import "_DCTOAuthURLProtocol.h"
#import <UIKit/UIKit.h>

@implementation _DCTOAuth1Account {
	__strong NSURL *_requestTokenURL;
	__strong NSURL *_accessTokenURL;
	__strong NSURL *_authorizeURL;
	
	__strong NSString *_consumerKey;
	__strong NSString *_consumerSecret;
	
	__strong NSString *_oauthToken;
	__strong NSString *_oauthTokenSecret;
	__strong NSString *_oauthVerifier;
}

- (id)initWithType:(NSString *)type
   requestTokenURL:(NSURL *)requestTokenURL
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
	   consumerKey:(NSString *)consumerKey
	consumerSecret:(NSString *)consumerSecret {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	
	_requestTokenURL = [coder decodeObjectForKey:@"_requestTokenURL"];
	_accessTokenURL = [coder decodeObjectForKey:@"_accessTokenURL"];
	_authorizeURL = [coder decodeObjectForKey:@"_authorizeURL"];
	
	_consumerKey = [coder decodeObjectForKey:@"_consumerKey"];
	_consumerSecret = [coder decodeObjectForKey:@"_consumerSecret"];
	
	_oauthToken = [coder decodeObjectForKey:@"_oauthToken"];
	_oauthTokenSecret = [coder decodeObjectForKey:@"_oauthTokenSecret"];
	_oauthVerifier = [coder decodeObjectForKey:@"_oauthVerifier"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_requestTokenURL forKey:@"_requestTokenURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	
	[coder encodeObject:_consumerKey forKey:@"_consumerKey"];
	[coder encodeObject:_consumerSecret forKey:@"_consumerSecret"];
	
	[coder encodeObject:_oauthToken forKey:@"_oauthToken"];
	[coder encodeObject:_oauthTokenSecret forKey:@"_oauthTokenSecret"];
	[coder encodeObject:_oauthVerifier forKey:@"_oauthVerifier"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *returnedValues))handler {
	
	NSMutableDictionary *returnedValues = [NSMutableDictionary new];
	
	void (^requestTokenCompletion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		if (handler != NULL) handler([returnedValues copy]);
	};
	
	void (^authorizeCompletion)(NSDictionary *) = ^(NSDictionary *dictionary) {
		[returnedValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		[self fetchRequestTokenWithParameters:dictionary completion:requestTokenCompletion];
	};
	
	void (^accessTokenCompletion)(NSDictionary *) = nil;
	
	if (_authorizeURL) {
		accessTokenCompletion = ^(NSDictionary *dictionary) {
			[returnedValues addEntriesFromDictionary:dictionary];
			[self _setValuesFromOAuthDictionary:dictionary];
			[self authorizeWithParameters:dictionary completion:authorizeCompletion];
		};
	} else {
		accessTokenCompletion = ^(NSDictionary *dictionary) {
			[returnedValues addEntriesFromDictionary:dictionary];
			[self _setValuesFromOAuthDictionary:dictionary];
			[self fetchRequestTokenWithParameters:dictionary completion:requestTokenCompletion];
		};
	}
	
	[self fetchAccessTokenWithParameters:nil completion:accessTokenCompletion];
}

- (void)fetchAccessTokenWithParameters:(NSDictionary *)userParameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:userParameters];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:_requestTokenURL
                                                      requestMethod:DCTOAuthRequestMethodGET
                                                         parameters:parameters];
	
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [string dctOAuth_parameterDictionary];
		completion(dictionary);
	}];
}

- (void)fetchRequestTokenWithParameters:(NSDictionary *)parameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:_accessTokenURL
                                                      requestMethod:DCTOAuthRequestMethodGET
                                                         parameters:parameters];
	
	request.account = self;
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [string dctOAuth_parameterDictionary];
		completion(dictionary);
	}];
}


- (void)authorizeWithParameters:(NSDictionary *)inputParameters completion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	[parameters addEntriesFromDictionary:inputParameters];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	
	NSMutableArray *keyValues = [NSMutableArray new];
	[parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		[keyValues addObject:[NSString stringWithFormat:@"%@=%@", key, [value dctOAuth_URLEncodedString]]];
	}];
	
	NSString *authorizeURLString = [NSString stringWithFormat:@"%@?%@", [_authorizeURL absoluteString], [keyValues componentsJoinedByString:@"&"]];
	NSURL *authorizeURL = [NSURL URLWithString:authorizeURLString];
	
	[_DCTOAuthURLProtocol registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		[_DCTOAuthURLProtocol unregisterForCallbackURL:self.callbackURL];
		
		NSDictionary *dictionary = [[URL query] dctOAuth_parameterDictionary];
		completion(dictionary);
	}];
	[[UIApplication sharedApplication] openURL:authorizeURL];
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"oauth_token"])
			_oauthToken = value;
		
		else if ([key isEqualToString:@"oauth_token_secret"])
			_oauthTokenSecret = value;
		
		else if ([key isEqualToString:@"oauth_verifier"])
			_oauthVerifier = value;
	}];
}

- (NSURLRequest *)_signedURLRequestFromOAuthRequest:(DCTOAuthRequest *)OAuthRequest {
	
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:OAuthRequest.URL
															requestMethod:OAuthRequest.requestMethod
															  consumerKey:_consumerKey
														   consumerSecret:_consumerSecret
																	token:_oauthToken
															  secretToken:_oauthTokenSecret
															   parameters:OAuthRequest.parameters];
	
	NSMutableArray *parameters = [NSMutableArray new];
	[signature.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [key dctOAuth_URLEncodedString];
        NSString *encodedValue = [value dctOAuth_URLEncodedString];
		NSString *string = [NSString stringWithFormat:@"%@=\"%@\"", encodedKey, encodedValue];
		[parameters addObject:string];
	}];
	
	NSString *string = [NSString stringWithFormat:@"oauth_signature=\"%@\"", [signature signedString]];
	[parameters addObject:string];
	NSString *parameterString = [parameters componentsJoinedByString:@","];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:OAuthRequest.URL];
	[request setHTTPMethod:NSStringFromDCTOAuthRequestMethod(OAuthRequest.requestMethod)];
	[request setAllHTTPHeaderFields:@{ @"Authorization" : [NSString stringWithFormat:@"OAuth %@", parameterString]}];
	return request;
}

@end
