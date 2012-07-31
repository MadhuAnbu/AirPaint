//
//  RemoteControl.h
//  AirPaint2
//
//  Created by Philipp Sessler on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "AppDelegate.h"
#import "Line.h"

@class DrawPrimitives;

@interface RemoteControl : NSObject {
 
    AppDelegate *appDelegate;
    AsyncUdpSocket *socket;
    
    NSString *hostToConnect;
    UInt16 portToConnect; 
    
    NSMutableDictionary *outstandingAck;
    NSString *documentsDirectory;
    
    
    // for point drawing
    CGPoint lastPoint;
    CGPoint firstPinchPoint;
    CGPoint lastPinchPoint;
    bool useFirstPinchPoint;
    
    Color remoteDrawColor;
    
    
}

- (void) sendMessage:(NSString *)msg withAck:(bool) ack;
- (void) sendData:(NSData*) data;
- (void) takeSnapshotWithID:(NSString*)snapShotID;
- (void) processDrawingCommand:(NSString *) msg;

@end
