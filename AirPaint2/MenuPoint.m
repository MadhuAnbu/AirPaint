//
//  MenuPoint.m
//  AirPaint2
//
//  Created by Philipp Sessler on 07.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuPoint.h"
#import <QuartzCore/QuartzCore.h>

@implementation MenuPoint

@synthesize numberLabel, menuText, progress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        bgImageSelected = [UIImage imageNamed:@"menuPoint_selected.png"];
        bgImageNotSelected = [UIImage imageNamed:@"menuPoint_not_selected.png"];

        self.frame = CGRectMake(0, 0, bgImageSelected.size.width, bgImageSelected.size.height);
        backgroundImageView = [[UIImageView alloc] initWithImage:bgImageNotSelected];;
        [self addSubview:backgroundImageView];
        
        numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, 30, 30)];
        [numberLabel setBackgroundColor:[UIColor clearColor]];
        [numberLabel setTextAlignment:UITextAlignmentCenter];
        [self addSubview:numberLabel];
        
        menuText = [[UILabel alloc] initWithFrame:CGRectMake(60,8, 200, 30)];
        [menuText setBackgroundColor:[UIColor clearColor]];
        [self addSubview:menuText];
    
        self.progress = [[DACircularProgressView alloc] initWithFrame:CGRectMake(235, 10, 30, 30)];
        self.progress.alpha = 0.0;
        
        [self addSubview:progress];
        
    }
    
    return self;
}


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    if(selected) {
    
        
        [backgroundImageView setImage:bgImageSelected];
        self.progress.alpha = 1.0;
                             
    } else {
        
        [backgroundImageView setImage:bgImageNotSelected];

        self.progress.alpha = 0.0;
        self.progress.progress = 0.0;
    }
}

@end
