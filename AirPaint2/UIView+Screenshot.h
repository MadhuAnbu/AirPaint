//
//  UIView+Screenshot.h
//  AirPaint2
//
//  Created by Philipp Sessler on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)

- (UIImage*)imageRepresentation;

- (UIImage*)imageRepresentationWithScaleFactor:(float) scale;

@end