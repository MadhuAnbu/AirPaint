//
//  ViewController.m
//  ColorPickerTest
//
//  Created by Philipp Sessler on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BrushColorViewController.h"

#define PIE_SIZE 170
#define degreesToRadians(x) (M_PI * (x) / 180.0)

@implementation BrushColorViewController

- (id)initWithCanvasViewController:(CanvasViewController*) viewController {
    
    self = [super initWithIcon:[UIImage imageNamed:@"color_icon.png"] andCanvasViwController:viewController];

    if (self) {
        
        appDelegate = [[UIApplication sharedApplication] delegate];
    
        // background image (frame)
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brushColor.png"]];

        colors = [NSArray arrayWithObjects:
                  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],          // black
                  [UIColor colorWithRed:0.25 green:0.11 blue:0.03 alpha:1.0],       // brown
                  [UIColor colorWithRed:0.72 green:0.81 blue:0.05 alpha:1.0],       // yewllow-green                              
                  [UIColor colorWithRed:0.18 green:0.56 blue:0.16 alpha:1.0],       // green                              
                  [UIColor colorWithRed:0 green:0.58 blue:0.49 alpha:1.0],          // green2
                  [UIColor colorWithRed:0.01 green:0.38 blue:0.38 alpha:1.0],       // blue-green
                  [UIColor colorWithRed:0.01 green:0.45 blue:0.65 alpha:1.0],       // blue2
                  [UIColor colorWithRed:0.04 green:0.31 blue:0.63 alpha:1.0],       // blue
                  [UIColor colorWithRed:0.16 green:0 blue:0.48 alpha:1.0],          // purple
                  [UIColor colorWithRed:0.51 green:0 blue:0.40 alpha:1.0],          // pink
                  [UIColor colorWithRed:0.78 green:0 blue:0.11 alpha:1.0],          // red  
                  [UIColor colorWithRed:1.0  green:0.3 blue:0 alpha:1.0],           // orange
                  [UIColor colorWithRed:1.0 green:0.8 blue:0 alpha:1.0],            // yellow
                  nil];
        
        currentColor = [colors objectAtIndex:0];
        
        int numberOfColors = MIN([colors count], [appDelegate.configurationsViewController.numberOfChoicesColor.text intValue]);
        
        circle = [[CDCircle alloc] initWithFrame:CGRectMake(
                                            (backgroundImageView.frame.size.width - PIE_SIZE)/2, 
                                            (backgroundImageView.frame.size.height - PIE_SIZE + 25)/2,
                                            PIE_SIZE, PIE_SIZE) 
                                numberOfSegments:numberOfColors ringWidth:60.f];
        overlay = [[CDCircleOverlayView alloc] initWithCircle:circle];

        circle.dataSource = self;
        circle.delegate = self;
       
        circle.overlayView.overlayThumb.arcColor = [UIColor clearColor];

        if(appDelegate.configurationsViewController.useCircelGestureForColor) {
            
            // arrowImageView
            arrowImageViewHolder = [[UIView alloc] initWithFrame:circle.frame];
         //   arrowImageViewHolder.layer.borderColor = [UIColor redColor].CGColor;
         //   arrowImageViewHolder.layer.borderWidth = 1.0f;
       
            UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowUp.png"]];
          
            CGRect rect = arrowImg.frame;
            rect.origin = CGPointMake(arrowImageViewHolder.frame.size.width/2 - rect.size.width/2, 0);
            arrowImg.frame = rect;
            [arrowImageViewHolder addSubview:arrowImg];
            
            [self.view addSubview:arrowImageViewHolder];
            
            oldAngle = 0;
            
        } else {
            // arrow image on top of circle
            
            UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowUp.png"]];
            
            CGRect frame = arrowImg.frame;
            frame.origin = CGPointMake(7, 5);
            arrowImg.frame = frame;
            
            [circle.overlayView.overlayThumb addSubview:arrowImg];
        }
         
        int i = 0;
        for (CDCircleThumb *thumb in circle.thumbs) {
            
            [thumb.iconView setHighlitedIconColor:[UIColor redColor]];
            thumb.separatorColor = [UIColor blackColor];
            thumb.separatorStyle = CDCircleThumbsSeparatorNone;
            thumb.gradientFill = NO;
            thumb.arcColor = [colors objectAtIndex:i];
            thumb.gradientColors = [NSArray arrayWithObjects:(id) [UIColor blackColor].CGColor, (id) [UIColor yellowColor].CGColor, (id) [UIColor blueColor].CGColor, nil];
            
            i++;
        }

        
        
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
    
    self.view.frame = CGRectMake(
                            (self.view.frame.size.height - backgroundImageView.frame.size.width)/2,
                            (self.view.frame.size.width - backgroundImageView.frame.size.height)/2 , 
                            backgroundImageView.frame.size.width, 
                            backgroundImageView.frame.size.height);    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:backgroundImageView];
    [self.view addSubview:circle];
    [self.view addSubview:overlay];
    

    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down.png"]];
    CGRect frame = arrowImageView.frame;
    frame.origin = CGPointMake(backgroundImageView.frame.size.width - frame.size.width - 30, backgroundImageView.frame.size.height - frame.size.height - 40);
    arrowImageView.frame = frame;
    [self.view addSubview:arrowImageView];
   
    arrowDown = YES;
    arrowImageView.alpha = 0.0;
    
    [circle selectSegment:0 animated:NO];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewDidAppear:(BOOL)animated {
    
    canvasViewController.brushColorIsActive = YES;
    if(appDelegate.configurationsViewController.useCircelGestureForColor.on) {
        [[appDelegate shoeConnection] sendMessage:@"trackCircleSegmentStart" withAck:YES];
    } else {
        [[appDelegate shoeConnection] sendMessage:@"trackSwipeStart" withAck:YES];
    }
    [canvasViewController hideCursor];
    FLog(@"Color start");

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Circle delegate & data source

-(void) circle:(CDCircle *)circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb {
    
    currentColor = [colors objectAtIndex:segment];
}

-(UIImage *) circle:(CDCircle *)circle iconForThumbAtRow:(NSInteger)row {
    return nil;
    //   return [UIImage imageNamed:@"icon_arrow_up.png"];
}


- (void) nextColor {

    if(arrowDown) {
        arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        arrowDown = NO;
    }
    
    arrowImageView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        arrowImageView.alpha = 0.7;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            arrowImageView.alpha = 0.0;
        } completion:^(BOOL finished){
            
        }];   
    }];    

    
    [circle nextSegment];
}

