//
//  UIView+Screenshot.m
//  AirPaint2
//
//  Created by Philipp Sessler on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)



- (UIImage*)imageRepresentation
{
    return [self imageRepresentationWithScaleFactor:self.window.screen.scale];
}

- (UIImage*)imageRepresentationWithScaleFactor:(float) scale {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, scale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return ret;
}

@end