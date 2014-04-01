//
//  EventDescriptionViewController.m
//  connect
//
//  Created by NickPiatt on 3/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#warning TODO tasks
// TODO: Make the favorite circle clickable
// TODO: When user clicks favorite button it needs to highlight the button
// TODO: When user clicks favorite button we need to add it to DB as a favorited event
// TODO: When a location room is not provided, the detail webview comes up too high and clips off some of the location pin and favorite circle

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
