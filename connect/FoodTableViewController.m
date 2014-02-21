//
//  FoodViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "FoodTableViewController.h"
#import "CoreDataHelper.h"

#import "Restaurant.h"
#import "Location.h"

@interface FoodTableViewController () {
    NSManagedObjectContext *managedObjectContext;
    NSMutableData *webData;
    NSURLConnection *connection;
    
    CoreDataHelper *cData;
}

@end

@implementation FoodTableViewController

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
    
    cData = [[CoreDataHelper alloc]init];
    
    //Idicates activity while table view loads data
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Initilizes NSURL object and and creates request
    NSURL *url = [NSURL URLWithString:@"https://uhds.oregonstate.edu/api/dining/calendar/index"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //Loads url request and sends messages to delegate as the load progresses
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(connection)
    {
        webData = [[NSMutableData alloc]init];
    }
    

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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

//Sent when the connection has received sufficient data to construct the URL response
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //Resets webData on valid response
    [webData setLength:0];
}


//Sets the recieved data to webData for use later. We are currently expecting it to receive JSON
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    NSLog(@"SetData");
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"FailWithError");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"ConnectionFinishedLoading");
    [self createManagedObjectsForFoodEntity];
    
}

-(void)createManagedObjectsForFoodEntity {
    //Create foundation object for JSON data and stores values in array
    NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    
    /*
     There is a slight issue we need to deal with concerning the data coming in
     here, basically if a restaurant closes and reopens, we end up with multiple results.
     
     Cooper's Creek BBQ
     7:00 AM - 1:00 PM
     
     Cooper's Creek BBQ
     5:00 PM - 7:30 PM
     
     While we can store these separately in the DB, I'm not sure we want to have multiple entries
     in our table. What we should be displaying is
     
     Cooper's Creek BBQ
     7:00 AM - 1:00 PM, 5:00 PM - 7:30 PM
     
     Or something of that sort.
     
     =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     After speaking with José we decided to make a change to the core data structure. We've removed
     start and end times from the restaurant entity and instead created a hour entity that has a
     relationship with the resaurant entity. This way we can created multiple start/end times for a
     particular restaurant.
     */
    
    NSMutableDictionary *uniqueRestaurantDict = [[NSMutableDictionary alloc]init];
    
    for (NSDictionary *aRestaurant in allDataArray) {
        
        if ([uniqueRestaurantDict objectForKey:[aRestaurant objectForKey:@"concept_title"]] == NULL) {
            NSLog(@"add me -- %@", [aRestaurant objectForKey:@"concept_title"]);
            
            /*
             New entry. Need to create an array for holding onto sets of start/end times. Store those
             values in dictionaries which will be added to the array. Then store that array.
             */
            
            NSMutableArray *hoursArray = [[NSMutableArray alloc]init];
            
            NSMutableDictionary *hoursDict = [[NSMutableDictionary alloc]init];
            [hoursDict setObject:[aRestaurant objectForKey:@"start"] forKey:@"start"];
            [hoursDict setObject:[aRestaurant objectForKey:@"end"] forKey:@"end"];
            
            [hoursArray addObject:hoursDict];
            
            NSMutableDictionary *restaurantData = [[NSMutableDictionary alloc]init];
            [restaurantData setObject:hoursArray forKey:@"hours"];
            [restaurantData setObject:[aRestaurant objectForKey:@"zone"] forKey:@"location"];
            
            
            [uniqueRestaurantDict setObject:restaurantData forKey:[aRestaurant objectForKey:@"concept_title"]];
        } else {
            NSLog(@"dont add me -- %@", [aRestaurant objectForKey:@"concept_title"]);
            
            /*
             Already have an entry for this location. Instead we need to snag the restaurant data (rdata),
             pull the hours array and add a new set of hours data.
             */
            
            NSMutableDictionary *rData = [uniqueRestaurantDict objectForKey:[aRestaurant objectForKey:@"concept_title"]];
            NSMutableArray *hoursArray = [rData objectForKey:@"hours"];
            
            // creating new set of hours data
            NSMutableDictionary *hoursDict = [[NSMutableDictionary alloc]init];
            [hoursDict setObject:[aRestaurant objectForKey:@"start"] forKey:@"start"];
            [hoursDict setObject:[aRestaurant objectForKey:@"end"] forKey:@"end"];
            
            // adding hours data to the array
            [hoursArray addObject:hoursDict];
            
        }
    }
    
    NSLog(@"%@", uniqueRestaurantDict);
}

@end
