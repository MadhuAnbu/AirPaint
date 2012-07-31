//
//  DynamicArray.h
//  AirPaint2
//
//  Created by Philipp Sessler on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INCREASE_LIMIT_STEP 300

typedef struct {
    float Position[3];
    float Color[4];
    float Size;
} Vertex;


@interface DynamicVertexArray : NSObject {
    int limit;
}

@property int count;
@property Vertex* data;

- (id) initWithMomentaryLimit:(int) limit;
- (int) addVertex: (Vertex) vertex;
- (void) removeVerticesFromIndex:(int) index;
- (int) getSize;
- (Vertex*) getDataFromIndex:(unsigned long) index;

@end
