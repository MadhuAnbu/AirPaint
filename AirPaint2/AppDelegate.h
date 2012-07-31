//
//  AppDelegate.h
//  AirPaint2
//
//  Created by Philipp Sessler on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "CanvasViewController.h"
#import "StartViewController.h"
#import "ShoeConnection.h"
#import "ConfigurationsViewController.h"
#import "RemoteControl.h"
#import "FileLogger.h"

@class StartViewController;
@class CanvasViewController;
@class ShoeConnection;
@class ConfigurationsViewController;
@class RemoteControl;
@class FileLogger;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIImagePickerController *imgPicker;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, retain, atomic) FileLogger *logger;

@property (readonly, retain, atomic) UINavigationController *navigationController;
@property (readonly, retain, atomic)  ShoeConnection * shoeConnection;
@property (readonly, retain, atomic) StartViewController *startViewController;
@property (readonly, retain, atomic) CanvasViewController *canvasViewController;
@property (readonly, retain, atomic) ConfigurationsViewController *configurationsViewController;

@property (readonly, retain, atomic) RemoteControl *remoteControl;

@property bool handTracked;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) showGallery;

// ---- navigation ---
- (void) switchToStartViewController;
- (void) switchToCanvas ;
- (void) switchToConfigurations;

@end
