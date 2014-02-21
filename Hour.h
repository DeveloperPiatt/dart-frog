//
//  Hour.h
//  connect
//
//  Created by Taylor Cuilty on 2/21/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Restaurant;

@interface Hour : NSManagedObject

@property (nonatomic, retain) NSDate * hourEnd;
@property (nonatomic, retain) NSDate * hourStart;
@property (nonatomic, retain) Restaurant *restaurant;

@end
