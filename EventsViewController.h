//
//  EventsViewController.h
//  connect
//
//  Created by NickPiatt on 3/24/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) NSDictionary *calendarData;

@end
