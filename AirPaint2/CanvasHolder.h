//
//  CanvasHolder.h
//  AirPaint2
//
//  Created by Philipp Sessler on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CanvasViewController.h"

@class AppDelegate;

@interface CanvasHolder : UIView {
    AppDelegate *appDelegate;
    Canvas *canvas;
    
    UIImage *tempBackground;
    
    bool transformationHasJustStarted;
    
    // transformation help variables
    float transformationLastScale;
    CGPoint transformationLastDelta;
 
    CGPoint transformation_toAdd_delta;
    float transformation_toAdd_scale;

    NSMutableArray *backgroundImageLayers;

    
    // activity view
    UIActivityIndicatorView *activity;
    NSTimer *timer;
    bool snapshotDone;
    bool canProcessCommands;
    
}




@property (atomic, retain) UIImageView* currentBackgroundLayerImageView;

- (id)initWithCanvas:(Canvas*) _canvas;

- (void) translation:(CGPoint) delta withScale: (float) scale doBreak:(bool) doBreak finished:(BOOL)finished cancel:(bool)cancel;
- (void) eraseToIndex:(int) index finished:(bool) finished;
- (void) saveTransformation;
- (void) startTransformation;
- (UIImage*) getSnapshotImage;
- (int) totalLinesCount;

- (void) activityTimer;

@end
