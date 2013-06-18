//
//  DCTAuthContentType.h
//  DCTAuth
//
//  Created by Daniel Tull on 30.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

@import Foundation;

extern NSString *const DCTAuthContentTypeParameterCharset;

typedef NS_ENUM(NSInteger, DCTAuthContentTypeType) {
	DCTAuthContentTypeUnknown,
	DCTAuthContentTypeTextPlain,
	DCTAuthContentTypeTextHTML,
	DCTAuthContentTypeJSON,
	DCTAuthContentTypePlist
};

@interface _DCTAuthContentType : NSObject

- (id)initWithString:(NSString *)string;
- (id)initWithContentType:(DCTAuthContentTypeType)contentType;
- (id)initWithContentType:(DCTAuthContentTypeType)contentType parameters:(NSDictionary *)parameters;

@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) DCTAuthContentTypeType contentType;
@property (nonatomic, readonly) NSStringEncoding stringEncoding;

@end
