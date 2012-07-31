//
//  ShoeConnection.h
//  AirPaint2
//
//  Created by Philipp Sessler on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "AppDelegate.h"

@class  AppDelegate;

@interface ShoeConnection : NSObject {
    
    AppDelegate *appDelegate;
    AsyncUdpSocket *socket;
    
    NSString *hostToConnect;
    UInt16 portToConnect; 
    
    NSMutableDictionary *outstandingAck;
}

@property (readonly) bool connected;

- (void) sendMessage:(NSString *)msg withAck:(bool) ack;
- (IBAction)checkAcks:(id)sender;

- (void) open;
- (void) connectionOpenedAck;
- (void) close;

@end
