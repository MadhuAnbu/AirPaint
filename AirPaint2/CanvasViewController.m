//
//  CanvasViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CanvasViewController.h"
#import "SidebarViewController.h"
#import "SettingViewController.h"
#import "Configurations.h"
#import "EraseViewController.h"
#import "Line.h"
#import "BrushColorViewController.h"

@implementation CanvasViewController
@synthesize debugLabel, canvas, canvasHolder, pencilCursor;
@synthesize sidebarViewController, brushColorViewController, eraseViewController, variousStuffViewController, brushSizeViewController, transformViewController;
@synthesize currentPopup;
@synthesize variousStuffIsActive, brushColorIsActive, eraseIsActive, brushSizeIsActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        shoeConnection = [appDelegate shoeConnection];

        sidebarIsVisible = NO;
        sidebarIsAnimating = NO;
        popupIsVisible = NO;
                
        currentPopup = nil;
                
        useFirstPinchPoint = NO;
         
        fingerCount_value = -1;
        
        translation_last_delta = CGPointMake(0, 0);
        translation_last_scale = 1.0;
    
        
        // active actions
        self.variousStuffIsActive = NO;
        self.brushColorIsActive = NO;
        
        // canvas 
        self.canvas = [[Canvas alloc] init];
        
        // canvasHolder
        self.canvasHolder = [[CanvasHolder alloc] initWithCanvas:self.canvas];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];    
      
    // create sidebar
    sidebarViewController = [[SidebarViewController alloc] initWitCanvas:self];   
    
    CGRect frame = self.sidebarViewController.view.frame;
    frame.origin.x = -SIDEBAR_WIDTH;
    sidebarViewController.view.frame = frame;
    
    [self.view addSubview:self.sidebarViewController.view];
    [self addChildViewController:self.sidebarViewController];

    [self.view addSubview:canvasHolder];;
    
    // create pencil-cursor
    self.pencilCursor = [[PencilCursor alloc] init];
    [self.view addSubview:self.pencilCursor.view];
    [self.view bringSubviewToFront:self.pencilCursor.view];
 
    // -------- debug label ----------
    self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 30)];
    [self.debugLabel setBackgroundColor:[UIColor grayColor]];;
    [self.debugLabel setFont:[ [self.debugLabel font] fontWithSize:12.0]];
    [self.view addSubview:self.debugLabel];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


-(IBAction)hideSidebar:(id)sender {

    if(!sidebarIsVisible || sidebarIsAnimating) return ;
      sidebarIsAnimating = YES;
    
    [sidebarViewController hide];
    
    [UIView animateWithDuration:REVEAL_ANIMATION_SPEED animations:^{
        CGRect frame = self.sidebarViewController.view.frame;
        frame.origin.x = -SIDEBAR_WIDTH;
        self.sidebarViewController.view.frame = frame;
    } completion:^(BOOL finished){
        sidebarIsAnimating = NO;
        sidebarIsVisible = NO;
    }];

}

-(IBAction)showSidebar:(id)sender {

    [self.view bringSubviewToFront:self.sidebarViewController.view];
    
    if(sidebarIsVisible || sidebarIsAnimating) return ;
    
    sidebarIsVisible = YES;
    sidebarIsAnimating = YES;
    
    [sidebarViewController show];
    
    [UIView animateWithDuration:REVEAL_ANIMATION_SPEED animations:^{
        CGRect frame = self.sidebarViewController.view.frame;
        frame.origin.x = 0;
        self.sidebarViewController.view.frame = frame;
    } completion:^(BOOL finished){
        sidebarIsAnimating = NO;
    }];

}

- (void) showPopup:(SettingViewController *) popupView {
    
    if(popupIsVisible) return ;

    [self.view addSubview:popupView.view];
    [self addChildViewController:popupView];
    
    popupIsVisible = YES;
    currentPopup = popupView;
}

- (void) hidePopup {
    
    if(!popupIsVisible) return ;
    
    [currentPopup.view removeFromSuperview];
    [currentPopup removeFromParentViewController];
    
    popupIsVisible = NO;
}


// ----------------------------------------------------------------------------------



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    

    if(sidebarIsVisible && [touch locationInView:self.view].x > 100) {
                
        [self hideSidebar:self];   
    }
    else { 
        [self showSidebar:self];
    }

}
 


- (void) showErasePopup {
    
    if(erasePopupVisible) return;
        else erasePopupVisible = YES;
    
    sliderValid = NO;
    self.eraseViewController.eraseToIndex = [canvasHolder totalLinesCount] - 1;
    
    self.eraseViewController = [[EraseViewController alloc] initWithCanvasWithController:self];
    [self.view addSubview:self.eraseViewController.view];
    [self addChildViewController:self.eraseViewController];
}

- (void) hideErasePopup {
    
    if(!erasePopupVisible) return;
        else erasePopupVisible = NO;
    
    sliderValid = NO;
    [canvas eraseToIndex:self.eraseViewController.eraseToIndex finished:YES];  
    
    [self.eraseViewController.view removeFromSuperview];
    [self.eraseViewController removeFromParentViewController];
    self.eraseViewController = nil;
    
}

