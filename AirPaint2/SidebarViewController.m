//
//  SidebarViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SidebarViewController.h"
#import "SettingViewController.h"
#import "SidebarIcon.h"
#import "Configurations.h"
#import "BrushSizeViewController.h"
#import "TransformViewController.h"
#import "BrushColorViewController.h"
#import "VariousStuffViewController.h"

@implementation SidebarViewController

@synthesize viewControllers;

- (id) initWitCanvas: (CanvasViewController*) canvas {
   
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
    
        canvasViewController = canvas;
        
        // initialize array with view controllers (menu points)
        [self initViewControllers]; 
        
        // autoresize mask  - needed for landscape orientation & rotation
        [self.view setAutoresizingMask: UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        // size of sidebar
        [self.view setFrame:CGRectMake(0,0, SIDEBAR_WIDTH,[UIScreen mainScreen].bounds.size.height )];
        
        // background image (whole view)
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sidebar_background.png"]]];
        
        sidebar_tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        sidebar_tableView.dataSource = self;
        sidebar_tableView.delegate = self;
        
        
        // style of table view
        sidebar_tableView.backgroundColor = [UIColor clearColor];
       	sidebar_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        sidebar_tableView.rowHeight = 70;
        
        [self.view addSubview:sidebar_tableView];
        
    }
    return self;    
    
}

- (void) initViewControllers {

    SettingViewController *brushSize = [[BrushSizeViewController alloc] initWithCanvasViewController:canvasViewController];
    
    SettingViewController *bruhsColor = [[BrushColorViewController alloc] initWithCanvasViewController:canvasViewController];
    [canvasViewController setBrushColorViewController:
                        (BrushColorViewController*)bruhsColor];
    
    SettingViewController *transform = [[TransformViewController alloc] initWithCanvasViewController:canvasViewController];

    SettingViewController *saveAndQuit = [[VariousStuffViewController alloc] initWithCanvasViewController:canvasViewController];
    
    self.viewControllers = [NSArray arrayWithObjects:brushSize, bruhsColor, transform,saveAndQuit, nil];
    
    
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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
    static NSString *MyCellIdentifier = @"MyCellIdentifier";
    
    SidebarIcon *cell = [sidebar_tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if(cell == nil) {
        cell = [[SidebarIcon alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier canvasViewController:canvasViewController] ;
    }
    
    [cell setSettingViewController: [self.viewControllers objectAtIndex:indexPath.row]];
    
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(selectedIndexPath==nil) {
        SettingViewController *controller = [self.viewControllers objectAtIndex:indexPath.row];
            
           CGRect frame = controller.view.frame;
            frame.origin.x = (canvasViewController.view.frame.size.width - frame.size.width) / 2 + SIDEBAR_PULL_WIDTH;
           controller.view.frame = frame;
        
        
         for (int i = 0; i <= [viewControllers count] ; i++) {
             SidebarIcon *sidebarIcon = (SidebarIcon *)[sidebar_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
             if(i!=indexPath.row) {
                 sidebarIcon.alpha = 0.3; 
        
             }
         }
        
        selectedIndexPath = indexPath;
        
    } else if (selectedIndexPath.row == indexPath.row){

        for (int i = 0; i <= [viewControllers count] ; i++) {
            SidebarIcon *sidebarIcon = (SidebarIcon *)[sidebar_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                sidebarIcon.alpha = 1.0; 
        }
        selectedIndexPath = nil;
    
    }
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{        
    if(selectedIndexPath==nil || indexPath.row == selectedIndexPath.row)
        return indexPath;
    else 
        return nil;
}

- (void) hide {

    NSIndexPath *selectedPopup = [sidebar_tableView indexPathForSelectedRow];
    
    if(selectedPopup != nil) {
        SettingViewController *controller = [self.viewControllers objectAtIndex:selectedPopup.row];
        
        [UIView animateWithDuration:REVEAL_ANIMATION_SPEED animations:^{
            CGRect frame = controller.view.frame;
            frame.origin.x = (canvasViewController.view.frame.size.width - frame.size.width)/2;
            controller.view.frame = frame;
        } completion:^(BOOL finished){
            
        }];    
    }
    

}

- (void) show
{

    NSIndexPath *selectedPopup = [sidebar_tableView indexPathForSelectedRow];
    if(selectedPopup != nil) {
        SettingViewController *controller = [self.viewControllers objectAtIndex:selectedPopup.row];
        [UIView animateWithDuration:REVEAL_ANIMATION_SPEED animations:^{
            CGRect frame = controller.view.frame;
            frame.origin.x = (canvasViewController.view.frame.size.width - frame.size.width)/2 
                                + SIDEBAR_PULL_WIDTH;
            controller.view.frame = frame;
        } completion:^(BOOL finished){
            
                    }];    
    }
    
}

- (SidebarIcon*) selectedSidebarIcon {
    return (SidebarIcon*)[sidebar_tableView cellForRowAtIndexPath:[sidebar_tableView indexPathForSelectedRow]];

}

- (void) deselectMenuPoint
{
    NSIndexPath *selected = [sidebar_tableView indexPathForSelectedRow];
    SidebarIcon *selectedIcon = (SidebarIcon*)[sidebar_tableView cellForRowAtIndexPath:selected];
    
    for (int i = 0; i <= [viewControllers count] ; i++) {
        SidebarIcon *sidebarIcon = (SidebarIcon *)[sidebar_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        sidebarIcon.alpha = 1.0; 
    }
    selectedIndexPath = nil;
    
    [selectedIcon setSelected:NO animated:NO];
}

@end
