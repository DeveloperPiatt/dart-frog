//
//  FAQ.h
//  connect
//
//  Created by NickPiatt on 2/3/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FAQ : NSManagedObject

@property (nonatomic, retain) NSString * faqQuestion;
@property (nonatomic, retain) NSString * faqAnswer;
@property (nonatomic, retain) NSNumber * faqIndex;

@end
