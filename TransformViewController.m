//
//  TanformViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 01.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransformViewController.h"

@implementation TransformViewController

- (id)initWithCanvasViewController:(CanvasViewController*) viewController
{
    self = [super initWithIcon:[UIImage imageNamed:@"scale_icon.png"] andCanvasViwController:viewController];
    if (self) {
        appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
    }
    
    canvasViewController.transformViewController = self;
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
    backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transformation.png"]];
    
    self.view.frame = CGRectMake(
                                 (self.view.frame.size.height - backgroundImageView.frame.size.width)/2,
                                 (self.view.frame.size.width - backgroundImageView.frame.size.height) - 25 , 
                                 backgroundImageView.frame.size.width, 
                                 backgroundImageView.frame.size.height);    
    
    UIImage *cancelImage_off = [UIImage imageNamed:@"cancel.png"];
    UIImage *cancelImage_on = [UIImage imageNamed:@"cancel_on.png"];

    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(120, 45, cancelImage_off.size.width, cancelImage_off.size.height);
    [cancelButton setImage:cancelImage_off forState:UIControlStateNormal];
    [cancelButton setImage:cancelImage_on forState:UIControlStateHighlighted];
    [cancelButton addTarget:self 
                     action:@selector(cancel) 
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backgroundImageView];
    [self.view addSubview:cancelButton];
    
    backgroundImageView.alpha = 0.6;
    cancelButton.alpha = 0.6;
    
}

- (void) viewDidAppear:(BOOL)animated {
    [[appDelegate shoeConnection] sendMessage:@"transformStart" withAck:YES];
    [[canvasViewController canvasHolder] startTransformation];
    [canvasViewController hideCursor];
    FLog(@"Transformation start");

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


- (void) cancel 
{
    [appDelegate.canvasViewController.canvasHolder translation:CGPointMake(0, 0) withScale:0.0 doBreak:NO finished:NO cancel:YES];
    [[appDelegate shoeConnection]  sendMessage:@"backToNormalTracking" withAck:YES];
    [canvasViewController showCursor];
    [canvasViewController.sidebarViewController deselectMenuPoint];

}

- (void) quit 
{
    
    [[appDelegate shoeConnection]  sendMessage:@"backToNormalTracking" withAck:YES];
    [[canvasViewController canvasHolder] saveTransformation];
    [canvasViewController showCursor];
    FLog(@"Transformation finished");

}

@end
