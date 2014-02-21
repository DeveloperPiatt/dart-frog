//
//  FoodCell.m
//  connect
//
//  Created by Taylor Cuilty on 2/21/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "FoodCell.h"

@implementation FoodCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
