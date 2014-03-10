//
//  CalendarXMLParser.h
//  connect
//
//  Created by NickPiatt on 3/5/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarXMLParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentElementValue;
    NSString *element;
    
    NSDictionary *item;
    NSMutableString *title;
    NSMutableString *subTitle;
    
}

@property (nonatomic, strong) NSMutableArray *eventsArray;

-(id)initParser;

@end
