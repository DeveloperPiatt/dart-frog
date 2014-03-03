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

#import "FoodCell.h"

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
    
    //Loads url request
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(connection) {
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
    NSArray *allRestaurants = [cData getArrayOfManagedObjectsForEntity:@"Restaurant" withSortDescriptor:@""];
    return [allRestaurants count];
}
    
- (FoodCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FoodCell";
    FoodCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
    // Configure the cell
        
    NSArray *matchingData = [cData getArrayOfManagedObjectsForEntity:@"Restaurant" withSortDescriptor:@"restaurantName"];
    
    if(indexPath.row < matchingData.count) {
        
        Restaurant *foodObj = [matchingData objectAtIndex:indexPath.row];
        cell.nameLabel.text = foodObj.restaurantName;
        cell.locationLabel.text = foodObj.location.locationName;
        
        NSSet *hourSet = foodObj.hours;
        
        /*
         Important to note that foodObj.hours is a NSSet of dictionaries. We are putting the dictionaries into a 
         mutable array so that we can sort them by the start times.
         */
        NSMutableArray *hourArray = [[NSMutableArray alloc]initWithArray:[hourSet allObjects]];
        NSSortDescriptor *arraySort = [[NSSortDescriptor alloc]initWithKey:@"hourStart" ascending:true];
        NSArray *sortedArray = [hourArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:arraySort]];
        
        NSMutableString *hourString = [NSMutableString stringWithFormat:@""];
        for (int x = 0; x < [hourArray count]; x++) {
            // Need to lead each new date after the first with ', ' so that it is displayed correctly
            if (x > 0) {
                [hourString appendString:@", "];
            }
            Hour *hourObj = [sortedArray objectAtIndex:x];
            NSString *dateString = [self convertDatesToStringWithStart:hourObj.hourStart andEnd:hourObj.hourEnd];
            [hourString appendString:dateString];
        }
        cell.hoursLabel.text = hourString;
        
    } else {
        // This should never actually go off and could realistically be removed
        cell.nameLabel.text = @"NoData";
        cell.locationLabel.text = @"NoData";
        cell.hoursLabel.text = @"NoData";
    }
    
    return cell;
}

// Sent when the connection has received sufficient data to construct the URL response
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Resets webData on valid response
    [webData setLength:0];
}


// Sets the recieved data to webData for use later. We are currently expecting it to receive JSON
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
    /*
     The hours need to get cleared because the restaurant may or may not be open that day
     or the hours could have changed. In such a case, since these hours are simply reflecting
     todays hours, we should clear them each time and only display restaurants from our list
     with open/close times.
     
     The question is, how do we know to remove a restaurant from core data if it has been closed
     down or renamed? All we really know is if a place is open today or not.
     */
    [cData removeManagedObjectsForEntity:@"Restaurant"];
    [cData removeManagedObjectsForEntity:@"Hour"];
    [self createManagedObjectsForFoodEntityUsingWebData:webData];
    [[self tableView] reloadData];
//    [cData saveManagedObjectContext];
    
}

