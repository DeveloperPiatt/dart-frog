//
//  TestClass.m
//  connect
//
//  Created by NickPiatt on 2/19/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import "CoreDataHelper.h"
#import "AppDelegate.h"

#import "Restaurant.h"
#import "Location.h"
#import "Event.h"
#import "News.h"
#import "Contact.h"
#import "Tweet.h"
#import "FAQ.h"

@implementation CoreDataHelper {
    NSManagedObjectContext *managedObjectContext;
}

-(id)init {
    self = [super init];
    
    if (self) {
        //Creates and returns managed object of AppDelegate class
        AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
        managedObjectContext = [appdelegate managedObjectContext];
    }
    
    return self;
}

-(NSArray*)getArrayOfManagedObjectsForEntity:(NSString*)entityName withSortDescriptor:(NSString*)sortDescript {
    
    
    //Create object that describes entity, name must match core data entity name, pass managedObjectContext
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    if (![sortDescript isEqualToString:@""])
    {
        //Perform fetch request on entity that fits the description
        //Predicates used to select entities based on certain criteria
        NSSortDescriptor *sortDescriptorIndex = [[NSSortDescriptor alloc]initWithKey:sortDescript ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc]initWithObjects: sortDescriptorIndex, nil];
        
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    
    NSError *error;
    NSArray *matchingData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return matchingData;
}

-(void)saveManagedObjectContext
{
    NSError *error;
    if(![managedObjectContext save:&error]) {
        NSLog(@"SaveFailed: %@", [error localizedDescription]);
    }
    else {
        NSLog(@"SaveSucceeded");
    }
}

-(void)removeManagedObjectsForEntity: (NSString*)entityName
{
    NSArray *allManagedObjects = [self getArrayOfManagedObjectsForEntity:entityName withSortDescriptor:@""];
    
    for (NSManagedObject *toDelete in allManagedObjects) {
        [managedObjectContext deleteObject:toDelete];
    }
}

@end
