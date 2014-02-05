//
//  FaqViewController.h
//  connect
//
//  Created by Taylor Cuilty on 2/3/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAQ.h"

@interface FaqViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)FAQ *selectedFAQ;
@property (weak, nonatomic) IBOutlet UITableView *FaqTableView;

@end
