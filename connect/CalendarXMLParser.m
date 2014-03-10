//
//  CalendarXMLParser.m
//  connect
//
//  Created by NickPiatt on 3/5/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "CalendarXMLParser.h"

@implementation CalendarXMLParser

@synthesize eventsArray;

-(id)initParser {
    if (self == [super init]) {
        eventsArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"found file and started parsing");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // current element
    element = elementName;
    
    if ([elementName isEqualToString:@"item"]) {
        NSLog(@"New Item Start");
        item = [[NSMutableDictionary alloc]init];
        title = [[NSMutableString alloc]init];
        subTitle = [[NSMutableString alloc]init];
    }
    
    currentElementValue = nil;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // Putting together the values of the different elements
    if(!currentElementValue) {
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    } else {
        [currentElementValue appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"channel"]) {
        return;
    }
    
    if ([elementName isEqualToString:@"title"]) {
        // do something
        [title appendString:currentElementValue];
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:subtitle"]) {
        // do something
        if (currentElementValue != nil) {
            [subTitle appendString:currentElementValue];
        }
//
    }
    if ([elementName isEqualToString:@"item"]) {
        [item setValue:title forKey:@"title"];
        [item setValue:subTitle forKey:@"subtitle"];
        NSLog(@"New Item End");
        [eventsArray addObject:item];
    }
}

@end
