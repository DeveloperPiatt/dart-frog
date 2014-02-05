//
//  FaqViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/3/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "FaqViewController.h"
#import "AppDelegate.h"

@interface FaqViewController ()
{
    NSManagedObjectContext *managedObjectContext; // how data from data object model is handled
    NSMutableData *webData;
    NSURLConnection *connection;
    NSMutableArray *array;
}

@end

@implementation FaqViewController

@synthesize selectedFAQ; // creates getter and setter for selectedFAQ


- (id)initWithStyle:(UITableViewStyle)style // automatically generated
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; // runs when view loads
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[self FaqTableView]setDelegate:self];
    [[self FaqTableView]setDataSource:self];
    array = [[NSMutableArray alloc]init];
    
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate]; // creates instance of AppDelegate class
    managedObjectContext = [appdelegate managedObjectContext]; // returns managed object
    
    [self generateTestData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning // automatically written
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Connections

-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
    [webData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didRecieveData:(NSData *)data
{
    [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLOg(@"Fail with error");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    NSArray *allNodes = [allDataDictionary objectForKey:@"nodes"];
    
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
//    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    return [matchingData count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (indexPath.row < matchingData.count ) {
        FAQ *faqObj = [matchingData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = faqObj.faqQuestion;
        cell.detailTextLabel.text = faqObj.faqAnswer;
    }
    else {
        cell.textLabel.text = @"No Data";
        cell.detailTextLabel.text = @"test";
    }
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
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

#pragma mark - QA Setup

-(void) addTestDataWithQuestion:(NSString*)faqQuestion andAnswer:(NSString*)faqAnswer {
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSManagedObject *newData = [NSEntityDescription insertNewObjectForEntityForName:@"FAQ" inManagedObjectContext:context];
//
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
    NSManagedObject *newFAQ = [[NSManagedObject alloc]initWithEntity:entityDesc insertIntoManagedObjectContext:managedObjectContext]; //
    
    [newFAQ setValue:faqQuestion forKey:@"faqQuestion"];
    [newFAQ setValue:faqAnswer forKey:@"faqAnswer"];
    [newFAQ setValue:[NSNumber numberWithInt:0] forKey:@"faqIndex"];
    
    NSError *error;
    if(![managedObjectContext save:&error]) {
        NSLog(@"Save Failed: %@", [error localizedDescription]);
    } else {
        NSLog(@"Save Succeeded");
    }
}

-(void) generateTestData {
    
    // create object that describes entity, name must match core data entity name, pass managedObjectContext
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc]; // do a fetch request on entity that fits the description
                                         // predicates used to select certain entities based on certain criteria
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // If we haven't loaded data yet, do it now. Otherwise don't keep loading data on every load of the app.
    if ([matchingData count] == 0) {
        
        
        [self addTestDataWithQuestion:@"Question1" andAnswer:@"Answer1"];
        [self addTestDataWithQuestion:@"Question2" andAnswer:@"Answer2"];
        [self addTestDataWithQuestion:@"Question3" andAnswer:@"Answer3"];
        [self addTestDataWithQuestion:@"Question4" andAnswer:@"Answer4"];
        [self addTestDataWithQuestion:@"Question5" andAnswer:@"Answer5"];
        [self addTestDataWithQuestion:@"Question6" andAnswer:@"Answer6"];
        [self addTestDataWithQuestion:@"Question7" andAnswer:@"Answer7"];
        
        [self.tableView reloadData];
    }
    
    
    
    
}

@end
