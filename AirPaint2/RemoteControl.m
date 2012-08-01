//
//  RemoteControl.m
//  AirPaint2
//
//  Created by Philipp Sessler on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RemoteControl.h"
#import "Configurations.h"
#import "UIImage+utils.h"

@implementation RemoteControl

- (id) init {
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
   // portToConnect = NETWORK_REMOTECONTROL_LISTENING_PORT;
   // hostToConnect = NETWORK_REMOTECONTROL_IP;
    outstandingAck = [NSMutableDictionary dictionary];
    
    NSError *error = nil;
    if (![socket bindToPort:NETWORK_REMOTECONTROL_LISTENING_PORT error:&error])
    {
        NSLog(@"Bind error: %@", error);
    }
    
    [socket receiveWithTimeout:-1 tag:0];
    
    
    documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
    useFirstPinchPoint = NO;

    Color c = {0.64 ,0.64 ,0.64, 0.8};
    remoteDrawColor = c;
    
    NSLog(@"Udp Echo server for Remote-Control started on port %hu", [socket localPort]);
    
    return self;
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg) {
        
        NSArray *chunks = [msg componentsSeparatedByString:@";"];
        NSString *command = [chunks objectAtIndex:0];
        
        if([command isEqualToString:@"snapshot"]) {
            NSString *snapshotID = [chunks objectAtIndex:1];
            [self takeSnapshotWithID:snapshotID];
        } else if([command isEqualToString:@"setLogFile"]) {
            NSString *studyID = [chunks objectAtIndex:1];
            NSString *logComment = [chunks objectAtIndex:2];
            
            appDelegate.configurationsViewController.studyID = studyID;
            appDelegate.configurationsViewController.additionalInfo = logComment;
         
            [appDelegate.logger setupLogFile];
        } else if([command isEqualToString:@"changeColor"]) {
            
            float red = [[chunks objectAtIndex:1] floatValue];
            float green = [[chunks objectAtIndex:2] floatValue];
            float blue = [[chunks objectAtIndex:3] floatValue];
            
            UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
            [appDelegate.canvasViewController.brushColorViewController setCurrentColor:color];
            
        } else if([command isEqualToString:@"draw"]) {
            
            
            [self processDrawingCommands:[msg substringFromIndex:5]];
            
        } else if([command isEqualToString:@"eraseCanvas"] ) {
            [appDelegate.canvasViewController.canvas eraseToIndex:-1 finished:YES];
        }
    } else {
		NSLog(@"Error converting received data into UTF-8 String");
	}
    
	//[udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:0];
	[socket receiveWithTimeout:-1 tag:0];
    
	return YES;
}

- (void) processDrawingCommands:(NSString *)msg
{
    msg = [msg substringFromIndex:5];
    NSArray *lines = [msg componentsSeparatedByString:@"\n"];

    for(NSString *line in lines) {
        
        [self processDrawingCommand:line];
    
    }
    
}

- (void) processDrawingCommand:(NSString *) msg 
{
    
    NSArray *chunks = [msg componentsSeparatedByString:@";"];
    NSString *gesture = [chunks objectAtIndex:0];
    
    if ([gesture isEqualToString:@"pinch_start"] || [gesture isEqualToString:@"pinch"]) {
        
        
        float x_coord = [((NSString *)[chunks objectAtIndex:1]) intValue];
        float y_coord = [((NSString *)[chunks objectAtIndex:2]) intValue];
        
        // NSLog(@"%@", gesture);
        if([gesture isEqualToString:@"pinch_start"]) {
            
            // last Point = the one of the cursor
            
            firstPinchPoint = CGPointMake(x_coord, y_coord);
            useFirstPinchPoint = YES;
            
            // lastPoint is last cursor point; draw first point
            [appDelegate.canvasViewController.canvas addAndRenderLineWithStartPoint:lastPoint endPoint:lastPoint color:remoteDrawColor lineWidth:[appDelegate.canvasViewController.brushSizeViewController getBrushSize]];
            
            
        } else {
            
            CGPoint delta;
            if(useFirstPinchPoint) {
                
                delta = CGPointMake(x_coord - firstPinchPoint.x, 
                                    y_coord - firstPinchPoint.y);
                
                useFirstPinchPoint = NO;
                
            } else {
                
                delta = CGPointMake(x_coord - lastPinchPoint.x, 
                                    y_coord - lastPinchPoint.y);
            }
            
            CGPoint newPoint = CGPointMake(lastPoint.x + delta.x, 
                                           lastPoint.y +delta.y);
            
            [appDelegate.canvasViewController.canvas addAndRenderLineWithStartPoint:lastPoint endPoint:newPoint color:remoteDrawColor lineWidth:[appDelegate.canvasViewController.brushSizeViewController getBrushSize]];
            
            lastPoint = newPoint;
            lastPinchPoint = CGPointMake(x_coord, y_coord);
            
        }
    
    } else if([gesture isEqualToString:@"cursor"]) {
        float x_coord = [((NSString *)[chunks objectAtIndex:1]) intValue];
        float y_coord = [((NSString *)[chunks objectAtIndex:2]) intValue];
        lastPoint = CGPointMake(x_coord, y_coord);
        
        lastPoint = [appDelegate.canvasViewController clipCursorPoint:lastPoint];
        
        [appDelegate.canvasViewController.pencilCursor movePencilCursorTo:lastPoint];
    
    }
}
                  
- (void) sendData:(NSData *)data 
{
    [socket sendData:data 
              toHost:hostToConnect 
                port:NETWORK_SHOE_LISTENING_PORT 
         withTimeout:-1 tag:0];
}

- (void) sendMessage:(NSString *)msg withAck:(bool) ack {
    
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendData:data];
    
}

// http://stackoverflow.com/questions/7964153/ios-whats-the-fastest-most-performant-way-to-make-a-screenshot-programaticall
- (void) takeSnapshotWithID:(NSString*)snapShotID;
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
            
        }
    }
    
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    image = [image rotatedByDegrees:90.0];
    image =  [image mergeWithImage:[appDelegate.canvasViewController.canvas getSnapshotImage]  strength:1.0];
    
    NSString *screenshotFileName = [NSString stringWithFormat:@"snapshot_%@.png", snapShotID];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:screenshotFileName];

    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filePath atomically:YES];
    
    
    UIGraphicsEndImageContext();
    
}

@end
