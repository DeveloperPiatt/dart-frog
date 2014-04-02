//
//  EventSymposiumCell.h
//  connect
//
//  Created by NickPiatt on 4/2/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventSymposiumCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;

@end
