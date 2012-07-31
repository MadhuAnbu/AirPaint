//
//  EraseViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "CanvasViewController.h"
#import "Canvas.h"
#import "AppDelegate.h"

@class CanvasViewController;
@class Canvas;
@class AppDelegate;

@interface EraseViewController : UIViewController {
    CanvasViewController *canvasViewController;
    Canvas *canvas;
    AppDelegate *appDelegate;
    
    int lastValue;
    UIImageView *backgroundImageView;

}

@property (retain, atomic) UISlider *slider;
@property int eraseToIndex;

- (id) initWithCanvasWithController:(CanvasViewController*) viewController;
- (IBAction)sliderChanged:(id)sender;
- (void) setSliderValue:(int) value;

@end
