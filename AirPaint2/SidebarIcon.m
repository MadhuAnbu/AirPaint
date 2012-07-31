//
//  SidebarIcon.m
//  AirPaint2
//
//  Created by Philipp Sessler on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SidebarIcon.h"
#import "CanvasViewController.h"
#import "BrushSizeViewController.h"

@implementation SidebarIcon

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier canvasViewController: (CanvasViewController*) canvas
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        canvasViewController = canvas;
        sidebarViewController = [canvasViewController sidebarViewController];
      
        buttonImage_normal = [UIImage imageNamed:@"button.png"];
        buttonImage_highlighted = [UIImage imageNamed:@"button_highlighted.png"];
        
        button = [[UIImageView alloc ] initWithImage:buttonImage_normal];
        [button setFrame:CGRectMake(2, 25, buttonImage_normal.size.width, buttonImage_normal.size.height)];

        popupVisible = NO;
        
        selectedBgImage = [UIImage imageNamed:@"sidebar_selected.png"];
        selectedBgImageView = [[UIImageView alloc ] initWithImage:selectedBgImage];
        [self addSubview:selectedBgImageView];
        [self sendSubviewToBack:selectedBgImageView];
        [selectedBgImageView setAlpha:0.0];
        
        //self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    return self;
}

- (void) setSettingViewController:(SettingViewController*) view 
{
    settingViewController = view;
    self.imageView.image = [settingViewController imageIconForSidebar];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
     
    [super setSelected:selected animated:animated];
     
    if (selected) {
 
        [selectedBgImageView setAlpha:1.0];

        if(!popupVisible) {
            
            [self addButton];

            
            if(![[canvasViewController currentPopup] 
                        isMemberOfClass:[[canvasViewController brushSizeViewController] class] ]) {

                [NSTimer scheduledTimerWithTimeInterval:0.5 target:canvasViewController selector:@selector(hideSidebar:) userInfo:nil repeats:NO];
            }
            
        }
        else {

            [settingViewController quit];
            
            [self removeButton];
            
            [self setSelected:NO];

            [canvasViewController hideSidebar:self];
        }    
        
    } else {
     
        [selectedBgImageView setAlpha:0.0];

      //  NSLog(@"not selected -> remove");
        self.imageView.image = [settingViewController imageIconForSidebar];
    }
    
         
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
    if([sidebarViewController selectedSidebarIcon]!=nil 
       && [sidebarViewController selectedSidebarIcon] != self) {
        return ;
    }
    
    [super setHighlighted:highlighted animated:animated];
      
    
    if(highlighted) {
        if(popupVisible) {
            [selectedBgImageView setAlpha:1.0];
            
            [self.imageView setImage:buttonImage_highlighted];
            [sidebarViewController hide];
        } else {
            [selectedBgImageView setAlpha:0.0];
            
            [self.imageView setImage:buttonImage_highlighted];

        }
    } 
    
}

- (void) addButton {
    
        button.image = buttonImage_normal;
        [self.imageView setImage:buttonImage_normal];
        popupVisible = YES;
        [canvasViewController showPopup:settingViewController];
    
}

- (void) removeButton {
        
    if(popupVisible) {
        [self.imageView setImage: [settingViewController imageIconForSidebar]];
        popupVisible = NO;
        [canvasViewController hidePopup];
    }
    
}
@end
