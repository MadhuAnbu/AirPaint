//
//  BrushSizeViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "TriangleView.h"

@class AppDelegate;

@interface BrushSizeViewController : SettingViewController {
    AppDelegate *appDelegate;
    TriangleView *triangle;
    float brushSize;
    UIImageView *backgroundImageView;
    UISlider *slider;
    int lastValue;
}

- (id)initWithCanvasViewController:(CanvasViewController*) viewController;
- (void) setBrushSize:(float) size;
- (float) getBrushSize;
- (IBAction)sliderChanged:(id)sender;
- (void) progressSliderGestureValue:(int) value;
- (void) setSliderValue:(int) value;

@property (retain, atomic) UISlider *slider;
@end

