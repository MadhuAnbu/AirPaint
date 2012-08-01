//
//  ShoeConnection.m
//  AirPaint2
//
//  Created by Philipp Sessler on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoeConnection.h"
#import "Configurations.h"

@implementation ShoeConnection 

@synthesize connected;

- (id) init {
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    portToConnect = NETWORK_SHOE_LISTENING_PORT;
    hostToConnect = NETWORK_SHOE_IP;
        
    outstandingAck = [NSMutableDictionary dictionary];
    
    NSError *error = nil;
    if (![socket bindToPort:NETWORK_DEVICE_PORT_LISTENING error:&error])
    {
        NSLog(@"Bind error: %@", error);
    }
    
    [socket receiveWithTimeout:-1 tag:0];
    
    
    NSLog(@"Udp Echo server started on port %hu", [socket localPort]);
    
    [self open];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkAcks:) userInfo:nil repeats:YES];
    
    return self;
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    
    if(!self.connected) {
      //  hostToConnect = host;
      //  portToConnect = port;
      //  connected = YES;
    }
    
    
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg) {
        
        NSLog(@"%@", msg);
        
        if ([outstandingAck count] > 0) {
        
          
            NSEnumerator *enumerator = [outstandingAck keyEnumerator];
            NSString *ack;
            while ((ack = [enumerator nextObject])) {
                
                // special case first
                    
                if([msg isEqualToString:ack] 
                    && [msg isEqualToString:@"connectionOpenedAck"]) {
                    [self connectionOpenedAck];
                }
                    
                if([msg isEqualToString:ack]) {
                    [outstandingAck removeObjectForKey:ack];
                    break;
                }
                    
            }
        }
            
        
        NSArray *chunks = [msg componentsSeparatedByString:@";"];
        NSString *command = [chunks objectAtIndex:0];
        
        if(!self.connected) {

                // do nothing
            
        } else if ([command isEqualToString:@"handTracked"]) {
            
            if(!appDelegate.handTracked && self.connected) {
                appDelegate.handTracked = YES;
                [[appDelegate navigationController] pushViewController:[appDelegate canvasViewController] animated:NO];
                FLog(@"Hand tracked");
            }
            
        } else if ([command isEqualToString:@"handLost"]) {
            
            if(appDelegate.handTracked && self.connected) {
                appDelegate.handTracked = NO;
                [[[appDelegate startViewController] label ]setText:@"Hand lost!"];
                [[appDelegate navigationController] popToRootViewControllerAnimated:NO];
                FLog(@"Hand lost");
            }
            
        } else {
            [[appDelegate canvasViewController] processCommand:msg];
        }
        
    } else {
		NSLog(@"Error converting received data into UTF-8 String");
	}
    
	//[udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:0];
	[socket receiveWithTimeout:-1 tag:0];
    
	return YES;
}


- (void) sendMessage:(NSString *)msg withAck:(bool) ack {
    
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [socket sendData:data toHost:hostToConnect port:NETWORK_SHOE_LISTENING_PORT withTimeout:-1 tag:0];
    
    NSString *ackMsg =  [NSString stringWithFormat:@"%@Ack",msg];
    if([outstandingAck objectForKey:ackMsg]==nil) {
        [outstandingAck setValue:[NSNumber numberWithInt:0]
                          forKey:ackMsg];
    } 
        
    NSLog(@"Schicke: >> %@", msg);
    
}

- (void) sendMessageAgain:(NSString*)msg {

    NSString *msg2 = [msg substringToIndex:[msg length]-3];
    [self sendMessage:msg2 withAck:YES];
}

- (IBAction)checkAcks:(id)sender {
    
    if([outstandingAck count]==0) return ;
    
    NSEnumerator *enumerator = [outstandingAck keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {        
        [self sendMessageAgain:key];
    }
    
}

- (void) open {
    
    if(!connected) {
        [self sendMessage:@"connectionOpened" withAck:YES];
    }
        
}

- (void) connectionOpenedAck {
    connected = YES;
    [[[appDelegate startViewController] label] setText:@"Hand not tracked"];
    FLog(@"Conntected to shoe");
}

- (void) close {
    if(!connected) return ;
    [self sendMessage:@"connectionClosed" withAck:NO];
    connected = NO;
}

@end
