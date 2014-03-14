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
//        NSLog(@"New Item Start");
        item = [[NSMutableDictionary alloc]init];
        title = [[NSMutableString alloc]init];
        subTitle = [[NSMutableString alloc]init];
        location = [[NSMutableString alloc]init];
        hoursDict = [[NSMutableDictionary alloc]init];
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
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:Location"]) {
        if (currentElementValue != nil) {
            [location appendString:currentElementValue];
        }
    }
    
    // Time
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:dtstart"]) {
        [hoursDict setObject:[NSString stringWithString:currentElementValue] forKey:@"start"];
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:dtend"]) {
        [hoursDict setObject:[NSString stringWithString:currentElementValue] forKey:@"end"];
    }
    
    if ([elementName isEqualToString:@"item"]) {
        [item setValue:title forKey:@"title"];
        [item setValue:subTitle forKey:@"subtitle"];
        [item setValue:location forKey:@"location"];
        
        [self addValuesToHoursDict];
        [item setValue:hoursDict forKey:@"hours"];
//        NSLog(@"New Item End");
        NSLog(@"%@", hoursDict);
        [eventsArray addObject:item];
    }
}

-(void) addValuesToHoursDict {
    // Function takes the current start/end values and adds a few extra values to the dictionary
    // Thu, 27 Mar 2014 17:00:00 PDT
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc]init];
    
    NSString *dateString = [NSString stringWithFormat:@"%@", [hoursDict objectForKey:@"start"]];
    
    NSRange pdtRange = [dateString rangeOfString:@"PDT"];
    
    if (pdtRange.location == NSNotFound) {
        [inputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'PST'"];
    } else {
        [inputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'PDT'"];
    }
    
    NSDateFormatter *dayNumFormatter = [[NSDateFormatter alloc]init];
    [dayNumFormatter setDateFormat:@"dd"];
    
    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc]init];
    [dayOfWeekFormatter setDateFormat:@"EEEE"];
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc]init];
    [monthFormatter setDateFormat:@"MMM"];
    
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc]init];
    [yearFormatter setDateFormat:@"yyyy"];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    [timeFormatter setDateFormat:@"hh:mm"];
    
    NSDate *formattedDate = [inputFormatter dateFromString:[hoursDict objectForKey:@"start"]];
    
//    NSLog(@"%@", [hoursDict objectForKey:@"start"]);
    
    // Day Number
    [hoursDict setObject:[NSString stringWithFormat:@"%@", [dayNumFormatter stringFromDate:formattedDate]] forKey:@"dayNum"];
    // Day of week
    [hoursDict setObject:[NSString stringWithFormat:@"%@", [dayOfWeekFormatter stringFromDate:formattedDate]] forKey:@"dayOfWeek"];
    // Month
    [hoursDict setObject:[NSString stringWithFormat:@"%@", [monthFormatter stringFromDate:formattedDate]] forKey:@"month"];
    // Year
    [hoursDict setObject:[NSString stringWithFormat:@"%@", [yearFormatter stringFromDate:formattedDate]] forKey:@"year"];
    // Time
    [hoursDict setObject:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:formattedDate]] forKey:@"time"];
    
}

@end
