//
//  Restaurant.h
//  connect
//
//  Created by NickPiatt on 2/27/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hour, Location;

@interface Restaurant : NSManagedObject

@property (nonatomic, retain) NSString * restaurantName;
@property (nonatomic, retain) NSSet *hours;
@property (nonatomic, retain) Location *location;
@end

@interface Restaurant (CoreDataGeneratedAccessors)

- (void)addHoursObject:(Hour *)value;
- (void)removeHoursObject:(Hour *)value;
- (void)addHours:(NSSet *)values;
- (void)removeHours:(NSSet *)values;

@end
