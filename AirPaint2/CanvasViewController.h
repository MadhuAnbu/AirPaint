//
//  CanvasViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "AsyncUdpSocket.h"
#import "SidebarViewController.h"
#import "SettingViewController.h"
#import "BrushSizeViewController.h"
#import "EraseViewController.h"
#import "BrushColorViewController.h"
#import "VariousStuffViewController.h"
#import "TransformViewController.h"

#import "PencilCursor.h"
#import "Canvas.h"
#import "CanvasHolder.h"
#import "ShoeConnection.h"

@class SidebarViewController;
@class SettingViewController;
@class EraseViewController;
@class VariousStuffViewController;
@class BrushColorViewController;
@class BrushSizeViewController;
@class TransformViewController;
@class CanvasHolder;
@class Canvas;
@class AppDelegate;
@class ShoeConnection;

@interface CanvasViewController : UIViewController {
    
    AppDelegate *appDelegate;
    ShoeConnection *shoeConnection;
    
    bool sidebarIsVisible;
    bool sidebarIsAnimating;
    
    bool popupIsVisible;
    
    // for point drawing
    CGPoint lastPoint;
    CGPoint firstPinchPoint;
    CGPoint lastPinchPoint;
    bool useFirstPinchPoint;
        
    
    // for erasing (slider)
    bool sliderValid;
    int slider_lastvalue;
    
    // for various stuff (fingercont)
    int fingerCount_value;
    
    // for transforming
    CGPoint translation_last_delta;
    float translation_last_scale;
   
    bool erasePopupVisible;
    
  }

@property (atomic, retain) UILabel *debugLabel;     // only for debug purposes

@property (nonatomic, retain) CanvasHolder* canvasHolder;
@property(nonatomic, retain) Canvas *canvas;

@property (nonatomic, retain) PencilCursor *pencilCursor;

@property (readonly, nonatomic, retain) SidebarViewController *sidebarViewController;

@property (nonatomic, retain) SettingViewController *currentPopup;
@property (nonatomic, retain) EraseViewController *eraseViewController;
@property (nonatomic, retain) BrushSizeViewController *brushSizeViewController;
@property (nonatomic, retain) BrushColorViewController *brushColorViewController;
@property (nonatomic, retain) VariousStuffViewController *variousStuffViewController;
@property (nonatomic, retain) TransformViewController *transformViewController;

// active actions
@property bool variousStuffIsActive;
@property bool brushColorIsActive;
@property bool eraseIsActive;
@property bool brushSizeIsActive;

// process incoming commands from shoe (called from ShoeConnection) 
- (void) processCommand:(NSString*) msg;

// update brush (called form BrushSizeViewController & BrushColorViewController)
- (void) updateBrush;

// sidebar
- (IBAction)hideSidebar:(id)sender;

// popups (settings)
- (void) showPopup:(SettingViewController *) popupView;
- (void) hidePopup;

// erase poupup (special kind of popup ;) )
- (void) showErasePopup;
- (void) hideErasePopup;
- (void) progressEraseSliderWithCurrentPoint: (int) currentPoint;    

// other functions
- (CGPoint) clipCursorPoint:(CGPoint) point;      

// cursor function
- (void) hideCursor;
- (void) showCursor;

- (void) quitCurrentAction;

@end
