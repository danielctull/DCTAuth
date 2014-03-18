//
//  DCTCertificateAuthURLProtocol.m
//  DCTAuth
//
//  Created by Daniel Tull on 17/03/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTCertificateAuthURLProtocol.h"
#import "DCTCertificateAccount.h"

NSString *const DCTCertificateAuthURLProtocolScheme = @"dctcertificateauth";
NSString *const DCTCertificateAuthURLProtocolAccount = @"DCTCertificateAuthURLProtocolAccount";

@interface DCTCertificateAuthURLProtocol ()
@property (nonatomic) NSURLConnection *connection;
@end

@implementation DCTCertificateAuthURLProtocol

+ (void)load {
	[NSURLProtocol registerClass:[DCTCertificateAuthURLProtocol class]];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	return [request.URL.scheme isEqualToString:DCTCertificateAuthURLProtocolScheme];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	NSMutableURLRequest *mutable = [request mutableCopy];
	NSURLComponents *components = [NSURLComponents componentsWithURL:mutable.URL resolvingAgainstBaseURL:YES];
	components.scheme = @"https";
	mutable.URL = [components URL];
	return [mutable copy];
}

- (void)startLoading {
	NSURLRequest *request = [[self class] canonicalRequestForRequest:self.request];
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[self.connection start];
}

- (void)stopLoading {
	[self.connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	DCTCertificateAccount *account = [NSURLProtocol propertyForKey:DCTCertificateAuthURLProtocolAccount inRequest:self.request];
	NSURLCredential *credential = [account URLCredential];
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

@end
