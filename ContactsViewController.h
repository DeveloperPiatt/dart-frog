//
//  ContactsViewController.h
//  connect
//
//  Created by Taylor Cuilty on 2/24/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *testTableView;

@end
