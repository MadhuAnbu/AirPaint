//
//  ConfigurationsViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigurationsViewController.h"
#import "Configurations.h"

@implementation ConfigurationsViewController

@synthesize studyID, additionalInfo;
@synthesize useCircelGestureForColor, pushAsConfirm, numberOfChoicesColor, numberOfChoicesVariouStuff, useSliderGestureForBrushSize;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];
       
        self.studyID = @"mee";
        self.additionalInfo = @"tryLine";
        
        // switch: circle gesture for brush color
        self.useCircelGestureForColor = [[UISwitch alloc] initWithFrame:CGRectMake(10, 40, 0, 0)];
        [self.useCircelGestureForColor setOn:YES];

        // switch: useSliderGestureForBrushSize
        self.useSliderGestureForBrushSize = [[UISwitch alloc] initWithFrame:CGRectMake(10, 80, 0, 0)];
        [self.useSliderGestureForBrushSize setOn:YES];

        // switch: enable push as confirmation
        self.pushAsConfirm = [[UISwitch alloc] initWithFrame:CGRectMake(10, 120, 0, 0)];
        [self.pushAsConfirm setOn:YES];

        // textfield:  number of color choices
        self.numberOfChoicesColor = [[UITextField alloc] initWithFrame:CGRectMake(10, 160, 50, 30.0)];
        self.numberOfChoicesColor.borderStyle = UITextBorderStyleRoundedRect;
        self.numberOfChoicesColor.text = [NSString stringWithFormat:@"%i",NUMBER_OF_CHOICES_COLOR_INITIAL];
        self.numberOfChoicesColor.delegate = self;
        
        
        // textfield:  number of various stuff choices
        self.numberOfChoicesVariouStuff = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 50, 30.0)];
        self.numberOfChoicesVariouStuff.borderStyle = UITextBorderStyleRoundedRect;
        self.numberOfChoicesVariouStuff.text = [NSString stringWithFormat:@"%i", NUMBER_OF_CHOICES_VARIOUSSTUFF_INITIAL];
        self.numberOfChoicesVariouStuff.delegate = self;
        
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor whiteColor]];    

    
    // ---- tite ----
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    titleLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0,10,[UIScreen mainScreen].bounds.size.height,15)];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    titleLabel.text = [NSString stringWithFormat:@"Configurations (StudyID: %@)", studyID];
    [self.view addSubview:titleLabel];

    
    // ---- circle gesture -----
    [self.view addSubview:useCircelGestureForColor];    
    UILabel *labelForUseCircelGestureForColor = [[UILabel alloc] initWithFrame:CGRectMake(120, 40, 300, 27)];
    labelForUseCircelGestureForColor.text = @"Use circle gesture for brush color";
    [self.view addSubview:labelForUseCircelGestureForColor];
    
    // ---- slider gesture for brushsize -----
    [self.view addSubview:useSliderGestureForBrushSize];    
    UILabel *labelForUseSliderGestureForBrushSize = [[UILabel alloc] initWithFrame:CGRectMake(120, 80, 300, 27)];
    labelForUseSliderGestureForBrushSize.text = @"Use slider gesture for brush size";
    [self.view addSubview:labelForUseSliderGestureForBrushSize];
    
    
    // ----- push as confirm -----
    [self.view addSubview:pushAsConfirm];    
    UILabel *labelForPushAsConfirm = [[UILabel alloc] initWithFrame:CGRectMake(120, 120, 300, 27)];
    labelForPushAsConfirm.text = @"Enable push gesture as confirm";
    [self.view addSubview:labelForPushAsConfirm];

    
    // ----- number of choices color
    [self.view addSubview:self.numberOfChoicesColor];
    UILabel *labelForNumberOfChoicesColor = [[UILabel alloc] initWithFrame:CGRectMake(120, 160, 300, 27)];
    labelForNumberOfChoicesColor.text = @"Number of color choices";
    [self.view addSubview:labelForNumberOfChoicesColor];
   
    
    // ----- number of choices various stuff
    [self.view addSubview:self.numberOfChoicesVariouStuff];
    UILabel *labelForNumberOfChoicesVariousStuff = [[UILabel alloc] initWithFrame:CGRectMake(120, 200, 300, 27)];
    labelForNumberOfChoicesVariousStuff.text = @"Number of various stuff choices";
    [self.view addSubview:labelForNumberOfChoicesVariousStuff];
    
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = [touch tapCount];
    switch (tapCount) {
        case 3:
            [appDelegate.navigationController popViewControllerAnimated:YES];
            break;
        default :
            break;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return NO;
}

@end
