//
//  DCTAuthResponse.h
//  DCTAuth
//
//  Created by Daniel Tull on 22.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	DCTAuthResponseContentTypeForm,
	DCTAuthResponseContentTypeJSON,
	DCTAuthResponseContentTypePlist,
	DCTAuthResponseContentTypeImagePNG,
	DCTAuthResponseContentTypeImageJPEG,
	DCTAuthResponseContentTypeImageTIFF,
	DCTAuthResponseContentTypeImageGIF,
	DCTAuthResponseContentTypeImageICO,
	DCTAuthResponseContentTypeImageX_ICON,
	DCTAuthResponseContentTypeImageBMP,
	DCTAuthResponseContentTypeImageX_BMP,
	DCTAuthResponseContentTypeImageX_XBITMAP,
	DCTAuthResponseContentTypeImageX_WIN_BITMAP
} DCTAuthResponseContentType;

@interface DCTAuthResponse : NSObject

- (id)initWithData:(NSData *)data URLResponse:(NSHTTPURLResponse *)URLResponse;
- (id)initWithURL:(NSURL *)URL;

@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSDictionary *HTTPHeaders;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSHTTPURLResponse *URLResponse;
@property (nonatomic, readonly) DCTAuthResponseContentType contentType;

@property (nonatomic, readonly) id contentObject;

- (NSString *)responseDescription;

@end
