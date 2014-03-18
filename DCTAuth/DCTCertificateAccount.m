//
//  DCTCertificateAccount.m
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTCertificateAccount.h"
#import "DCTCertificateAccountCredential.h"
#import "DCTCertificateAuthURLProtocol.h"
#import "DCTAuthRequest.h"
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

	DCTCertificateAccountCredential *credential = self.credential;
	NSString *password = self.password ? self.password : credential.password;
	NSData *certificate = self.certificate ? self.certificate : credential.certificate;

	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:self.authenticationURL
																 parameters:nil];
	request.account = self;
	[request performRequestWithHandler:^(DCTAuthResponse *response, NSError *error) {

		NSArray *responses;
		if (response) {
			self.credential = [[DCTCertificateAccountCredential alloc] initWithCertificate:certificate password:password];
			responses = @[response];
		} else {
			self.credential = nil;
		}

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
	URLComponents.scheme = [DCTCertificateAuthURLProtocol modifiedSchemeForScheme:URLComponents.scheme];
	request.URL = [URLComponents URL];

	[DCTCertificateAuthURLProtocol setAccount:self forRequest:request];
}

- (NSURLCredential *)URLCredential {

	DCTCertificateAccountCredential *credential = self.credential;
	NSString *password = self.password ? self.password : credential.password;

	if (!password) return nil;

	NSDictionary *options = @{ (__bridge id)kSecImportExportPassphrase : password };

	CFArrayRef itemsRef = CFArrayCreate(NULL, 0, 0, NULL);
	OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)self.certificate, (__bridge CFDictionaryRef)options, &itemsRef);
	NSArray *items = (__bridge NSArray *)itemsRef;
	CFRelease(itemsRef);

	if (securityError != errSecSuccess) return nil;

	NSDictionary *information =  [items firstObject];

	SecIdentityRef identityRef = (__bridge SecIdentityRef)information[(__bridge id)kSecImportItemIdentity];

	SecCertificateRef certificateRef;
	SecIdentityCopyCertificate(identityRef, &certificateRef);
	NSArray *certificates = @[(__bridge id)certificateRef];

	return [NSURLCredential credentialWithIdentity:identityRef
									  certificates:certificates
									   persistence:NSURLCredentialPersistenceNone];
}

@end
