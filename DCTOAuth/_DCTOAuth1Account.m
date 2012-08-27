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
	
	_consumerKey = [self _valueForSecureKey:@"_consumerKey"];
	_consumerSecret = [self _valueForSecureKey:@"_consumerSecret"];
	
	_oauthToken = [self _valueForSecureKey:@"_oauthToken"];
	_oauthTokenSecret = [self _valueForSecureKey:@"_oauthTokenSecret"];
	_oauthVerifier = [self _valueForSecureKey:@"_oauthVerifier"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_requestTokenURL forKey:@"_requestTokenURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	
	[self _setValue:_consumerKey forSecureKey:@"_consumerKey"];
	[self _setValue:_consumerSecret forSecureKey:@"_consumerSecret"];
	
	[self _setValue:_oauthToken forSecureKey:@"_oauthToken"];
	[self _setValue:_oauthTokenSecret forSecureKey:@"_oauthTokenSecret"];
	[self _setValue:_oauthVerifier forSecureKey:@"_oauthVerifier"];
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
	[parameters setObject:[self.callbackURL absoluteString] forKey:@""];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_requestTokenURL];
	[self _signURLRequest:request oauthParameters:parameters];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), string);
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
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:_accessTokenURL
                                                      requestMethod:DCTOAuthRequestMethodGET
                                                         parameters:parameters];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), authorizeURL);
	
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

- (void)_signURLRequest:(NSMutableURLRequest *)request oauthParameters:(NSDictionary *)parameters {
	
	NSMutableDictionary *allHTTPHeaderFields = [[request allHTTPHeaderFields] mutableCopy];
	
	NSMutableDictionary *oauthParameters = [NSMutableDictionary new];
	
	[oauthParameters setObject:_consumerKey forKey:@"oauth_consumer_key"];
	if (self.callbackURL) [oauthParameters setObject:[self.callbackURL absoluteString] forKey:@"oauth_callback"];
	if (_oauthToken) [oauthParameters setObject:_oauthToken forKey:@"oauth_token"];
	[oauthParameters addEntriesFromDictionary:parameters];
	
	_DCTOAuthSignature *signature = [[_DCTOAuthSignature alloc] initWithURL:request.URL
																 HTTPMethod:request.HTTPMethod
															 consumerSecret:_consumerSecret
																secretToken:_oauthTokenSecret
																 parameters:oauthParameters];
	
	[allHTTPHeaderFields setObject:[signature authorizationHeader] forKey:@"Authorization"];
	[request setAllHTTPHeaderFields:allHTTPHeaderFields];	
}

- (void)_signURLRequest:(NSMutableURLRequest *)request {
	[self _signURLRequest:request oauthParameters:nil];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; consumerKey = %@; oauth_token = %@>",
			NSStringFromClass([self class]),
			self,
			_consumerKey,
			_oauthToken];
}

@end
