//
//  EventDescriptionViewController.m
//  connect
//
//  Created by NickPiatt on 3/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "EventDescriptionViewController.h"

@interface EventDescriptionViewController ()

@end

@implementation EventDescriptionViewController

@synthesize eventDataDictionary, eventDetailWebview, timeLabel, dateLabel, locationDetailLabel, locationLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"\n%@", eventDataDictionary);
    
    [eventDetailWebview loadHTMLString:[eventDataDictionary objectForKey:@"description"] baseURL:nil];
    
    [self updateTimeAndDateLabels];
    
    [locationLabel setText:[eventDataDictionary objectForKey:@"location"]];
    [locationDetailLabel setText:[eventDataDictionary objectForKey:@"room"]];
    
	// Do any additional setup after loading the view.
}

-(void)updateTimeAndDateLabels {
    NSDictionary *hourDict = [eventDataDictionary objectForKey:@"hours"];
    [timeLabel setText:[NSString stringWithFormat:@"%@-%@", [hourDict objectForKey:@"timeStart"], [hourDict objectForKey:@"timeEnd"]]];
    
    NSString *dateLabelString = [NSString stringWithFormat:@"%@, %@ %@", [hourDict objectForKey:@"dayOfWeekShort"], [hourDict objectForKey:@"month"], [hourDict objectForKey:@"dayNum"]];
    [dateLabel setText:dateLabelString];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
