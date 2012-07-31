//
//  BrushSizeViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrushSizeViewController.h"
#import "Configurations.h"

@implementation BrushSizeViewController

@synthesize slider;

- (id)initWithCanvasViewController:(CanvasViewController*) viewController
{
    self = [super initWithIcon:[UIImage imageNamed:@"brush_icon.png"] andCanvasViwController:viewController];
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];
        [canvasViewController setBrushSizeViewController:self];
        brushSize = BRUSH_SIZE_INITIAL;
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

- (void)loadView
{
    [super loadView];
     
    // background image (frame)
    backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brushSize.png"]];
    
    self.view.frame = CGRectMake(
                        (self.view.frame.size.height - backgroundImageView.frame.size.width)/2,
                        (self.view.frame.size.width - backgroundImageView.frame.size.height)/2 , 
                        backgroundImageView.frame.size.width, 
                        backgroundImageView.frame.size.height);    

    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backgroundImageView];
    
    triangle = [[TriangleView alloc] initWithFrame:CGRectMake(35, 70, 200, BRUSH_SIZE_MAX) andBrushColor:[[canvasViewController brushColorViewController] getCurrentUIColor]];
    [triangle setProgress: (BRUSH_SIZE_INITIAL/BRUSH_SIZE_MAX)];
    [self.view addSubview:triangle];
    
    if(appDelegate.configurationsViewController.useSliderGestureForBrushSize.on) {
        NSLog(@"slider loaded");
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 110, self.view.frame.size.width * 0.8, 25)];
        [self.slider setContinuous:NO];
        [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];    
        [self.slider setMaximumValue:BRUSH_SIZE_MAX];
        [self.slider setMinimumValue:BRUSH_SIZE_MIN];
        [self.slider setValue: BRUSH_SIZE_INITIAL];
        [self.view addSubview:self.slider];

    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    canvasViewController.brushSizeIsActive = YES;
    
    [triangle setBrushColor:[[canvasViewController brushColorViewController] getCurrentUIColor]];
    
    if(appDelegate.configurationsViewController.useSliderGestureForBrushSize.on) 
        [[appDelegate shoeConnection] sendMessage:@"trackSliderStart" withAck:YES];
    else 
        [[appDelegate shoeConnection] sendMessage:@"triangleStart" withAck:YES];
    
    [canvasViewController updateBrush];
    [canvasViewController hideCursor];
    FLog(@"Size start");

}


- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void) setBrushSize:(float) size 
{
    if(size < BRUSH_SIZE_MIN) 
        size = BRUSH_SIZE_MIN;
    
    brushSize = size;
    [triangle setProgress:(brushSize/BRUSH_SIZE_MAX)];
}

- (float) getBrushSize 
{
    return brushSize;
}

- (void) progressSliderGestureValue:(int) value
{
    int steps = SLIDER_MAX_VALUE / (BRUSH_SIZE_MAX - BRUSH_SIZE_MIN);
    int currentValue = value / steps;
    [self setSliderValue:currentValue];
    
    NSLog(@"steps: %i currentValue:%i", steps, currentValue);
    
}

- (void) setSliderValue:(int) value {
    [self.slider setValue:(self.slider.value + value)];
    [self.slider sendActionsForControlEvents:UIControlEventValueChanged];
}


- (IBAction)sliderChanged:(id)sender 
{
    [self setBrushSize:self.slider.value];
}

- (void) quit {
    [[appDelegate shoeConnection] sendMessage:@"backToNormalTracking" withAck:YES];
    
    [canvasViewController updateBrush];
    [canvasViewController hidePopup];
    [canvasViewController hideSidebar:self];
    [canvasViewController showCursor];
    
    canvasViewController.brushSizeIsActive = NO;
    FLog(@"Size finished");

    
}
@end
