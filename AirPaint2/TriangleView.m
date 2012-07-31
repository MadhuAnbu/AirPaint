//
//  TriangleView.m
//  AirPaint2
//
//  Created by Philipp Sessler on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriangleView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TriangleView

- (id)initWithFrame:(CGRect)frame andBrushColor:(UIColor *) color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        brushColor = color;
        
        emptyTriangelView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.65, frame.size.height)];
        [self addSubview:emptyTriangelView];
        
        progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, emptyTriangelView.frame.size.width, emptyTriangelView.frame.size.height)];
        progressImageView.image = [UIImage imageWithData:nil];
        [self addSubview:progressImageView];
    
        brushView = [[UIImageView alloc] initWithFrame:
                     CGRectMake(self.frame.size.width - self.frame.size.height, 
                                0, 
                                self.frame.size.height,
                                self.frame.size.height)];
        brushView.image = [UIImage imageWithData:nil];
        [self addSubview:brushView];
        
        
        
    }
    return self;
}

-(void)drawEmptyTriangle
{
    UIGraphicsBeginImageContext(emptyTriangelView.frame.size);
    [emptyTriangelView.image drawInRect:CGRectMake(0, 0, emptyTriangelView.frame.size.width, emptyTriangelView.frame.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
  
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 
                         CGRectGetMinX(emptyTriangelView.frame), 
                         CGRectGetMaxY(emptyTriangelView.frame)); // bottom left
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 
                            CGRectGetMaxX(emptyTriangelView.frame), 
                            CGRectGetMinY(emptyTriangelView.frame)); // top right
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 
                            CGRectGetMaxX(emptyTriangelView.frame), 
                            CGRectGetMaxY(emptyTriangelView.frame)); // bottom right
    
    CGContextClosePath(UIGraphicsGetCurrentContext());
    CGContextStrokePath(UIGraphicsGetCurrentContext());

    emptyTriangelView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) drawProgress {
        
    UIGraphicsBeginImageContext(progressImageView.frame.size);
    
    progressImageView.image = [UIImage imageWithData:nil];
    
    CGContextFlush(UIGraphicsGetCurrentContext());
    
    [progressImageView.image drawInRect:CGRectMake(0, 0, progressImageView.frame.size.width, progressImageView.frame.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 
                         0, 
                         progressImageView.frame.size.height);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 
                            progressImageView.frame.size.width * progress, 
                            progressImageView.frame.size.height);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 
                            progressImageView.frame.size.width * progress, 
                            progressImageView.frame.size.height 
                                - progressImageView.frame.size.height *progress);
    CGContextClosePath(UIGraphicsGetCurrentContext());
    
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    progressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

- (void) drawBrush {
    
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    [brushColor getRed:&red green:&green blue:&blue alpha:nil];
    
    float diameter = emptyTriangelView.frame.size.height * progress;
    
    UIGraphicsBeginImageContext(brushView.frame.size);
    
    brushView.image = [UIImage imageWithData:nil];
    
    CGContextFlush(UIGraphicsGetCurrentContext());
    
    [brushView.image drawInRect:CGRectMake(0,0,brushView.frame.size.width, brushView.frame.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), diameter);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 
                         brushView.frame.size.width/2,
                         brushView.frame.size.height/2);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),
                            brushView.frame.size.width/2,
                            brushView.frame.size.height/2);
    CGContextClosePath(UIGraphicsGetCurrentContext());
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    brushView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) setProgress:(float)p {

    progress = p;
   
    [self drawEmptyTriangle];
    [self drawProgress];
    [self drawBrush];
}

- (void) setBrushColor:(UIColor*) color {
    brushColor = color;
    [self drawBrush];
}

@end
