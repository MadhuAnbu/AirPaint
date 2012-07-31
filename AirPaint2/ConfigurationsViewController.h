//
//  ConfigurationsViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ConfigurationsViewController : UIViewController <UITextFieldDelegate> {
    AppDelegate *appDelegate;
    
    bool keyboardIsShown;
}

@property (retain, atomic) NSString *studyID;
@property (retain, atomic) NSString *additionalInfo;

@property (retain, atomic) UISwitch *useCircelGestureForColor;
@property (retain, atomic) UISwitch *useSliderGestureForBrushSize;
@property (retain, atomic) UISwitch *pushAsConfirm;
@property (retain, atomic) UITextField *numberOfChoicesColor;
@property (retain, atomic) UITextField *numberOfChoicesVariouStuff;

- (id)init;

@end
