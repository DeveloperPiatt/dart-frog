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
        eventTitle = [[NSMutableString alloc]init];
        eventSubTitle = [[NSMutableString alloc]init];
        eventLocation = [[NSMutableString alloc]init];
        eventHoursDict = [[NSMutableDictionary alloc]init];
        eventDescription = [[NSMutableString alloc]init];
        eventLocationRoom = [[NSMutableString alloc]init];
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
        [eventTitle appendString:currentElementValue];
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:subtitle"]) {
        // do something
        if (currentElementValue != nil) {
            [eventSubTitle appendString:currentElementValue];
        }
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:Location"]) {
        if (currentElementValue != nil) {
            [eventLocation appendString:currentElementValue];
        }
    }
    if ([elementName isEqualToString:@"description"]) {
        if (currentElementValue != nil) {
            [eventDescription appendString:currentElementValue];
        }
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:room"]) {
        if (currentElementValue != nil) {
            [eventLocationRoom appendString:currentElementValue];
        }
    }
    
    // Time
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:dtstart"]) {
        [eventHoursDict setObject:[NSString stringWithString:currentElementValue] forKey:@"start"];
    }
    if ([elementName isEqualToString:@"edu.oregonstate.calendar:dtend"]) {
        [eventHoursDict setObject:[NSString stringWithString:currentElementValue] forKey:@"end"];
    }
    
    if ([elementName isEqualToString:@"item"]) {
        [item setValue:eventTitle forKey:@"title"];
        [item setValue:eventSubTitle forKey:@"subtitle"];
        [item setValue:eventLocation forKey:@"location"];
        [item setValue:eventLocationRoom forKey:@"room"];
        
        [self addValuesToHoursDict];
        [item setValue:eventHoursDict forKey:@"hours"];
        
        [item setValue:eventDescription forKey:@"description"];
//        NSLog(@"New Item End");
        [eventsArray addObject:item];
    }
}

-(void) addValuesToHoursDict {
    // Function takes the current start/end values and adds a few extra values to the dictionary
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc]init];
    NSString *dateString = [NSString stringWithFormat:@"%@", [eventHoursDict objectForKey:@"start"]];
    
    /*
     Sometimes the RSS feed returns times in PST as well as PDT. Since we need to be able to set the format
     we look at the date string and see if PDT can be found.
     */
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
    [timeFormatter setDateFormat:@"hh:mm a"];
    
    NSDate *formattedDate = [inputFormatter dateFromString:[eventHoursDict objectForKey:@"start"]];
    
    // Day Number
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [dayNumFormatter stringFromDate:formattedDate]] forKey:@"dayNum"];
    // Day of week
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [dayOfWeekFormatter stringFromDate:formattedDate]] forKey:@"dayOfWeek"];
    
    [dayOfWeekFormatter setDateFormat:@"EEE"];
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [dayOfWeekFormatter stringFromDate:formattedDate]] forKey:@"dayOfWeekShort"];
    
    // Month
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [monthFormatter stringFromDate:formattedDate]] forKey:@"month"];
    // Year
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [yearFormatter stringFromDate:formattedDate]] forKey:@"year"];
    // Time
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:formattedDate]] forKey:@"timeStart"];
    
    
    formattedDate = [inputFormatter dateFromString:[eventHoursDict objectForKey:@"end"]];
    
    [eventHoursDict setObject:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:formattedDate]] forKey:@"timeEnd"];
    
}

@end
