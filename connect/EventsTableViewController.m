//
//  EventsTableViewController.m
//  connect
//
//  Created by NickPiatt on 3/5/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "EventsTableViewController.h"
#include "CalendarXMLParser.h"
#include "EventStandardCell.h"

@interface EventsTableViewController () {
    NSArray *eventDataArray;
    CalendarXMLParser *parser;
}

@end

@implementation EventsTableViewController

@synthesize calendarData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Displaying Data For -- %@", [calendarData objectForKey:@"Title"]);
    
    eventDataArray = [self getEventData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

-(NSArray*)getEventData {
    /*
     today
     week
     month
     
     http://calendar.oregonstate.edu/today/' + myScope + '/' + myCalName + '/rss20.xml
     */
    
    NSURL *url = [[NSURL alloc]initWithString:@"http://calendar.oregonstate.edu/today/month/osu-conferences/rss20.xml"];
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:data];
    
    parser = [[CalendarXMLParser alloc]initParser];
    [xmlParser setDelegate:parser];
    
    BOOL parseWorked = [xmlParser parse];
    
    if (parseWorked) {
        NSLog(@"%@", parser.eventsArray);
    } else {
        NSLog(@"Parse Failed");
    }
    
    return parser.eventsArray;
}

@end
