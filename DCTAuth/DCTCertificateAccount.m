//
//  DCTCertificateAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTCertificateAccount.h"
#import "DCTAuthRequest.h"
#import "DCTCertificateAuthURLProtocol.h"
@import Security;

static const struct DCTCertificateAccountProperties {
	__unsafe_unretained NSString *authenticationURL;
} DCTCertificateAccountProperties;

static const struct DCTCertificateAccountProperties DCTCertificateAccountProperties = {
	.authenticationURL = @"authenticationURL"
};

@interface DCTCertificateAccount ()
@property (nonatomic) NSURL *authenticationURL;
@property (nonatomic) NSData *certificate;
@property (nonatomic) NSString *password;
@end

@implementation DCTCertificateAccount

#pragma mark - DCTCertificateAccount

- (instancetype)initWithType:(NSString *)type
		   authenticationURL:(NSURL *)authenticationURL
				 certificate:(NSData *)certificate
					password:(NSString *)password {

	self = [super initWithType:type];
	if (!self) return nil;
	_authenticationURL = [authenticationURL copy];
	_certificate = [certificate copy];
	_password = [password copy];
	return self;
}

#pragma mark - DCTAuthAccount

- (void)authenticateWithHandler:(void (^)(NSArray *responses, NSError *error))handler {

//	[self extractInformationFromCertificate:self.certificate
//								   password:self.password
//								 completion:^(SecIdentityRef identity, SecTrustRef trust) {
//									 NSLog(@"%@:%@ %@ %@", self, NSStringFromSelector(_cmd), identity, trust);
//								 }];

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authenticationURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

		NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), response);

		NSArray *responses;
		if (response) responses = @[response];

		handler(responses, error);
	}];
}

- (void)extractInformationFromCertificate:(NSData *)certificate
								 password:(NSString *)password
							   completion:(void(^)(SecIdentityRef identity, SecTrustRef trust))completion {

	NSDictionary *options = @{ (__bridge id)kSecImportExportPassphrase : password };

	CFArrayRef itemsRef = CFArrayCreate(NULL, 0, 0, NULL);
	OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)certificate, (__bridge CFDictionaryRef)options, &itemsRef);
	NSArray *items = (__bridge NSArray *)itemsRef;
	CFRelease(itemsRef);

	if (securityError != errSecSuccess) return;

	NSDictionary *information =  [items firstObject];

	SecIdentityRef identity = (__bridge SecIdentityRef)information[(__bridge id)kSecImportItemIdentity];
	SecTrustRef trust = (__bridge SecTrustRef)information[(__bridge id)kSecImportItemTrust];
	completion(identity, trust);
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [self initWithCoder:coder];
	if (!self) return nil;
	_authenticationURL = [coder decodeObjectForKey:DCTCertificateAccountProperties.authenticationURL];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.authenticationURL forKey:DCTCertificateAccountProperties.authenticationURL];
}

#pragma mark - DCTAuthAccountSubclass

- (void)signURLRequest:(NSMutableURLRequest *)request
		forAuthRequest:(DCTAuthRequest *)authRequest {

	NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
	URLComponents.scheme = DCTCertificateAuthURLProtocolScheme;
	request.URL = [URLComponents URL];

	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), request);

	[DCTCertificateAuthURLProtocol setProperty:self forKey:DCTCertificateAuthURLProtocolAccount inRequest:request];
}

- (NSURLCredential *)URLCredential {

	NSDictionary *options = @{ (__bridge id)kSecImportExportPassphrase : self.password };

	CFArrayRef itemsRef = CFArrayCreate(NULL, 0, 0, NULL);
	OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)self.certificate, (__bridge CFDictionaryRef)options, &itemsRef);
	NSArray *items = (__bridge NSArray *)itemsRef;
	CFRelease(itemsRef);

	if (securityError != errSecSuccess) return nil;

	NSDictionary *information =  [items firstObject];

	SecIdentityRef identityRef = (__bridge SecIdentityRef)information[(__bridge id)kSecImportItemIdentity];
	//SecTrustRef trust = (__bridge SecTrustRef)information[(__bridge id)kSecImportItemTrust];

	SecCertificateRef certificateRef;
	SecIdentityCopyCertificate(identityRef, &certificateRef);
	NSArray *certificates = @[(__bridge id)certificateRef];

	NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identityRef
															 certificates:certificates
															  persistence:NSURLCredentialPersistenceForSession];
	return credential;
//
//	NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:self.authenticationURL.host
//																				  port:[self.authenticationURL.port integerValue]
//																			  protocol:self.authenticationURL.scheme
//																				 realm:nil
//																  authenticationMethod:nil];
//
//	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:protectionSpace];
}

@end
