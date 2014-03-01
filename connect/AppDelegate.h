//
//  AppDelegate.h
//  connect
//
//  Created by NickPiatt on 1/21/14.
//  Copyright (c) 2014 Oregon State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, strong, nonatomic) NSMutableArray *xmlArray;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
