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
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"found file and started parsing");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"channel"])
    {
        xmlArray = [[NSMutableArray alloc]init];
    }
    
    else if ([elementName isEqualToString:@"item"])
    {
        NSLog(@"Item found");
        NSEntityDescription *newsEntityDesc = [NSEntityDescription entityForName:@"News" inManagedObjectContext:managedObjectContext];
        theNews = [[News alloc]initWithEntity:newsEntityDesc insertIntoManagedObjectContext:managedObjectContext];
    }
    
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

        currentElementValue = [[NSMutableString alloc] initWithString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"channel"]) {
        return;
    }
    
    NSLog(@"Element Name: %@", elementName);
    NSLog(@"Current Element Value: %@", currentElementValue);
    
    if ([elementName isEqualToString:@"title"]) {
        theNews.newsTitle = currentElementValue;
    }
    
    if ([elementName isEqualToString:@"pubDate"]) {
        theNews.newsDate = currentElementValue;
    }
    
    if ([elementName isEqualToString:@"description"]) {
        theNews.newsSummary = currentElementValue;
    }
    
    if ([elementName isEqualToString:@"link"]) {
        theNews.newsLink = currentElementValue;
    }

    
    if (theNews != nil) {
        [xmlArray addObject:theNews];
    }
    
    currentElementValue = nil;
    
}

@end
