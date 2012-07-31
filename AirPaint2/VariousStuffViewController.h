//
//  VariousStuffViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 07.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingViewController.h"

@class AppDelegate;

@interface VariousStuffViewController : SettingViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *menuTable;
    
    AppDelegate *appDelegate;
    
    ALAssetsLibrary* library;
    
    UIImageView *backgroundImageView;

    // activity indicator (for saving canvas)
    UIActivityIndicatorView *activity;
    NSTimer *timer;
    bool canvasSaved;
    
    int displayStartRow;

    UIImageView *arrowImageView;

    bool arrowDown;
}

- (id)initWithCanvasViewController:(CanvasViewController*) viewController;
- (void) selectMenuPoint:(int) index;
- (IBAction)performSelectAction:(id)sender;

- (void) increaseSelectedMenuPoint;
- (void) deselectSelectedMenuPoint;

- (void) activityTimer;

- (void) scrollMenuDown;
- (void) scrollMenuUp;

@end
