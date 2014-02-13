/*
//  FaqViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/3/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
*/

#import "FaqViewController.h"
#import "AppDelegate.h"
#import "FAQCell.h"

@interface FaqViewController ()
{
    NSManagedObjectContext *managedObjectContext;
    NSMutableData *webData;
    NSURLConnection *connection;
}

@end

@implementation FaqViewController

@synthesize selectedFAQ; //Creates getter and setter for selectedFAQ


#pragma mark - Initilize

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
    
    //Idicates activity while table view loads data
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Initilizes NSURL object and and creates request
    NSURL *url = [NSURL URLWithString:@"http://connect.oregonstate.edu/faq/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //Loads url request and sends messages to delegate as the load progresses
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(connection)
    {
        webData = [[NSMutableData alloc]init];
    }
    
    //Creates and returns managed object of AppDelegate class
    AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
    managedObjectContext = [appdelegate managedObjectContext];
}


- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
}


#pragma mark - Connection

//Sent when the connection has received sufficient data to construct the URL response

/*
 Resets webData on a valid response
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
    [webData setLength:0];
}


//Stores data in array as connection loads data
/*
 Sets the recieved data to webData for use later. We are currently expecting it to receive JSON
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    NSLog(@"set data");
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Fail with error");
}


#pragma mark - JSON transformation

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"ConnectionFinishedLoading");
    [self removeManagedObjectsForFaqEntity];
    [self createManagedObjectsForFaqEntity];
    [self saveManagedObjectContext];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *matchingData = [self getArrayOfManagedObjectsForEntity:@"FAQ"];
    
    //Return the number of rows
    return [matchingData count];
    
}


- (FAQCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FAQCell";
    FAQCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    // Configure the cell
    
    NSArray *matchingData = [self getArrayOfManagedObjectsForEntity:@"FAQ"];
    
    if (indexPath.row < matchingData.count ) {
        FAQ *faqObj = [matchingData objectAtIndex:indexPath.row];
        
        cell.questionLabel.text = faqObj.faqQuestion;
        cell.answerLabel.text = faqObj.faqAnswer;
    }
    else {
        cell.questionLabel.text = @"No Data";
        cell.answerLabel.text = @"No Data";
    }
    
    
    return cell;
}

#pragma mark - Helper Functions

-(NSArray*)getArrayOfManagedObjectsForEntity:(NSString*)entity {
    
    //Create object that describes entity, name must match core data entity name, pass managedObjectContext
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    //Perform fetch request on entity that fits the description
    //Predicates used to select entities based on certain criteria
    NSSortDescriptor *sortDescriptorIndex = [[NSSortDescriptor alloc]initWithKey:@"faqIndex" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects: sortDescriptorIndex, nil];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return matchingData;
}


/*
 Removes all managed objects for FAQ Entity. This is used when we are pulling new data from the web.
 */
-(void)removeManagedObjectsForFaqEntity {
    NSArray *allManagedObjects = [self getArrayOfManagedObjectsForEntity:@"FAQ"];
    
    for (NSManagedObject *toDelete in allManagedObjects) {
        [managedObjectContext deleteObject:toDelete];
    }
}

-(void)saveManagedObjectContext {
    NSError *error;
    if(![managedObjectContext save:&error]) {
        NSLog(@"Save Failed: %@", [error localizedDescription]);
    }
    else {
        NSLog(@"Save Succeeded");
    }
}

-(void)createManagedObjectsForFaqEntity {
    //Create foundation object for JSON data and stores values in array
    NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    NSArray *allNodes = [allDataDictionary objectForKey:@"nodes"];
    
    int indexCount = 0;
    for (NSDictionary *nodeIndex in allNodes) {
        
        //Create and assign values to entities
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
        NSManagedObject *newFAQ = [[NSManagedObject alloc]initWithEntity:entityDesc insertIntoManagedObjectContext:managedObjectContext];
        
        [newFAQ setValue:[[nodeIndex objectForKey:@"node"] objectForKey:@"question"] forKey:@"faqQuestion"];
        [newFAQ setValue:[[nodeIndex objectForKey:@"node"] objectForKey:@"answer"] forKey:@"faqAnswer"];
        [newFAQ setValue:[NSNumber numberWithInt:indexCount] forKey:@"faqIndex"];
        
        indexCount++;
    }
}

@end
