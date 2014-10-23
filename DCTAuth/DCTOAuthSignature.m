//
//  DCTOAuthSignature.m
//  DCTAuth
//
//  Created by Daniel Tull on 04.07.2010.
//  Copyright 2010 Daniel Tull. All rights reserved.
//

#import "DCTOAuthSignature.h"
#import "DCTOAuth1.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+DCTAuth.h"
#import "NSData+DCTAuth.h"

static NSString * const DTOAuthSignatureTypeString[] = {
	@"HMAC-SHA1",
	@"PLAINTEXT"
};

@interface DCTOAuthSignature ()
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSString *consumerSecret;
@property (nonatomic, readonly) NSString *secretToken;
@property (nonatomic, readonly) NSString *HTTPMethod;
@property (nonatomic, readonly) NSMutableDictionary *parameters;
@property (nonatomic, readonly) DCTOAuthSignatureType type;
@end

@implementation DCTOAuthSignature

- (instancetype)initWithURL:(NSURL *)URL
				 HTTPMethod:(NSString *)HTTPMethod
			 consumerSecret:(NSString *)consumerSecret
				secretToken:(NSString *)secretToken
				 parameters:(NSDictionary *)parameters
					   type:(DCTOAuthSignatureType)type {
	
	self = [self init];
	if (!self) return nil;
	
	_URL = [URL copy];
	_HTTPMethod = [HTTPMethod copy];
	_consumerSecret = [consumerSecret copy];
	_secretToken = secretToken ? [secretToken copy] : @"";
	_parameters = [NSMutableDictionary new];
	_type = type;
	
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	NSString *timestamp = [@((NSInteger)timeInterval) stringValue];
	NSString *nonce = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString *version = @"1.0";

	_parameters[DCTOAuth1Keys.version] = version;
	_parameters[DCTOAuth1Keys.nonce] = nonce;
	_parameters[DCTOAuth1Keys.timestamp] = timestamp;
	_parameters[DCTOAuth1Keys.signatureMethod] = DTOAuthSignatureTypeString[type];
	[_parameters addEntriesFromDictionary:parameters];
	
	return self;
}

- (NSString *)signatureBaseString {

	NSMutableDictionary *parameters = [self.parameters mutableCopy];
	NSDictionary *queryDictionary = [[self.URL query] dctAuth_parameterDictionary];
	[parameters addEntriesFromDictionary:queryDictionary];

	NSArray *keys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];

	NSMutableArray *parameterStrings = [NSMutableArray new];
	[keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger i, BOOL *stop) {
		NSString *value = [parameters objectForKey:key];
		NSString *keyValueString = [NSString stringWithFormat:@"%@=%@", key, [value dctAuth_URLEncodedString]];
		[parameterStrings addObject:keyValueString];
	}];
	
	NSString *parameterString = [parameterStrings componentsJoinedByString:@"&"];

	NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:self.URL resolvingAgainstBaseURL:YES];
	URLComponents.query = nil;
	URLComponents.fragment = nil;

	NSMutableArray *baseArray = [NSMutableArray new];
	[baseArray addObject:self.HTTPMethod];
	[baseArray addObject:[[URLComponents.URL absoluteString] dctAuth_URLEncodedString]];
	[baseArray addObject:[parameterString dctAuth_URLEncodedString]];

	return [baseArray componentsJoinedByString:@"&"];
}

- (NSString *)signatureString {
	
	NSString *baseString = [self signatureBaseString];
	NSString *secretString = [NSString stringWithFormat:@"%@&%@", self.consumerSecret, self.secretToken];
	
	NSData *baseData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
	NSData *secretData = [secretString dataUsingEncoding:NSUTF8StringEncoding];
	
	unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, baseData.bytes, baseData.length, result);
	
	NSData *theData = [NSData dataWithBytes:result length:20];
	return [theData dctAuth_base64EncodedString];
}

- (NSString *)authorizationHeader {
	
	NSMutableArray *parameters = [NSMutableArray new];
	[self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [[key description] dctAuth_URLEncodedString];
        NSString *encodedValue = [[value description] dctAuth_URLEncodedString];
		NSString *string = [NSString stringWithFormat:@"%@=\"%@\"", encodedKey, encodedValue];
		[parameters addObject:string];
	}];

	switch (self.type) {

		case DCTOAuthSignatureTypeHMAC_SHA1: {
			NSString *signature = [NSString stringWithFormat:@"%@=\"%@\"", DCTOAuth1Keys.signature, [self.signatureString dctAuth_URLEncodedString]];
			[parameters addObject:signature];
			break;
		}

		case DCTOAuthSignatureTypePlaintext: {
			NSString *secretToken = self.secretToken ?: @"";
			NSString *signature = [NSString stringWithFormat:@"%@=\"%@&%@\"", DCTOAuth1Keys.signature, self.consumerSecret, secretToken];
			[parameters addObject:signature];
			break;
		}
	}

	NSString *parameterString = [parameters componentsJoinedByString:@","];	
	return [NSString stringWithFormat:@"%@ %@", DCTOAuth1Keys.OAuth, parameterString];
}

@end
