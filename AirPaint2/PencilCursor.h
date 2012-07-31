//
//  PencilCursor.h
//  AirPaint2
//
//  Created by Philipp Sessler on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@interface PencilCursor : UIViewController {

    UIImage *originalPencilImage;
    
    UIImage *pencilImage;
    
    UIImageView *pencilImageView;
    UIImageView *brushPointView;

    CGPoint lastPoint;
    
    CGRect myFrame;
    
    float currentBrushSize;
    
}

- (id)init;

- (void) adjustBrushSize:(float) brushSize andColor:(Color) col;
- (CGSize) computeSizeForPencilImageDependingOnBrushSize:(float) size;
- (void) movePencilCursorTo:(CGPoint) point;
- (void) movePencilCursorTo:(CGPoint) point traverse:(BOOL) traverse;

@end
