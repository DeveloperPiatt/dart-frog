//
//  StoryViewController.m
//  connect
//
//  Created by Taylor Cuilty on 4/2/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "StoryViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "News.h"
#import "NewsTableViewController.h"

@interface StoryViewController ()

@end

@implementation StoryViewController

@synthesize articleContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(articleContent);
    
    [_storyWebview loadHTMLString:articleContent baseURL:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

@end