-(void)createManagedObjectsForFoodEntityUsingWebData:(NSData*)wData
{
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
    
//    NSMutableDictionary *uniqueRestaurantDict = [[NSMutableDictionary alloc]init];
    
    // Iterating through all the restaurants in allDataArray.
    for (NSDictionary *aRestaurant in allDataArray) {
        
        NSString *rName = [aRestaurant objectForKey:@"concept_title"];
        NSString *rLocation = [aRestaurant objectForKey:@"zone"];
        
        // Create the new hour set
        Hour *newHour = [self getHourForRestaurant:aRestaurant];
        
        // Pointer for restaurant
        Restaurant *restaurantObj;
        
        // Check and see if restaurant name is already in core data with restaurant location
        
        NSEntityDescription *restaurantEntityDesc = [NSEntityDescription entityForName:@"Restaurant" inManagedObjectContext:managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:restaurantEntityDesc];
        
        NSSortDescriptor *sortDescriptorIndex = [[NSSortDescriptor alloc]initWithKey:@"restaurantName" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc]initWithObjects: sortDescriptorIndex, nil];
        fetchRequest.sortDescriptors = sortDescriptors;
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"restaurantName = %@", rName];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"location.locationName = %@", rLocation];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        // If so, add a new set of hours to the hours set
        
        if ([matchingData count] > 0) {
            restaurantObj = [matchingData objectAtIndex:0];
            
        } else {
            NSEntityDescription *restaurantEntityDesc = [NSEntityDescription entityForName:@"Restaurant" inManagedObjectContext:managedObjectContext];
            restaurantObj = [[Restaurant alloc]initWithEntity:restaurantEntityDesc insertIntoManagedObjectContext:managedObjectContext];
            restaurantObj.restaurantName = rName;
            
        }
        
        NSMutableSet *hourSet = [NSMutableSet setWithSet:restaurantObj.hours];
        [hourSet addObject:newHour];
        
        restaurantObj.hours = hourSet;
        
        // Check and see if location already exists in core data
        // If so get a pointer to that location
        // If not create the location
        // Set that location as the restaurant location
        
        if ([matchingData count] < 1) {
            // Restaurant is new, need to get a location for it
            Location *locationObj = [self getLocation:rLocation];
            if (locationObj == nil) {
                NSEntityDescription *locationEntityDesc = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
                locationObj = [[Location alloc]initWithEntity:locationEntityDesc insertIntoManagedObjectContext:managedObjectContext];
                
                locationObj.locationName = [aRestaurant objectForKey:@"zone"];
            }
            restaurantObj.location = locationObj;
        }
        
        [cData saveManagedObjectContext];
    }
}

-(NSString *)convertDatesToStringWithStart:(NSDate*)startDate andEnd:(NSDate*)endDate
{
    NSString *dateString;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"];
    
    // Start Time
    NSString *startDateString = [outputFormatter stringFromDate:startDate];
    
    // End Time
    NSString *endDateString = [outputFormatter stringFromDate:endDate];
    
    dateString = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
    
    return dateString;
}

-(Hour *)getHourForRestaurant:(NSDictionary*)restaurantData
{
    /*
     This function merely puts together our Hour managed object using the restaurant
     data pulled from the web. It returns an Hour object with a start/end time set.
     */
    NSEntityDescription *hourEntityDesc = [NSEntityDescription entityForName:@"Hour" inManagedObjectContext:managedObjectContext];
    Hour *newHour = [[Hour alloc]initWithEntity:hourEntityDesc insertIntoManagedObjectContext:managedObjectContext];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"hh:mm a"];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"'Hours:' hh:mm a"];
    
    /*
     As long as the start/end times are not coming back as null, convert them to a
     date and store them. If they are coming back as null, store them as nil in
     core data
     */
    
    if (![[restaurantData objectForKey:@"start"] isEqual:[NSNull null]]) {
        NSDate *formatterDate = [inputFormatter dateFromString:[restaurantData objectForKey:@"start"]];
        newHour.hourStart = formatterDate;
    } else {
        newHour.hourStart = nil;
    }
    
    if (![[restaurantData objectForKey:@"end"] isEqual:[NSNull null]]) {
        NSDate *formatterDate = [inputFormatter dateFromString:[restaurantData objectForKey:@"end"]];
        newHour.hourEnd = formatterDate;
    } else {
        newHour.hourEnd = nil;
    }
    return newHour;
}

-(Location *)getLocation:(NSString*)locationName
{
    // Setting up the managed objects we will be working with
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDescription];
    
    // Perform fetch request on entity that fits the description
    // Predicates used to select entities based on certain criteria
    NSSortDescriptor *sortDescriptorIndex = [[NSSortDescriptor alloc]initWithKey:@"locationName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects: sortDescriptorIndex, nil];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationName = %@", locationName];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([matchingData count] > 0) {
        return [matchingData objectAtIndex:0];
    } else {
        return nil;
    }
    
}

@end
