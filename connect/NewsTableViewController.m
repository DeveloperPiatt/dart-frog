//
//  NewsTableViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/27/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "NewsTableViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "XMLParser.h"


@interface NewsTableViewController () {
    
    CoreDataHelper *cData;
    NSManagedObjectContext *managedObjectContext;
}

@end

@implementation NewsTableViewController

# pragma - mark Initilize

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cData = [[CoreDataHelper alloc]init];
    
    //Idicates activity while table view loads data
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Creates and returns managed object of AppDelegate class
    AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
    managedObjectContext = [appdelegate managedObjectContext];
    
    NSURL *url = [[NSURL alloc]initWithString:@"http://blogs.oregonstate.edu/newstudents/feed/"];
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    Parser *theParser = [[Parser alloc]initParser];
    
    [xmlParser setDelegate:theParser];
    
    

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
    NSArray *matchingData = [cData getArrayOfManagedObjectsForEntity:@"News" withSortDescriptor:@""];
    
    //Return the number of rows
    return [matchingData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Connection

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"Found file");
    NSLog(@"Begin parse");
    
}

#pragma mark - XML transformation

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"ConnectionFinishedLoading");
    [cData removeManagedObjectsForEntity:@"News"];
    [cData saveManagedObjectContext];
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//}

@end
