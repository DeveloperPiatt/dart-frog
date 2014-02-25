//
//  ContactsViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/24/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "ContactsViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Contact.h"
#import "ContactCell.h"

@interface ContactsViewController () {
    
    NSManagedObjectContext *managedObjectContext;
    NSMutableData *webData;
    NSURLConnection *connection;
    CoreDataHelper *cData;
}

@end

@implementation ContactsViewController

# pragma mark - Initilize

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
    NSURL *url = [NSURL URLWithString:@"http://connect.oregonstate.edu/directory/json"];
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Connection

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


#pragma mark - JSON transformation

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"ConnectionFinishedLoading");
    [cData removeManagedObjectsForEntity:@"Contact"];
    [self createManagedObjectsForContactEntity];
    [cData saveManagedObjectContext];
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
    NSArray *matchingData = [cData getArrayOfManagedObjectsForEntity:@"Contact" withSortDescriptor:@""];
    
    //Return the number of rows
    return [matchingData count];
}


- (ContactCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell
    
    NSArray *matchingData = [cData getArrayOfManagedObjectsForEntity:@"Contact" withSortDescriptor:@"contactTitle"];
        
    if (indexPath.row < matchingData.count) {
        Contact *contactObj = [matchingData objectAtIndex:indexPath.row];
        
        cell.title.text = contactObj.contactTitle;
        cell.number.text = contactObj.contactNumber;
    }
    else {
        
        cell.title.text = @"NoData";
        cell.number.text = @"NoData";
    }
    
    return cell;
}


# pragma mark - Core Data

-(void)createManagedObjectsForContactEntity
{
    //Create foundation object for JSON data and stores values in array
    NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    NSArray *allNodes = [allDataDictionary objectForKey:@"nodes"];
    
    for (NSDictionary *nodeIndex in allNodes)
    {
        //Create and assign values to entities
    
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:managedObjectContext];
        Contact *newContact = [[Contact alloc]initWithEntity:entityDesc insertIntoManagedObjectContext:managedObjectContext];
    
        newContact.contactTitle = [[nodeIndex objectForKey:@"node"] objectForKey:@"title"];
        newContact.contactTitle = [newContact.contactTitle stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        if ([[[nodeIndex objectForKey:@"node"] objectForKey:@"phone_number"] isKindOfClass:[NSDictionary class]] == YES) {
            newContact.contactNumber = [[[nodeIndex objectForKey:@"node"] objectForKey:@"phone_number"] objectForKey:@"1"];
        }
        else {
            
        newContact.contactNumber = [[nodeIndex objectForKey:@"node"] objectForKey:@"phone_number"];
        }
    }
}

# pragma mark - Call contact

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = (ContactCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cell.number.text]];
    
    NSLog(@"Calling %@", cell.number.text);
}

/*-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    ContactCell *cell = (ContactCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    ABAuthorizationStatus access = ABAddressBookGetAuthorizationStatus();
    
    if (access == 0) {
        
    ABAddressBookRequestAccessCompletionHandler completion;
    ABAddressBookRequestAccessWithCompletion(addressBook, completion);
 
    }
 
    if (access != 0) {
 
        ABRecordRef newContact = ABPersonCreate();
        
        ABRecordSetValue(newContact, kABPersonFirstNameProperty, (__bridge CFStringRef)cell.title.text, /&error);
        ABRecordSetValue(newContact, kABPersonPhoneProperty, (__bridge CFStringRef)cell.number.text, &error);
    
        ABAddressBookAddRecord(addressBook, newContact, &error);
        ABAddressBookSave(addressBook, &error);
    }
    else
    {
       NSLog(@"%ld", access);
    }
}
*/

@end
