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
    
    if ([elementName isEqualToString:@"item"])
    {
        NSLog(@"Item found");
        NSEntityDescription *newsEntityDesc = [NSEntityDescription entityForName:@"News" inManagedObjectContext:managedObjectContext];
        theNews = [[News alloc]initWithEntity:newsEntityDesc insertIntoManagedObjectContext:managedObjectContext];
        NSLog(@"%@",attributeDict);
        theNews.newsTitle = [[attributeDict objectForKey:@"title"] stringValue];
        theNews.newsDate = [[attributeDict objectForKey:@"pubDate"] stringValue];
        theNews.newsSummary = [[attributeDict objectForKey:@"description"] stringValue];
        theNews.newsLink = [[attributeDict objectForKey:@"link"] stringValue];
        
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
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
    
    if ([elementName isEqualToString:@"item"]) {
        [xmlArray addObject:theNews];
        
        theNews = nil;
    }
}

@end
