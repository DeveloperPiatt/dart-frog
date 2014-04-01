//
//  EventsViewController.m
//  connect
//
//  Created by NickPiatt on 3/24/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#warning TODO tasks
// TODO: If no internet connection we need to gray out the segmented controller and just show events for this month from core data

#import "EventsViewController.h"
#include "CalendarXMLParser.h"
#include "EventStandardCell.h"
#include "EventDescriptionViewController.h"

@interface EventsViewController () {
    NSArray *eventDataArray;
    CalendarXMLParser *parser;
}

@end

@implementation EventsViewController

@synthesize calendarData, eventTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"Displaying Data For -- %@", [calendarData objectForKey:@"Title"]);
    NSLog(@"Table Row Style -- %@", [[calendarData objectForKey:@"Data"] objectForKey:@"Type"]);
    
    [self setTableViewRowHeight];
    
    eventDataArray = [self getEventData];
    [eventTableView reloadData];
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
        eventTableView.rowHeight = 152;
    } else if ([dataType isEqualToString:@"symposium"]) {
        eventTableView.rowHeight = 110;
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
    [cell.timeLabel setText:[hoursData objectForKey:@"timeStart"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventStandardCell *cell = (EventStandardCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    // Putting together the data we want to use from the selected cell and passing it for the segue
    NSDictionary *segueData = @{@"title": cell.titleLabel.text, @"indexPath": indexPath};
    [self performSegueWithIdentifier:@"standardSegue" sender:segueData];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Override for segue
    EventDescriptionViewController *newVC = segue.destinationViewController;
    if([segue.identifier isEqualToString:@"standardSegue"]) {
        
        newVC.navigationItem.title = [sender objectForKey:@"title"];
        newVC.eventDataDictionary = [parser.eventsArray objectAtIndex:[(NSIndexPath*)[sender objectForKey:@"indexPath"] row]];
    }
}

-(NSArray*)getEventData {
#warning this function is deprecated and needs to be fully replaced by getEventDataForRange:
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

-(NSArray*)getEventDataForRange:(NSString*)range {
    
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://calendar.oregonstate.edu/today/%@/osu-conferences/rss20.xml", range]];
    
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

-(IBAction)updateCalendarRange:(UISegmentedControl *)sender {
    /*
     The calendar range is what the user changes when they want to see the events
     for just today, this week or all of this month.
     */
    switch (sender.selectedSegmentIndex) {
        case 0:
            // today selected
            eventDataArray = [self getEventDataForRange:@"day"];
            break;
        case 1:
            // week selected
            eventDataArray = [self getEventDataForRange:@"week"];
            break;
        case 2:
            // month selected
            eventDataArray = [self getEventDataForRange:@"month"];
            break;
        default:
            break;
    }
    
    [eventTableView reloadData];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
