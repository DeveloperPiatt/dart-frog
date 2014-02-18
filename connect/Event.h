//
//  Event.h
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * eventDetails;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * eventRoom;
@property (nonatomic, retain) NSString * eventTime;
@property (nonatomic, retain) NSManagedObject *location;

@end
