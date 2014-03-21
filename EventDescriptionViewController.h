//
//  EventDescriptionViewController.h
//  connect
//
//  Created by NickPiatt on 3/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDescriptionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic) IBOutlet UIWebView *eventDetailWebview;
@property (nonatomic, strong) NSDictionary *eventDataDictionary;
@end
