//
//  FAQCell.h
//  connect
//
//  Created by Taylor Cuilty on 2/10/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAQCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerLabel;


@end
