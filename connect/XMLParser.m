//
//  XMLParser.m
//  connect
//
//  Created by Taylor Cuilty on 2/28/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "XMLParser.h"
#import "News.h"

@implementation Parser

-(id) initParser {
    
    if (self == [super init]) {
        app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSInteger *indexCounter;
    
    if ([elementName isEqualToString:@"rss"])
    {
        
        app.xmlArray = [[NSMutableArray alloc] init];
    }
    
    else if ([elementName isEqualToString:@"item"])
    {
        theNews = [[News alloc] init];
        
        theNews.newsTitle = [[attributeDict objectForKey:@"title"] stringValue];
        theNews.newsDate = [[attributeDict objectForKey:@"pubDate"] stringValue];
        theNews.newsSummary = [[attributeDict objectForKey:@"description"] stringValue];
        theNews.newsLink = [[attributeDict objectForKey:@"link"] stringValue];
        theNews.newsIndex = indexCounter;
        
        indexCounter++;
        
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(!currentElementValue)
    {
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [currentElementValue appendString:string];
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"rss"])
    {
        return;
    }
    
    if ([elementName isEqualToString:@"item"])
    {
      app.xmlArray
    }
    
}


@end
