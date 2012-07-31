//
//  TansformViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 01.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"

@class AppDelegate;

@interface TransformViewController : SettingViewController {
    AppDelegate  *appDelegate;
    CGPoint lastDelta;
    
    UIImageView *backgroundImageView;
}

- (id)initWithCanvasViewController:(CanvasViewController*) viewController;

- (void) cancel;
- (void) quit;

@end
