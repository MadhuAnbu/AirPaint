//
//  MenuPoint.h
//  AirPaint2
//
//  Created by Philipp Sessler on 07.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface MenuPoint : UITableViewCell {
    UIImageView *backgroundImageView;
    
    UIImage *bgImageSelected;
    UIImage *bgImageNotSelected;
    
}

@property (retain, atomic) UILabel *numberLabel;
@property (retain, atomic) UILabel *menuText;
@property (strong, nonatomic) DACircularProgressView *progress;

@end