- (void) previousColor {
    
    
    if(!arrowDown) {
        arrowImageView.transform = CGAffineTransformIdentity;
        arrowDown = YES;
    }
    
    
    arrowImageView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        arrowImageView.alpha = 0.7;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            arrowImageView.alpha = 0.0;
        } completion:^(BOOL finished){
            
        }];   
    }];    
    

    
    [circle previousSegment];
}

- (Color) getCurrentColor {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    [currentColor getRed:&red green:&green blue:&blue alpha:nil];
    Color col = {red, green, blue, 1.0};
    
    return col;
}

- (UIColor*) getCurrentUIColor {
    return currentColor;
}

- (void) quit {
    
    
    [[appDelegate shoeConnection] sendMessage:@"backToNormalTracking" withAck:YES];
    [canvasViewController.sidebarViewController deselectMenuPoint];
    canvasViewController.brushColorIsActive = NO;
    [canvasViewController updateBrush];
    [canvasViewController hidePopup];
    [canvasViewController hideSidebar:self];
    [canvasViewController showCursor];
    FLog(@"Color finished");

}


- (void) selectSegmentWithAngle:(int) angle 
{

    int segmentWidth = 360 / [colors count];
    int segmentNumber = angle / segmentWidth;
        
    float angleToRotate = degreesToRadians(segmentNumber*segmentWidth);
    
    if(angleToRotate == oldAngle) return;
    
    oldAngle = angleToRotate;
    
    arrowImageViewHolder.transform = CGAffineTransformIdentity;
    
    // if(steps > 0) isAnimating = YES;
    [UIView animateWithDuration:0.f 
                          delay:0.f 
                        options:UIViewAnimationCurveEaseOut 
                     animations:^{
                         
                         [arrowImageViewHolder setTransform:CGAffineTransformRotate(arrowImageViewHolder.transform, angleToRotate)];
                         
                     } completion:^(BOOL finished) {
                         
                         
                     }];  
    
    // if(segmentNumber < [colors count])
    
    if(segmentNumber== [colors count])
        segmentNumber = 0;

    currentColor = [colors objectAtIndex:segmentNumber];

    
}

- (void) setCurrentColor:(UIColor*) col 
{
    currentColor = col;
}


@end
