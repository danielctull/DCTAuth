//
//  DTOAuthSignature.m
//  DCTConnectionKit
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "_DCTOAuthSignature.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+DCTOAuth.h"
#import "NSData+DCTOAuth.h"

NSString * const DTOAuthSignatureTypeString[] = {
	@"HMAC-SHA1",
	@"PLAINTEXT"
};

@implementation _DCTOAuthSignature {
	__strong NSURL *_URL;
	__strong NSString *_consumerKey;
	__strong NSString *_consumerSecret;
	__strong NSString *_secretToken;
	__strong NSMutableDictionary *_parameters;
	DCTOAuthRequestMethod _requestMethod;
}

- (id)initWithURL:(NSURL *)URL
	requestMethod:(DCTOAuthRequestMethod)requestMethod
	  consumerKey:(NSString *)consumerKey
   consumerSecret:(NSString *)consumerSecret
			token:(NSString *)token
	  secretToken:(NSString *)secretToken
	   parameters:(NSDictionary *)parameters {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_requestMethod = requestMethod;
	_consumerKey = [consumerKey copy];
	_consumerSecret = [consumerSecret copy];
	_secretToken = [secretToken copy];
	
	_parameters = [NSMutableDictionary new];
	
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	NSString *timestamp = [NSString stringWithFormat:@"%i", (NSInteger)timeInterval];
	NSString *nonce = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString *version = @"1.0";
	if (token) [_parameters setObject:token forKey:@"oauth_token"];
	[_parameters setObject:version forKey:@"oauth_version"];
	[_parameters setObject:nonce forKey:@"oauth_nonce"];
	[_parameters setObject:timestamp forKey:@"oauth_timestamp"];
	[_parameters setObject:_consumerKey forKey:@"oauth_consumer_key"];
	[_parameters setObject:DTOAuthSignatureTypeString[self.type] forKey:@"oauth_signature_method"];
	[_parameters addEntriesFromDictionary:parameters];
	
	return self;
}

- (void)setType:(DCTOAuthSignatureType)type {
	_type = type;
	[_parameters setObject:DTOAuthSignatureTypeString[_type] forKey:@"oauth_signature_method"];
}

- (NSDictionary *)parameters {
	return [_parameters copy];
}

- (NSString *)signedString {
	
	NSMutableArray *parameters = [NSMutableArray new];
	
	NSArray *keys = [[_parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
	
	[keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger i, BOOL *stop) {
		NSString *value = [_parameters objectForKey:key];
		NSString *keyValueString = [NSString stringWithFormat:@"%@=%@", key, [value dctOAuth_URLEncodedString]];
		[parameters addObject:keyValueString];
	}];
	
	NSString *parameterString = [parameters componentsJoinedByString:@"&"];
	
	NSMutableArray *baseArray = [NSMutableArray new];
	[baseArray addObject:[NSStringFromDCTOAuthRequestMethod(_requestMethod) dctOAuth_URLEncodedString]];
	[baseArray addObject:[[_URL absoluteString] dctOAuth_URLEncodedString]];
	[baseArray addObject:[parameterString dctOAuth_URLEncodedString]];
	
	NSString *baseString = [baseArray componentsJoinedByString:@"&"];
	if (!_secretToken) _secretToken = @"";
	NSString *secretString = [NSString stringWithFormat:@"%@&%@", _consumerSecret, _secretToken];
	
	NSData *baseData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
	NSData *secretData = [secretString dataUsingEncoding:NSUTF8StringEncoding];
	
	unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, baseData.bytes, baseData.length, result);
	
	NSData *theData = [NSData dataWithBytes:result length:20];
	NSData *base64EncodedData = [theData dctOAuth_base64EncodedData];
	NSString *string = [[NSString alloc] initWithData:base64EncodedData encoding:NSUTF8StringEncoding];
	return [string dctOAuth_URLEncodedString];
}

@end
