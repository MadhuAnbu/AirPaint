//
//  StartViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class AppDelegate;

@interface StartViewController : UIViewController {
    AppDelegate *appDelegate;
}

@property (nonatomic, retain) UILabel *label;

@end
