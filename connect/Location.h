//
//  Location.h
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * locationAbrv;
@property (nonatomic, retain) NSNumber * locationLatitude;
@property (nonatomic, retain) NSNumber * locationLongitude;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *restaurants;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addRestaurantsObject:(NSManagedObject *)value;
- (void)removeRestaurantsObject:(NSManagedObject *)value;
- (void)addRestaurants:(NSSet *)values;
- (void)removeRestaurants:(NSSet *)values;

@end
