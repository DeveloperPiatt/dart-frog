//
//  Tweet.h
//  connect
//
//  Created by Taylor Cuilty on 2/17/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweetAvatar;
@property (nonatomic, retain) NSString * tweetLink;
@property (nonatomic, retain) NSString * tweetText;
@property (nonatomic, retain) NSString * tweetTime;
@property (nonatomic, retain) NSString * tweetUser;

@end
