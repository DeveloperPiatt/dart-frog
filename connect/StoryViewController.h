//
//  StoryViewController.h
//  connect
//
//  Created by Taylor Cuilty on 4/2/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *storyWebview;
@property (strong, nonatomic) NSString *articleContent;


@end
