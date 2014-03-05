//
//  XMLParser.m
//  connect
//
//  Created by Taylor Cuilty on 2/28/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "AppDelegate.h"
#import "XMLParser.h"
#import "News.h"

@implementation XMLParser
@synthesize xmlArray;

-(id) initParser {
    
    if (self == [super init]) {
        AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
        managedObjectContext = [appdelegate managedObjectContext];
        xmlArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"found file and started parsing");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // current element
    element = elementName;
    
    // each news ariticle is an item
    if ([elementName isEqualToString:@"item"]) {
        item = [[NSMutableDictionary alloc] init];
        title = [[NSMutableString alloc] init];
        date = [[NSMutableString alloc] init];
        summary = [[NSMutableString alloc] init];
        link = [[NSMutableString alloc] init];
    }
    
    // need to set the current element value to nil each time we find a new element because of whitespaces
    // in theory there is a delegate method to catch white spaces, but i think it isn't working because the
    // XML file doesn't have a doctype set
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
    
    // Capturing the data from currentElementValue into the associated string
    
    if ([elementName isEqualToString:@"link"]) {
        [link appendString:currentElementValue];
    }
    
    if ([elementName isEqualToString:@"title"]) {
        [title appendString:currentElementValue];
    }
    
    if ([elementName isEqualToString:@"pubDate"]) {
        [date appendString:currentElementValue];
    }
    
    if ([elementName isEqualToString:@"description"]) {
        [summary appendString:currentElementValue];
    }
    
    // end of item, store all the data gathered and add the dictionary object to our xmlArray
    if ([elementName isEqualToString:@"item"]) {
        [item setValue:title forKey:@"title"];
        [item setValue:link forKey:@"link"];
        [item setValue:date forKey:@"date"];
        [item setValue:summary forKey:@"summary"];
        
        [xmlArray addObject:item];
    }
}

@end
