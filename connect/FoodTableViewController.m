//
//  FoodViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "FoodTableViewController.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"

#import "Restaurant.h"
#import "Hour.h"
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
    //Creates and returns managed object of AppDelegate class
    AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
    managedObjectContext = [appdelegate managedObjectContext];
    
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
    [self createManagedObjectsForFoodEntityUsingWebData:webData];
    
}

-(void)createManagedObjectsForFoodEntityUsingWebData:(NSData*)wData {
    //Create foundation object for JSON data and stores values in array
    NSArray *allDataArray = [NSJSONSerialization JSONObjectWithData:wData options:0 error:nil];
    
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
    
    // Iterating through all the restaurants in allDataArray.
    for (NSDictionary *aRestaurant in allDataArray) {
        
        // Checking each restaurant entry to see if it's unique or not.
        if ([uniqueRestaurantDict objectForKey:[aRestaurant objectForKey:@"concept_title"]] == NULL) {
            
            // Setting up the managed objects we will be working with
            NSEntityDescription *restaurantEntityDesc = [NSEntityDescription entityForName:@"Restaurant" inManagedObjectContext:managedObjectContext];
            Restaurant *newRestaurant = [[Restaurant alloc]initWithEntity:restaurantEntityDesc insertIntoManagedObjectContext:managedObjectContext];
            
            NSEntityDescription *hourEntityDesc = [NSEntityDescription entityForName:@"Hour" inManagedObjectContext:managedObjectContext];
            Hour *newHour = [[Hour alloc]initWithEntity:hourEntityDesc insertIntoManagedObjectContext:managedObjectContext];
            
            NSEntityDescription *locationEntityDesc = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
            Location *newLocation = [[Location alloc]initWithEntity:locationEntityDesc insertIntoManagedObjectContext:managedObjectContext];
            
            newLocation.locationName = [aRestaurant objectForKey:@"zone"];
            
            newRestaurant.restaurantName = [aRestaurant objectForKey:@"concept_title"];
            
            if (![[aRestaurant objectForKey:@"start"] isEqual:[NSNull null]]) {
                newHour.hourStart = [aRestaurant objectForKey:@"start"];
            } else {
                newHour.hourStart = @"Not Listed";
            }
            if (![[aRestaurant objectForKey:@"end"] isEqual:[NSNull null]]) {
                newHour.hourEnd = [aRestaurant objectForKey:@"end"];
            } else {
                newHour.hourEnd = @"Not Listed";
            }
            
            newHour.restaurant = newRestaurant;
            
            // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
            // End of core data
            // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
            
            NSLog(@"add me -- %@", [aRestaurant objectForKey:@"concept_title"]);
            
            /*
             New entry. Need to create an array for holding onto sets of start/end times. Store those
             values in dictionaries which will be added to the array. Then store that array.
             */
            
            NSMutableArray *hoursArray = [[NSMutableArray alloc]init];
            
            // Setting up an object to hold a start and end time for this current entry
            NSMutableDictionary *hoursDict = [[NSMutableDictionary alloc]init];
            [hoursDict setObject:[aRestaurant objectForKey:@"start"] forKey:@"start"];
            [hoursDict setObject:[aRestaurant objectForKey:@"end"] forKey:@"end"];
            
            /* 
             Adding the hours object to the array that will store all of said entries
             As we iterate through allDataArray a restaurant may come up more than once
             if it closes and re-opens later in the day. By the end of our iteration
             through allDataArray this array could have 1-x sets of start/end times
             */
            [hoursArray addObject:hoursDict];
            
            // Setting up a dictionary for holding restaurantData
            NSMutableDictionary *restaurantData = [[NSMutableDictionary alloc]init];
            
            // Setting the hours array so that we can access it later
            [restaurantData setObject:hoursArray forKey:@"hours"];
            
            /*
             Setting the 'zone', or the location, of the restaurant. We only need to
             do this once when we first set up this restaurant data object.
             */
             [restaurantData setObject:[aRestaurant objectForKey:@"zone"] forKey:@"location"];
            
            /* 
             And finally we add the restaurant data to a dictionary and key it with
             the restaurant name
             */
             [uniqueRestaurantDict setObject:restaurantData forKey:[aRestaurant objectForKey:@"concept_title"]];
            
           
            
            
        } else {
            
            // Setting up the managed objects we will be working with
            NSEntityDescription *restaurantEntityDesc = [NSEntityDescription entityForName:@"Restaurant" inManagedObjectContext:managedObjectContext];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            [fetchRequest setEntity:restaurantEntityDesc];
            
            
            //Perform fetch request on entity that fits the description
            //Predicates used to select entities based on certain criteria
            NSSortDescriptor *sortDescriptorIndex = [[NSSortDescriptor alloc]initWithKey:@"restaurantName" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc]initWithObjects: sortDescriptorIndex, nil];
                
            fetchRequest.sortDescriptors = sortDescriptors;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"restaurantName = %@", [aRestaurant objectForKey:@"concept_title"]];
            
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            Restaurant *repeatedRestaurant = [matchingData objectAtIndex:0];

            NSEntityDescription *hourEntityDesc = [NSEntityDescription entityForName:@"Hour" inManagedObjectContext:managedObjectContext];
            Hour *newHour = [[Hour alloc]initWithEntity:hourEntityDesc insertIntoManagedObjectContext:managedObjectContext];
            
            if (![[aRestaurant objectForKey:@"start"] isEqual:[NSNull null]]) {
                newHour.hourStart = [aRestaurant objectForKey:@"start"];
            } else {
                newHour.hourStart = @"Not Listed";
            }
            if (![[aRestaurant objectForKey:@"end"] isEqual:[NSNull null]]) {
                newHour.hourEnd = [aRestaurant objectForKey:@"end"];
            } else {
                newHour.hourEnd = @"Not Listed";
            }
            
            newHour.restaurant = repeatedRestaurant;
            // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
            // End of core data
            // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
            
            NSLog(@"duplicate -- %@", [aRestaurant objectForKey:@"concept_title"]);
            
            /*
             Already have an entry for this location. Instead we need to snag the restaurant data (rdata),
             pull the hours array and add a new set of hours data.
             */
            
            // Setting a pointer to the restaurant data that we know should already exist
            NSMutableDictionary *rData = [uniqueRestaurantDict objectForKey:[aRestaurant objectForKey:@"concept_title"]];
            
            // And another pointer to the hours array that we know should exist in the restaurant data
            NSMutableArray *hoursArray = [rData objectForKey:@"hours"];
            
            // creating new set of hours data
            NSMutableDictionary *hoursDict = [[NSMutableDictionary alloc]init];
            [hoursDict setObject:[aRestaurant objectForKey:@"start"] forKey:@"start"];
            [hoursDict setObject:[aRestaurant objectForKey:@"end"] forKey:@"end"];
            
            // and adding it to the hours array
            [hoursArray addObject:hoursDict];
            
            
            
        }
    }
    
    // Just checking to see how the data looks ... and it looks good!
    NSLog(@"%@", uniqueRestaurantDict);
    
}

@end
