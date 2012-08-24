//
//  DTOAuthController.m
//  DTOAuthController
//
//  Created by Daniel Tull on 09.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTOAuthController.h"
#import "DCTOAuthURLProtocol.h"
#import "DCTOAuthSignature.h"
#import "DCTOAuthRequest.h"
#import <UIKit/UIKit.h>

NSString * const DCTOAuthMethodString[] = {
	@"GET",
	@"POST"
};

@implementation DCTOAuthController {
	__strong DCTOAuthSignature *_signature;
}

- (id)initWithRequestTokenURL:(NSURL *)requestTokenURL
				 authorizeURL:(NSURL *)authorizeURL
				  callbackURL:(NSURL *)callbackURL
			   accessTokenURL:(NSURL *)accessTokenURL
				  consumerKey:(NSString *)consumerKey
			   consumerSecret:(NSString *)consumerSecret {
	
	self = [super init];
	if (!self) return nil;
	
	_requestTokenURL = [requestTokenURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_authorizeURL = [authorizeURL copy];
	_callbackURL = [callbackURL copy];
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	
	return self;
}

- (void)fetchAccessTokenCompletion:(void(^)(NSDictionary *returnedValues))completion {
	
	NSDictionary *parameters = nil;
	if (self.callbackURL)
		parameters = @{ @"oauth_callback" : [self.callbackURL absoluteString] };
	
	NSURLRequest *request = [self _URLRequestWithURL:self.requestTokenURL
									   requestMethod:DCTOAuthRequestMethodGET
										  parameters:parameters];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *reaponse, NSData *data, NSError *error) {
		
		NSMutableDictionary *returnValues = [NSMutableDictionary new];
		
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [self _dictionaryFromString:string];
		[returnValues addEntriesFromDictionary:dictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		
		NSString *authorizeURLString = [NSString stringWithFormat:@"%@?%@&oauth_callback=%@", [self.authorizeURL absoluteString], string, [self _URLEncodedString:[self.callbackURL absoluteString]]];
		NSURL *authorizeURL = [NSURL URLWithString:authorizeURLString];
		
		[DCTOAuthURLProtocol registerForCallbackURL:self.callbackURL handler:^(NSURL *URL) {
			[DCTOAuthURLProtocol unregisterForCallbackURL:self.callbackURL];
			
			NSDictionary *dictionary = [self _dictionaryFromString:[URL query]];
			[returnValues addEntriesFromDictionary:dictionary];
			[self _setValuesFromOAuthDictionary:dictionary];
			
			NSURLRequest *request = [self _URLRequestWithURL:self.accessTokenURL
											   requestMethod:DCTOAuthRequestMethodGET
												  parameters:dictionary];
			
			[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *reaponse, NSData *data, NSError *error) {
				
				NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSDictionary *dictionary = [self _dictionaryFromString:string];
				[returnValues addEntriesFromDictionary:dictionary];
				[self _setValuesFromOAuthDictionary:dictionary];
				
				if (completion != NULL) completion([returnValues copy]);
			}];
		}];
		
		[[UIApplication sharedApplication] openURL:authorizeURL];
	}];
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

- (NSDictionary *)_dictionaryFromString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@"&"];
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	[components enumerateObjectsUsingBlock:^(NSString *keyValueString, NSUInteger idx, BOOL *stop) {
		NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
		[dictionary setObject:[keyValueArray objectAtIndex:1] forKey:[keyValueArray objectAtIndex:0]];
	}];
	return [dictionary copy];
}

- (NSURLRequest *)_URLRequestWithURL:(NSURL *)URL requestMethod:(DCTOAuthRequestMethod)requestMethod parameters:(NSDictionary *)parameters {
		
	DCTOAuthSignature *signature = [[DCTOAuthSignature alloc] initWithURL:URL
															requestMethod:requestMethod
															  consumerKey:self.consumerKey
														   consumerSecret:self.consumerSecret
																	token:self.oauthToken
															  secretToken:self.oauthTokenSecret
															   parameters:parameters];
	
	DCTOAuthRequest *request = [[DCTOAuthRequest alloc] initWithURL:URL
															 method:requestMethod
														  signature:signature];
	return [request signedRequest];
}

- (NSString *)_URLEncodedString:(NSString *)string {
	
	return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
																				  (CFStringRef)objc_unretainedPointer(string),
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
}
			  
@end
