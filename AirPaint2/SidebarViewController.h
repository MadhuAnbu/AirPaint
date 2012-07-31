//
//  SidebarViewController.h
//  AirPaint2
//
//  Created by Philipp Sessler on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasViewController.h"
#import "SidebarIcon.h"
@class CanvasViewController;
@class SidebarIcon;

@interface SidebarViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *sidebar_tableView;
    
    CanvasViewController *canvasViewController;
    
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, retain) NSArray *viewControllers;

- (SidebarIcon*) selectedSidebarIcon;

- (id) initWitCanvas: (CanvasViewController*) canvas;
- (void) initViewControllers;
- (void) hide;
- (void) show;

- (void) deselectMenuPoint;

@end
