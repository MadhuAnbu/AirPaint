//
//  ViewController.h
//  ColorPickerTest
//
//  Created by Philipp Sessler on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CDCircle.h"
#import "CDCircleOverlayView.h"
#import "Line.h"
#import "SettingViewController.h"

@class  AppDelegate;

@interface BrushColorViewController : SettingViewController <CDCircleDelegate, CDCircleDataSource> {
    
    AppDelegate *appDelegate;
    
    UIImageView *backgroundImageView;
    
    CDCircle *circle;
    CDCircleOverlayView *overlay;
 
    NSArray * colors;
        
    UIColor* currentColor;
    
    float oldAngle;
    
    UIView *arrowImageViewHolder;
    UIImageView *arrowImageView;
    bool arrowDown;
}

- (id)initWithCanvasViewController:(CanvasViewController*) viewController;

- (void) nextColor;
- (void) previousColor;

- (void) selectSegmentWithAngle:(int) angle;

- (UIColor*) getCurrentUIColor;
- (Color) getCurrentColor;

- (void) setCurrentColor:(UIColor*) col;

@end