// ----------------------------------------------------------------------------------


- (void) progressEraseSliderWithCurrentPoint: (int) currentPoint {
    
    int steps = [[self.canvas lines] count];
    int stepWidth = SLIDER_STEP_WIDTH_PREFERED;
 
    if ( (SLIDER_START_POINT - SLIDER_END_POINT )/ steps < SLIDER_STEP_WIDTH_PREFERED ) {
        stepWidth = (SLIDER_START_POINT - SLIDER_END_POINT )/ steps;
        
        if(stepWidth==0) stepWidth=SLIDER_STEP_WIDTH_MIN;
    }
    
    steps--;
    
    if(!sliderValid) {

        [self.debugLabel setText:[NSString stringWithFormat:@"Slider NOT VALID"]];

        if(currentPoint >= SLIDER_START_POINT) 
            sliderValid = YES;

    } else {
        
        [self.debugLabel setText:[NSString stringWithFormat:@"Slider VALID - currentValue: %i\t Lines:%i\t stepWidth:%i", currentPoint, [[self.canvas lines] count], stepWidth]];
       
        if(currentPoint > SLIDER_START_POINT) 
            currentPoint = SLIDER_START_POINT;
        else if(currentPoint < SLIDER_END_POINT) 
            currentPoint = SLIDER_END_POINT;
        
        int stepsMade = (SLIDER_START_POINT - currentPoint) / stepWidth;
        int sliderValue = steps - stepsMade;    

        NSLog(@"steps made: %i, slider-value: %i (max-steps: %i)\n", stepsMade, sliderValue, steps);
        
        if(sliderValue != [self.eraseViewController.slider value]) {
            printf("do\n");
            [self.eraseViewController setSliderValue:sliderValue];
        }
    }
}

// ----------------------------------------------------------------------------------



