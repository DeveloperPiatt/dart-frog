//
//  Hour.h
//  connect
//
//  Created by NickPiatt on 2/21/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Restaurant;

@interface Hour : NSManagedObject

@property (nonatomic, retain) NSString * hourEnd;
@property (nonatomic, retain) NSString * hourStart;
@property (nonatomic, retain) Restaurant *restaurant;

@end
