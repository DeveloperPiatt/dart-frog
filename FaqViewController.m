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
    NSMutableArray *array;
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
    
    array = [[NSMutableArray alloc]init];
    
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
    
   //Use helper function here?
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
}


#pragma mark - Connection

//Sent when the connection has received sufficient data to construct the URL response
-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
    [webData setLength:0];
}


//Stores data in array as connection loads data
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
    
    //Create foundation object for JSON data and stores values in array
    NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    NSArray *allNodes = [allDataDictionary objectForKey:@"nodes"];
    
    NSArray *matchingData = [self getArrayOfManagedObjectsForEntity:@"FAQ"];
    
    //
    for (NSManagedObject *toDelete in matchingData) {
        [managedObjectContext deleteObject:toDelete];
    }
    
    
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
    
    NSError *error;
    if(![managedObjectContext save:&error]) {
        NSLog(@"Save Failed: %@", [error localizedDescription]);
    }
    else {
        NSLog(@"Save Succeeded");
    }
    
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
    static NSString *CellIdentifier = @"FAQCell";
    FAQCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    NSArray *matchingData = [self getArrayOfManagedObjectsForEntity:@"FAQ"];
    
    if (indexPath.row < matchingData.count ) {
        FAQ *faqObj = [matchingData objectAtIndex:indexPath.row];
        
        cell.questionLabel.text = faqObj.faqQuestion;
        cell.answerLabel.text = faqObj.faqAnswer;
    }
    else {
        cell.textLabel.text = @"No Data";
        cell.detailTextLabel.text = @"No Data";
    }
    
    
    return cell;
}


/*
//Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
//Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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

@end