- (void) processCommand:(NSString*) msg {
    
    [self.debugLabel setText:@""];
    
    NSArray *chunks = [msg componentsSeparatedByString:@";"];
    NSString *gesture = [chunks objectAtIndex:0];
    
    
    
    if ([gesture isEqualToString:@"pinch_start"] || [gesture isEqualToString:@"pinch"]) {
        
        
        float x_coord = [((NSString *)[chunks objectAtIndex:1]) intValue];
        float y_coord = [((NSString *)[chunks objectAtIndex:2]) intValue];
        
        // NSLog(@"%@", gesture);
        if([gesture isEqualToString:@"pinch_start"]) {
            
            // last Point = the one of the cursor
            
            firstPinchPoint = CGPointMake(x_coord, y_coord);
            useFirstPinchPoint = YES;
            
            FLog(@"%f,%f", lastPoint.x, lastPoint.y);

            // lastPoint is last cursor point; draw first point
            [canvas addAndRenderLineWithStartPoint:lastPoint endPoint:lastPoint color:[brushColorViewController getCurrentColor] lineWidth:[brushSizeViewController getBrushSize]];
            
      
        } else {
            
            CGPoint delta;
            if(useFirstPinchPoint) {
                
                delta = CGPointMake(x_coord - firstPinchPoint.x, 
                                    y_coord - firstPinchPoint.y);
                
                useFirstPinchPoint = NO;
                
            } else {
                
                delta = CGPointMake(x_coord - lastPinchPoint.x, 
                                    y_coord - lastPinchPoint.y);
            }
            
            CGPoint newPoint = CGPointMake(lastPoint.x + delta.x, 
                                           lastPoint.y +delta.y);
            
            //printf("Line (%f,%f) to (%f,%f)\n", lastPoint.x, lastPoint.y, newPoint.x, newPoint.y);
                        
            FLog(@"%f,%f", newPoint.x, newPoint.y);
            [canvas addAndRenderLineWithStartPoint:lastPoint endPoint:newPoint color:[brushColorViewController getCurrentColor] lineWidth:[brushSizeViewController getBrushSize]];
        
            lastPoint = newPoint;
            lastPinchPoint = CGPointMake(x_coord, y_coord);
            
        }
        
    } else if([gesture isEqualToString:@"cursor"]) {
        float x_coord = [((NSString *)[chunks objectAtIndex:1]) intValue];
        float y_coord = [((NSString *)[chunks objectAtIndex:2]) intValue];
        lastPoint = CGPointMake(x_coord, y_coord);
        
        lastPoint = [self clipCursorPoint:lastPoint];
        
        [self.pencilCursor movePencilCursorTo:lastPoint];
        
    } else if([gesture isEqualToString:@"eraseStart"]) {
        
        eraseIsActive = YES;
        slider_lastvalue = -100;
        [self showErasePopup];
              
    // ---------------------------- pinch -------------------------------------
    // for transformation

    } else if([gesture isEqualToString:@"transform"]) {
        
        
        CGPoint delta = CGPointMake(
                            [((NSString *)[chunks objectAtIndex:1]) floatValue], 
                            [((NSString *)[chunks objectAtIndex:2]) floatValue]);
        
        float scale = [((NSString *)[chunks objectAtIndex:3]) floatValue];
    
        if(scale > TRANSFORMATION_SCALE_MAX) scale = TRANSFORMATION_SCALE_MAX;
        if(scale < TRANSFORMATION_SCALE_MIN) scale = TRANSFORMATION_SCALE_MIN;
        
        if(delta.x != translation_last_delta.x 
           || delta.y != translation_last_delta.y
           || scale != translation_last_scale) {
            
            translation_last_delta = delta;
            translation_last_scale = scale;
                    
            [canvasHolder translation:delta withScale:(1+scale) doBreak:NO finished:NO cancel:NO];
        }
        
        [self.debugLabel setText:[NSString stringWithFormat:@"Transform: (%f,%f) \t Scale: %f", translation_last_delta.x, 
                translation_last_delta.y, 
                1+translation_last_scale]];

        
    } else if([gesture isEqualToString:@"transformFinished"]) {
      
        [canvasHolder translation:translation_last_delta withScale:1+translation_last_scale doBreak:YES finished:NO cancel:NO];
        
    // ---------------------------- swipe -------------------------------------
    // for brush color
        
    } else if([gesture isEqualToString:@"swipe"]) {
        
        NSString *direction = [chunks objectAtIndex:1];
        if([direction isEqualToString:@"up"]) {
                        if(self.brushColorIsActive) [brushColorViewController nextColor];
            if(self.variousStuffIsActive) [variousStuffViewController scrollMenuDown];
            
        }  else if ([direction isEqualToString:@"down"]) {
                        
            if(self.brushColorIsActive) 
                [brushColorViewController previousColor];
            if(self.variousStuffIsActive) [variousStuffViewController scrollMenuUp];

        }
    
    
    // ---------------------------- circle -------------------------------------
    // for brush color
    
    } else if([gesture isEqualToString:@"circle"]) {
      
        int angle = [[chunks objectAtIndex:1] intValue];

        [brushColorViewController selectSegmentWithAngle:angle];
    
    // ---------------------------- slider -------------------------------------
    // for brush size & erase 
    
    } else if([gesture isEqualToString:@"slider"]) {
    
        if(eraseIsActive) {
          
            int current_sliderValue = [((NSString *)[chunks objectAtIndex:1]) intValue];
            
            if(current_sliderValue != slider_lastvalue) {
                slider_lastvalue = current_sliderValue;
                [self progressEraseSliderWithCurrentPoint:slider_lastvalue];
            }

            
        } else if(brushSizeIsActive) {
            int current_sliderValue = [((NSString *)[chunks objectAtIndex:1]) intValue];

            [brushSizeViewController progressSliderGestureValue:current_sliderValue];
            
        }
        
    }  else if([gesture isEqualToString:@"fingerCount"]) {
        
           
        int fingerCount = [[chunks objectAtIndex:1] intValue];
        
        if(fingerCount_value == -1) {
            
            [variousStuffViewController selectMenuPoint:fingerCount];
            fingerCount_value = fingerCount;
        } else if(fingerCount_value == fingerCount) {
            [variousStuffViewController increaseSelectedMenuPoint];
        } else if(fingerCount_value != fingerCount) {
            [variousStuffViewController deselectSelectedMenuPoint];
            [variousStuffViewController selectMenuPoint:fingerCount];
            fingerCount_value = fingerCount;
        }
        
    } else if([gesture isEqualToString:@"fingerCountChanged"]) {
        [variousStuffViewController deselectSelectedMenuPoint];
        fingerCount_value = -1;
        
    } else if([gesture isEqualToString:@"triangle"]) {
        
        [brushSizeViewController setBrushSize:([[chunks objectAtIndex:1] floatValue]*BRUSH_SIZE_MAX)];
    } else if([gesture isEqualToString:@"triangleFinished"]) {
    
        [brushSizeViewController quit];
    
    // ---------------------------- push -------------------------------------

    } else if([gesture isEqualToString:@"push"]) {
        
        [self quitCurrentAction];
    }
    
}

- (void) updateBrush 
{
    [self.pencilCursor adjustBrushSize:[brushSizeViewController getBrushSize] andColor:[brushColorViewController getCurrentColor]];
}



- (CGPoint) clipCursorPoint:(CGPoint) point {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if(point.x < 0) point.x = 0;
    else if(point.x > screenSize.height) point.x = screenSize.height;
    else if(point.y > screenSize.width) point.y = screenSize.width;
    else if(point.y < 0) point.y = 0;
    
    return point;
}


- (void) hideCursor
{
    [self.pencilCursor.view setAlpha:0.0f];
}
- (void) showCursor 
{
    [self.pencilCursor.view setAlpha:1.0f];
}


- (void) quitCurrentAction 
{
    if(erasePopupVisible) 
        [self hideErasePopup];
    else if(currentPopup!=variousStuffViewController 
            && appDelegate.configurationsViewController.pushAsConfirm.on) 
        [currentPopup quit];
    
}
@end
