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
    NSLog(@"Table Row Style -- %@", [[calendarData objectForKey:@"Data"] objectForKey:@"Type"]);
    
    [self setTableViewRowHeight];
    
    eventDataArray = [self getEventData];
    [[self tableView] reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setTableViewRowHeight {
    /*
     If the calendar data type is standard, row height needs to be 152
     If the calendar data type is symposium, row height needs to be 110
     */
    
    NSString *dataType = [[calendarData objectForKey:@"Data"] objectForKey:@"Type"];
    
    /*
     In the future it would be nice if we could pull this from the actual cell and not
     hard code it
     */
    
    if ([dataType isEqualToString:@"standard"]) {
        self.tableView.rowHeight = 152;
    } else if ([dataType isEqualToString:@"symposium"]) {
        self.tableView.rowHeight = 110;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [eventDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EventStandardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *cellData = [parser.eventsArray objectAtIndex:indexPath.row];
    NSDictionary *hoursData = [cellData objectForKey:@"hours"];
    
    [cell.titleLabel setText:[cellData objectForKey:@"title"]];
    [cell.subtitleLabel setText:[cellData objectForKey:@"subtitle"]];
    [cell.locationLabel setText:[cellData objectForKey:@"location"]];
    
    [cell.monthLabel setText:[hoursData objectForKey:@"month"]];
    [cell.dayNumLabel setText:[hoursData objectForKey:@"dayNum"]];
    [cell.dayOfWeekLabel setText:[hoursData objectForKey:@"dayOfWeek"]];
    
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
        NSLog(@"Parse Worked!");
//        NSLog(@"%@", parser.eventsArray);
    } else {
        NSLog(@"Parse Failed");
    }
    
    return parser.eventsArray;
}

@end
