//
//  Restaurant.h
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Restaurant : NSManagedObject

@property (nonatomic, retain) NSString * restaurantClose;
@property (nonatomic, retain) NSString * restaurantName;
@property (nonatomic, retain) NSString * restaurantOpen;
@property (nonatomic, retain) Location *location;

@end
