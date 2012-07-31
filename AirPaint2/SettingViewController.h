//
//  SettingViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CanvasViewController;

@interface SettingViewController : UIViewController {
    CanvasViewController *canvasViewController;
}

@property (retain, atomic) UIImage *imageIconForSidebar;
@property (nonatomic, retain) UILabel *label;

- (id)initWithIcon:(UIImage *) imageIcon andCanvasViwController:(CanvasViewController*) viewController;

- (void) quit;
        
@end
