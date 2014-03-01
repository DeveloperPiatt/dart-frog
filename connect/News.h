//
//  News.h
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface News : NSManagedObject

@property (nonatomic, retain) NSString * newsDate;
@property NSInteger * newsIndex;
@property (nonatomic, retain) NSString * newsSummary;
@property (nonatomic, retain) NSString * newsTitle;
@property (nonatomic, retain) NSString * newsLink;

@end
