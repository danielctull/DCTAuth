//
//  _DCTAuthXMLParser.m
//  DCTAuth
//
//  Created by Daniel Tull on 22.01.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "_DCTAuthXMLParser.h"

@interface _DCTAuthXMLParser () <NSXMLParserDelegate>
@property (nonatomic, readonly) NSData *XMLData;
@property (nonatomic, readonly) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSMutableDictionary *currentElement;
@property (nonatomic, strong) NSMutableString *currentString;
@end

@implementation _DCTAuthXMLParser

- (id)initWithXMLData:(NSData *)XMLData {
	self = [self init];
	if (!self) return nil;
	_XMLData = XMLData;
	return self;
}

- (NSDictionary *)parsedDictionary {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.XMLData];
	[parser parse];
	return [self.dictionary copy];
}

+ (NSDictionary *)dictionaryFromXMLData:(NSData *)data {
	_DCTAuthXMLParser *parser = [[self alloc] initWithData:data];
	return [parser parsedDictionary];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {

	
	self.currentString = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {

	self.currentString = nil;
}

@end
