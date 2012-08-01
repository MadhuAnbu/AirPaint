//
//  DynamicArray.m
//  AirPaint2
//
//  Created by Philipp Sessler on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DynamicVertexArray.h"
#import "AppDelegate.h"

@implementation DynamicVertexArray 

@synthesize myData, count;


- (id) initWithMomentaryLimit:(unsigned long) _limit {
    
   limit = _limit;
    if(limit <= 0) {
        NSLog(@"Error allocating space for DynamicVertexArray: limit %lu is invalid\n", limit); 
        return nil;
    }
    
    self.myData = calloc(limit, sizeof(Vertex));
    
    if(self.myData == NULL) {
        NSLog(@"Error allocating space for DynamicVertexArray\n"); 
        return nil;
    }
    else 
        self.count = 0;
    
    return self;
}

- (unsigned long) addVertex:(Vertex) vertex {
        
    self.myData[self.count] = vertex;
    self.count++;
    
    if(self.count == limit) {
        NSLog(@"Dynamic-vertex-buffer reallocated");
        limit += INCREASE_LIMIT_STEP;
        self.myData = realloc(self.myData, limit*sizeof(Vertex));
        if(self.myData == NULL) {
            NSLog(@"Error allocating space for DynamicVertexArray\n"); 
            return -1;
        } else {
            [[[(AppDelegate*) [[UIApplication sharedApplication] delegate] canvasViewController] canvas] updateVBO];
        }
    }
            
    return (self.count-1);
}

- (void) removeVerticesFromIndex:(unsigned long) index {
    
    if(index >= self.count) {
        NSLog(@"Dynamic Vertex Buffer removeVerticesFromIndex: Index %lu greater than count", index);
    }
    
    self.count = index;
}


- (unsigned long) getCurrentSizeLimit {
    return limit*sizeof(Vertex);
}
- (unsigned long) getSize {
    return self.count * sizeof(Vertex);
}

- (void*) getDataFromIndex:(unsigned long) index {
    return (void*) &self.myData[index];
}



@end
