//
//  DCTOAuth2RequestType.h
//  DCTAuth
//
//  Created by Daniel Tull on 17.01.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;

extern const struct DCTOAuth2RequestType {
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *authorize;
	__unsafe_unretained NSString *refresh;
	__unsafe_unretained NSString *signing;
} DCTOAuth2RequestType;
