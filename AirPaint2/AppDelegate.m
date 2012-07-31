//
//  AppDelegate.m
//  AirPaint2
//
//  Created by Philipp Sessler on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Configurations.h"
#import "StartViewController.h"
#import "CanvasViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize shoeConnection, startViewController, canvasViewController;
@synthesize handTracked;
@synthesize navigationController;
@synthesize configurationsViewController;
@synthesize remoteControl;
@synthesize logger;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.handTracked = NO;
    
    
    // ---- view controllers -----
    startViewController= [[StartViewController alloc] initWithNibName:nil bundle:nil];
    canvasViewController = [[CanvasViewController alloc] initWithNibName:nil bundle:nil];
    configurationsViewController = [[ConfigurationsViewController alloc] init];

    // ---- remote control -----
    remoteControl = [[RemoteControl alloc] init];
    
    // ---- network connection ---
    shoeConnection = [[ShoeConnection alloc] init];
    
    // ---- logger -----
    logger = [[FileLogger alloc] init];
    
    imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.allowsEditing = NO;
	imgPicker.delegate = self;	
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:startViewController];
    
    [navigationController setNavigationBarHidden:YES];
    
    [startViewController.label setText:@"No shoe found :("];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
  //  FLog(@"AirPaint has started");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [shoeConnection close];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // If the user clicks the home-button, end the programm...
    // Won't be apple-approved, but who cares...
    exit(0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [shoeConnection close];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AirPaint2" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AirPaint2.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// ------ navigation -----

- (void) switchToStartViewController
{
    //self.window.rootViewController = startViewController;
    
    if(!self.handTracked)
        [self.navigationController popToRootViewControllerAnimated:NO];
    else 
        [self switchToCanvas];
}

- (void) switchToCanvas 
{
    //self.window.rootViewController = canvasViewController;
    
    
    if(self.navigationController.topViewController == self.configurationsViewController)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [self.navigationController pushViewController:canvasViewController animated:NO];
    
}
- (void) switchToConfigurations 
{
    
    //self.window.rootViewController = canvasViewController;
    [self.navigationController pushViewController:self.configurationsViewController animated:YES];
    
}

// ------ gallery -----

- (void) showGallery {
	[[self.window rootViewController] presentModalViewController:imgPicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}


@end
