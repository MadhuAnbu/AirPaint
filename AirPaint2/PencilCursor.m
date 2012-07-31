//
//  PencilCursor.m
//  AirPaint2
//
//  Created by Philipp Sessler on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PencilCursor.h"
#import "Configurations.h"
#import "UIImage+utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation PencilCursor

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        originalPencilImage = [UIImage imageNamed:@"pencil.png"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];

    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.view setAutoresizingMask:  UIViewAutoresizingNone];    
    [self.view setAutoresizesSubviews:YES];
    
    Color col = {0.0,0.0,0.0,1.0};
    [self adjustBrushSize:BRUSH_SIZE_INITIAL andColor:col];
 
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void) adjustBrushSize:(float) brushSize andColor:(Color) newColor {
    
    currentBrushSize = brushSize;       // needed for movePencilCursorTo
    
    pencilImage = [originalPencilImage scaleToSize:[self computeSizeForPencilImageDependingOnBrushSize:brushSize]];
    
    [self.view setFrame:CGRectMake(0, 0, pencilImage.size.width + brushSize/2, pencilImage.size.height + brushSize/2)];
    
    [brushPointView removeFromSuperview];
    brushPointView = nil;
    
    
    // brush point
    brushPointView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
     
    [brushPointView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    brushPointView.image = [UIImage imageWithData:nil];
    CGContextFlush(UIGraphicsGetCurrentContext());
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSize);
        
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),newColor.r, newColor.g, newColor.b, 1.0);
   
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 
                         brushSize/2, pencilImage.size.height);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 
                            brushSize/2, pencilImage.size.height);
    CGContextClosePath(UIGraphicsGetCurrentContext());
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    brushPointView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
   

    // imageView for pencil
    [pencilImageView removeFromSuperview];
    pencilImageView = nil;
    
    pencilImageView = [[UIImageView alloc] initWithImage:pencilImage];
    [pencilImageView setFrame:CGRectMake(brushSize/2, 0, pencilImageView.frame.size.width, pencilImageView.frame.size.height)];
    
    
    myFrame = self.view.frame;
    
    
    [self.view addSubview:brushPointView];
    [self.view addSubview:pencilImageView];
    

    
}

- (void) movePencilCursorTo:(CGPoint) point {   
        
    myFrame.origin.x = point.x - currentBrushSize/2;
    myFrame.origin.y = point.y - self.view.frame.size.height + currentBrushSize/2;
    
    [self.view setFrame:myFrame];
}

- (void) movePencilCursorTo:(CGPoint) point traverse:(BOOL) traverse{   
    
    if(traverse)
        point.y = self.view.superview.frame.size.height - point.y;
    [self movePencilCursorTo:point];
}

- (CGSize) computeSizeForPencilImageDependingOnBrushSize:(float) size {
    int width = size * 30 / 7.0;
    int height = (35/30) * width;
    return CGSizeMake(width, height);
}

@end
