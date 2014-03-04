//
//  NewsCell.h
//  connect
//
//  Created by Taylor Cuilty on 3/3/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storyTitle;
@property (weak, nonatomic) IBOutlet UILabel *storyDate;
@property (weak, nonatomic) IBOutlet UITextView *storyDescript;

@end
