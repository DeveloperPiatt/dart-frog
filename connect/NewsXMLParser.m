//
//  NewsXMLParser.m
//  connect
//
//  Created by Taylor Cuilty on 2/28/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsXMLParser.h"
#import "News.h"

@implementation NewsXMLParser
@synthesize xmlArray;

-(id) initParser {
    
    if (self == [super init]) {
        AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
        managedObjectContext = [appdelegate managedObjectContext];
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"Found file and started parsing");
}

/*
 In the xml file for the news feature, each article is an "item" element. Items have child elements that provide the title, description, publication date, etc. The NewsXMLParser class creates a News entity for each item in the xml file and assigns the appropriate child elements of the item to the attributes of the News entity. Once a News entity has been created and all attribute assigned values, the News entity is added to xmlArray. So, when the parsing is done, xmlArray contains all the items found in the xml file.
 */

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // Channel is the parent element of all items
    if ([elementName isEqualToString:@"channel"])
    {
        xmlArray = [[NSMutableArray alloc]init];
    }
    
    // Create News entity when item element is found
    else if ([elementName isEqualToString:@"item"])
    {
        NSLog(@"Item found");
        NSEntityDescription *newsEntityDesc = [NSEntityDescription entityForName:@"News" inManagedObjectContext:managedObjectContext];
        theNews = [[News alloc]initWithEntity:newsEntityDesc insertIntoManagedObjectContext:managedObjectContext];
    }
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    // Gets characters found between opening and closing tags of element
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
    } else if ([elementName isEqualToString:@"pubDate"]) {
        theNews.newsDate = [currentElementValue substringToIndex:16];
    } else if ([elementName isEqualToString:@"description"]) {
        theNews.newsSummary = currentElementValue;
        
        // Want to cut-off description at the end of a word after about 120 characters
        /* This is done while the file is being parsed rather than when the rows are being created because the function that creates the rows is called continuously as the table view is scrolled. We don't want to continuously edit the description and append "..." */
        
        if ([theNews.newsSummary length] > 120) {
            BOOL foundSpace = FALSE;
            int endPoint = 120;
            
            while ((!foundSpace) && (endPoint < [theNews.newsSummary length])) {
                
                NSString *lastChar = [theNews.newsSummary substringWithRange:NSMakeRange(endPoint, 1)];
                if ([lastChar isEqualToString:@" "]) {
                    foundSpace = TRUE;
                } else {
                    endPoint++;
                }
            }
            
            theNews.newsSummary = [theNews.newsSummary substringToIndex:MIN(endPoint, [theNews.newsSummary length])];
        }
        
        theNews.newsSummary = [theNews.newsSummary stringByAppendingString:@"..."];
        
    } else if ([elementName isEqualToString:@"link"]) {
        theNews.newsLink = currentElementValue;
    } else if ([elementName isEqualToString:@"content:encoded"]) {
        theNews.newsStory = @"Story";
    }

    
    if ([elementName isEqualToString:@"item"]) {
        [xmlArray addObject:theNews];
        theNews = nil;
    }
    
    currentElementValue = nil;
    
}

@end
