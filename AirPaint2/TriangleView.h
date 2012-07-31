//
//  TriangleView.h
//  AirPaint2
//
//  Created by Philipp Sessler on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriangleView : UIView {
    float progress;
    
    UIImageView *progressImageView;
    UIImageView *emptyTriangelView;
    UIImageView *brushView;
    
    UIColor *brushColor;

}
- (id)initWithFrame:(CGRect)frame andBrushColor:(UIColor *) color;
- (void) setProgress:(float)p;
- (void) setBrushColor:(UIColor*) color;

@end
