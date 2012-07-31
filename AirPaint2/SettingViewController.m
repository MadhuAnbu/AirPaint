//
//  SettingViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "Configurations.h"

@implementation SettingViewController

@synthesize imageIconForSidebar, label;

- (id)initWithIcon:(UIImage *) imageIcon andCanvasViwController:(CanvasViewController*) viewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.imageIconForSidebar = imageIcon;
        
        canvasViewController = viewController;

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

- (void)viewDidLoad 
{
//   self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SETTINGS_POPUP_WIDTH, 100)];
//   [self.label setBackgroundColor:[UIColor clearColor]];
    
//    [self.view addSubview:self.label];
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


- (void) quit {
    NSLog(@"quit");
}

@end
