//
//  NewsTableViewController.h
//  connect
//
//  Created by Taylor Cuilty on 2/27/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "News.h"

@interface NewsTableViewController : UITableViewController

@property (nonatomic, retain) AppDelegate *app;
@property (nonatomic, retain) News *theNews;

@end
