//
//  UIImage+scale.h
//  AirPaint2
//
//  Created by Philipp Sessler on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (utils)

-(UIImage*)scaleToSize:(CGSize)size;
- (UIImage * ) mergeWithImage:  (UIImage *) imageB
                     strength: (float) strength;
- (UIImage*) rotate:(int) degrees;
- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

@end