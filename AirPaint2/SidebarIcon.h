//
//  SidebarIcon.h
//  AirPaint2
//
//  Created by Philipp Sessler on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasViewController.h"
#import "SettingViewController.h"
#import "SidebarViewController.h"

@class SidebarViewController;

@interface SidebarIcon : UITableViewCell {
    CanvasViewController *canvasViewController;
    
    SettingViewController *settingViewController;
    
    SidebarViewController *sidebarViewController;
    
    UIImageView *button;
    UIImage *buttonImage_normal;
    UIImage *buttonImage_highlighted;
    
    bool popupVisible;
    
    UIImageView *selectedBgImageView;
    UIImage *selectedBgImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier canvasViewController: (CanvasViewController*) canvas;
- (void) setSettingViewController:(SettingViewController*) view;
- (void) removeButton;
- (void) addButton;

@end
