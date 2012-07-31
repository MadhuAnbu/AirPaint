//
//  DynamicArray.m
//  AirPaint2
//
//  Created by Philipp Sessler on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DynamicVertexArray.h"

@implementation DynamicVertexArray 

@synthesize data, count;


- (id) initWithMomentaryLimit:(int) _limit {
    
   limit = _limit;
    if(limit <= 0) {
        NSLog(@"Error allocating space for DynamicVertexArray: limit %i is invalid\n", limit); 
        return nil;
    }
    
    self.data = malloc (sizeof(Vertex) * limit);
    
    if(self.data == NULL) {
        NSLog(@"Error allocating space for DynamicVertexArray\n"); 
        return nil;
    }
    else 
        self.count = 0;
    
    return self;
}

- (int) addVertex:(Vertex) vertex {
    
    if(self.count >= limit) {
        NSLog(@"Dynamic-vertex-buffer reallocated");
        limit += INCREASE_LIMIT_STEP;
        self.data = realloc(self.data, limit*sizeof(Vertex));
        if(self.data == NULL) {
            NSLog(@"Error allocating space for DynamicVertexArray\n"); 
            return -1;
        } 
    }
        
    self.data[self.count] = vertex;
    self.count++;
        
    return (self.count-1);
}

- (void) removeVerticesFromIndex:(int) index {
    
    if(index >= self.count) {
        NSLog(@"Dynamic Vertex Buffer removeVerticesFromIndex: Index %i greater than count", index);
    }
    
    self.count = index;
}

- (int) getSize {
    return self.count * sizeof(Vertex);
}

- (Vertex*) getDataFromIndex:(unsigned long) index {
    return &self.data[index];
}



@end
