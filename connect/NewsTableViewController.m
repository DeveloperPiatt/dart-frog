//
//  NewsTableViewController.m
//  connect
//
//  Created by Taylor Cuilty on 2/27/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "NewsTableViewController.h"
#import "CoreDataHelper.h"
#import "XMLParser.h"
#import "NewsCell.h"


@interface NewsTableViewController () {
    
    NSManagedObjectContext *managedObjectContext;
    XMLParser *theParser;
}

@end

@implementation NewsTableViewController
@synthesize app;
@synthesize theNews;

# pragma - mark Initilize

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Hi");
    app = [[UIApplication sharedApplication] delegate];
    
    [self.tableView reloadData];
    
    //Idicates activity while table view loads data
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Creates and returns managed object of AppDelegate class
    AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
    managedObjectContext = [appdelegate managedObjectContext];
    
    
    NSURL *url = [[NSURL alloc]initWithString:@"http://blogs.oregonstate.edu/newstudents/feed/"];
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    theParser = [[XMLParser alloc]initParser];
    
    [xmlParser setDelegate:theParser];
    
    BOOL worked = [xmlParser parse];
    
    if (worked) {
        NSLog(@"Amount %i", [theParser.xmlArray count]);
    } else {
        NSLog(@"No");
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
    //Return the number of rows
    return [theParser.xmlArray count];
}

- (NewsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsCell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"%d", [theParser.xmlArray count]);
    theNews = [theParser.xmlArray objectAtIndex:indexPath.row];
    
    cell.storyTitle.text = theNews.newsTitle;
    cell.storyDate.text = theNews.newsDate;
    cell.storyDescript.text = theNews.newsSummary;
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//}

@end
