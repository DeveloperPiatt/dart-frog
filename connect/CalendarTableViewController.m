//
//  CalendarTableViewController.m
//  connect
//
//  Created by NickPiatt on 3/4/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "CalendarTableViewController.h"
#import "EventsViewController.h"

@interface CalendarTableViewController ()

@end

@implementation CalendarTableViewController {
    NSArray *tableDataArray;
    
}

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
    tableDataArray = [self getCalendarTableData];
    [[self tableView] reloadData];

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    // Configure the cell...
    
    cell.textLabel.text = [[tableDataArray objectAtIndex:indexPath.row] valueForKey:@"Title"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Row selected");
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Putting together the data we want to use from the selected cell and passing it for the segue
    NSDictionary *segueData = @{@"title": cell.textLabel.text, @"indexPath": indexPath};
    [self performSegueWithIdentifier:@"customSegue" sender:segueData];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"Preparing!");
    
    // Override for segue
    EventsViewController *newVC = segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"customSegue"]) {
        newVC.navigationItem.title = [sender objectForKey:@"title"];
        newVC.calendarData = [tableDataArray objectAtIndex:[(NSIndexPath*)[sender objectForKey:@"indexPath"] row]];
    }
}

-(NSArray*)getCalendarTableData
{
    NSMutableArray *CTData = [[NSMutableArray alloc]init]; //CTData -> Calendar Table Data
    
    /*
     Data is being structured as follows ...
     
     CTData is an array of dictionaries. Each dictionary provides basic information about each calendar.
     
     CTData Key/Value schema
     
     Key   ->   Title
     Value ->   String
     
     Key   ->   Data
     Value ->   Dictionary
     
                Key   ->    Calendar Type
                Value ->    String
     
                Key   ->    URL
                Value ->    String
     
     This Schema is an adaptation of how things were set up in the Titanium version of the application
     */
    
    [CTData addObject:@{@"Data" : @{@"Type" : @"standard", @"Url" : @"newstudentprograms"}, @"Title" : @"New Student Programs"}];
    [CTData addObject:@{@"Data" : @{@"Type" : @"symposium", @"Url" : @"symposium"}, @"Title" : @"OSU Scholar Symposium"}];
    
    return  CTData;
}

@end
