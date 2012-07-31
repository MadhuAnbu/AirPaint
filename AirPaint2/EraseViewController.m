//
//  EraseViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EraseViewController.h"

@implementation EraseViewController

@synthesize slider, eraseToIndex;

- (id) initWithCanvasWithController:(CanvasViewController*) viewController 
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];

        canvasViewController = viewController;
        canvas = [canvasViewController canvas];
        
        lastValue = -10;        // just any value that doesn't occur
    }
    
    eraseToIndex = [[canvasViewController canvasHolder] totalLinesCount] - 1;
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
 
    // autoresize mask  - needed for landscape orientation & rotation
    [self.view setAutoresizingMask: UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
    [self.view setAutoresizesSubviews:YES];
    
    // background image (frame)
    backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"erase.png"]];
    
    self.view.frame = CGRectMake(
                                 (self.view.frame.size.height - backgroundImageView.frame.size.width)/2,
                                 (self.view.frame.size.width - backgroundImageView.frame.size.height) - 25 , 
                                 backgroundImageView.frame.size.width, 
                                 backgroundImageView.frame.size.height);    
    
    [self.view addSubview:backgroundImageView];
    
    // slider
    float sliderWidth = self.view.frame.size.width * 0.9;
    float sliderHeight = 30;
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(
                            (self.view.frame.size.width - sliderWidth)/2, 
                            (self.view.frame.size.height - sliderHeight) - 15, 
                            sliderWidth, 30)];
    [slider setContinuous:NO];
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];    
    [self.slider setMaximumValue:[[canvasViewController canvasHolder] totalLinesCount]-1];
    [self.slider setMinimumValue:-1];
    [self.slider setValue: [self.slider maximumValue]];
    [self.view addSubview:self.slider];
    
    self.view.alpha = 0.6;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    canvasViewController.eraseIsActive = YES;
    
    FLog(@"Erease start");
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    canvasViewController.eraseIsActive = NO;
    FLog(@"Erease finished");

}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(IBAction)sliderChanged:(id)sender {
    
    int progressAsInt = (int) round(self.slider.value);
    
    printf("slider value: %i\n", progressAsInt);
    if(progressAsInt != lastValue) {
        lastValue = progressAsInt;
        [[canvasViewController canvasHolder] eraseToIndex:progressAsInt finished:NO];
    }
    
}

- (void) setSliderValue:(int) value {
    [self.slider setValue:value];
    [self.slider sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
