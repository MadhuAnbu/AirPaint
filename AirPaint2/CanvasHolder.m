//
//  CanvasHolder.m
//  AirPaint2
//
//  Created by Philipp Sessler on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CanvasHolder.h"
#import "UIView+Screenshot.h"
#import "UIImage+utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation CanvasHolder

@synthesize currentBackgroundLayerImageView;

- (id)initWithCanvas:(Canvas*) _canvas
{
    self = [super initWithFrame:_canvas.frame];
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];
        canvas = _canvas;
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        currentBackgroundLayerImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [currentBackgroundLayerImageView setBackgroundColor:[UIColor whiteColor]];

        
        transformation_toAdd_delta = CGPointMake(0, 0);
        transformation_toAdd_scale = 0.0;

        
        [self addSubview:currentBackgroundLayerImageView];
        [currentBackgroundLayerImageView addSubview:canvas];
        
        transformationHasJustStarted = YES;
        
        backgroundImageLayers = [NSMutableArray array];
        
        canProcessCommands = YES;
        
        // acitivity view
        activity = 	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.hidesWhenStopped = YES;
        activity.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        activity.alpha = 0.0;
        [self addSubview:activity];
        
    }
    return self;
}

- (void) translation:(CGPoint) delta withScale: (float) scale doBreak:(bool) doBreak finished:(BOOL)finished cancel:(bool)cancel
{
    
    if(!canProcessCommands)
        return ;

    if(cancel) {
        canProcessCommands = NO;        
        canProcessCommands = YES;
            
        canvas.alpha = 1.0;
        transformationHasJustStarted = YES;

        currentBackgroundLayerImageView.transform = CGAffineTransformIdentity;

        if(backgroundImageLayers.count != 0) {
            currentBackgroundLayerImageView = [backgroundImageLayers objectAtIndex:backgroundImageLayers.count -1];
        }
        
        transformation_toAdd_delta = CGPointMake(0, 0);
        transformation_toAdd_scale = 0.0;
        
        [[appDelegate canvasViewController] transformViewController].view.alpha = 0.0;

        return ;
    }
    delta.x += transformation_toAdd_delta.x;
    delta.y += transformation_toAdd_delta.y;
    scale += transformation_toAdd_scale;
 
    transformationLastDelta = delta;
    transformationLastScale = scale;
    
    if(doBreak) {
        transformation_toAdd_delta.x += delta.x;
        transformation_toAdd_delta.y += delta.y;
        transformation_toAdd_scale += scale - 1; 
    }

    CGAffineTransform translation = CGAffineTransformMakeTranslation(delta.x, delta.y);
    CGAffineTransform scaling = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform transformation = CGAffineTransformConcat(translation, scaling);
  
    if(transformationHasJustStarted) {
      
        canProcessCommands = NO;
        activity.alpha = 1.0;
        [[appDelegate canvasViewController] transformViewController].view.alpha = 0.0;
        timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(activityTimer) userInfo:nil repeats:YES];
        
        [currentBackgroundLayerImageView setImage:[self getSnapshotImage]];
        
        [[appDelegate canvasViewController] transformViewController].view.alpha = 1.0;
        canProcessCommands = YES;
        transformationHasJustStarted = NO;
        canvas.alpha = 0.0;
        
    } else if (finished) {
        [canvas eraseToIndex:-1 finished:YES];

        [[appDelegate canvasViewController] transformViewController].view.alpha = 0.0;
        
        activity.alpha = 1.0;
        timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(activityTimer) userInfo:nil repeats:YES];
        
        tempBackground = [self getSnapshotImage];
        
        canvas.alpha = 1.0;
        transformationHasJustStarted = YES;
        currentBackgroundLayerImageView.transform = CGAffineTransformIdentity;
        currentBackgroundLayerImageView.image = tempBackground;
        transformation_toAdd_delta = CGPointMake(0, 0);
        transformation_toAdd_scale = 0.0;
        [backgroundImageLayers addObject:tempBackground];
        return ;
    }
    
    currentBackgroundLayerImageView.transform = transformation;
       
}


- (void) activityTimer
{
    if (snapshotDone) {
        [timer invalidate];
        [activity stopAnimating];
        activity.alpha = 0.0;        
    } else {
        [activity startAnimating];
    }
    
}

- (void) startTransformation 
{
    [self translation:CGPointMake(0, 0) withScale:1.0 doBreak:NO finished:NO cancel:NO];
}

- (void) saveTransformation 
{
    [self translation:transformationLastDelta withScale:transformationLastScale doBreak:NO finished:YES cancel:NO];
}

- (UIImage*) getSnapshotImage 
{    
    snapshotDone = NO;
    UIImage* snapshot_1 = [self imageRepresentation];
    UIImage* snapshot_2 = [canvas getSnapshotImage];
    UIImage *merge =  [snapshot_1 mergeWithImage:snapshot_2 strength:1.0];
    snapshotDone = YES;
    return merge;
    
}

- (void) eraseToIndex:(int) index finished:(bool) finished 
{    
        
    if([backgroundImageLayers count]!=0 && (index <= ([backgroundImageLayers count] - 1) || index==-1)) {
            
        canvas.alpha = 0.0;
        if(index==-1) {
            currentBackgroundLayerImageView.image = [UIImage imageWithData:nil];

        } else {
            currentBackgroundLayerImageView.image = [backgroundImageLayers objectAtIndex:index];
        }
        
        if(finished) {
            [canvas eraseToIndex:-1 finished:YES];
            canvas.alpha = 1.0;
            
            if(index==-1) {
                [backgroundImageLayers removeObjectsInRange:NSMakeRange(0, [backgroundImageLayers count])];
            } else {
                [backgroundImageLayers removeObjectsInRange:NSMakeRange(index+1, [backgroundImageLayers count] - index)];
            }
        }
        
    } else {
        
        canvas.alpha = 1.0;
        
        if([backgroundImageLayers count]>0)
            currentBackgroundLayerImageView.image = [backgroundImageLayers objectAtIndex:[backgroundImageLayers count]-1];
        
        [canvas eraseToIndex:(index - [backgroundImageLayers count]) 
                    finished:finished];
    }
}

- (int) totalLinesCount 
{
    return [backgroundImageLayers count] + [[canvas lines] count];
}

@end
