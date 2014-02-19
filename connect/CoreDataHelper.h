//
//  TestClass.h
//  connect
//
//  Created by NickPiatt on 2/19/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject

-(NSArray*)getArrayOfManagedObjectsForEntity:(NSString*)entityName withSortDescriptor:(NSString*)sortDescript;

-(void)saveManagedObjectContext;
-(void)removeManagedObjectsForEntity: (NSString*)entityName;

@end
