//
//  CalendarXMLParser.m
//  connect
//
//  Created by NickPiatt on 3/5/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "CalendarXMLParser.h"
#import "AppDelegate.h"
#import "Event.h"

#warning TODO
// TODO: Set locations for events in core data
// TODO: Add location to the list of things we check to see if event is a duplicate or not

@interface CalendarXMLParser () {
    NSManagedObjectContext *managedObjectContext;
}

@end

@implementation CalendarXMLParser

@synthesize eventsArray;

-(id)initParser {
    if (self == [super init]) {
        eventsArray = [[NSMutableArray alloc]init];
        
        AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
        managedObjectContext = [appdelegate managedObjectContext];
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
        
        
        [self createManagedObjectsWithData:item];
        
        
        [eventsArray addObject:item];
    }
}

-(void)createManagedObjectsWithData:(NSDictionary*)itemData {
    
    NSDictionary *hoursDict = [itemData objectForKey:@"hours"];
    
    NSString *eventDate = [hoursDict objectForKey:@"start"];
    NSString *eventName = [itemData objectForKey:@"title"];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc]init];
    
    NSRange pdtRange = [eventDate rangeOfString:@"PDT"];
    if (pdtRange.location == NSNotFound) {
        [inputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'PST'"];
    } else {
        [inputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'PDT'"];
    }
    
    NSDate *formattedDate = [inputFormatter dateFromString:eventDate];
    
    if (![self eventExistsWithName:eventName AndDate:formattedDate]) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
        
        Event *newEvent = [[Event alloc]initWithEntity:entityDesc insertIntoManagedObjectContext:managedObjectContext];
        
        newEvent.eventName = [itemData objectForKey:@"title"];
        newEvent.eventRoom = [itemData objectForKey:@"subtitle"];
        newEvent.eventDetails = [itemData objectForKey:@"description"];
        
        
        
        newEvent.eventDate = formattedDate;
        newEvent.eventTime = [NSString stringWithFormat:@"%@-%@", [hoursDict objectForKey:@"timeStart"], [hoursDict objectForKey:@"timeEnd"]];
        
        [self saveManagedObjectContext];
    } else {
        NSLog(@"events already exist");
    }
    
    
    
}

-(BOOL)eventExistsWithName:(NSString*)eventName AndDate:(NSDate*)eventDate
{
    //Create object that describes entity, name must match core data entity name, pass managedObjectContext
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    //Perform fetch request on entity that fits the description
    //Predicates used to select entities based on certain criteria
    NSSortDescriptor *sortDescriptorIndex = [[NSSortDescriptor alloc]initWithKey:@"eventName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects: sortDescriptorIndex, nil];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"eventName = %@", eventName];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"eventDate = %@", eventDate];
    
    NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    [fetchRequest setPredicate:predicates];
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returns true if event with same name and date already exists in core data
    // As far as I know, this should be enough data to make this check accurately
    if ([matchingData count] > 0) {
        return true;
    }
    
    return false;
}



-(void)saveManagedObjectContext
{
    NSError *error;
    if(![managedObjectContext save:&error]) {
        NSLog(@"SaveFailed: %@", [error localizedDescription]);
    }
    else {
        NSLog(@"SaveSucceeded");
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
