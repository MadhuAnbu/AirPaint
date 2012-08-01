//
//  DynamicArray.h
//  AirPaint2
//
//  Created by Philipp Sessler on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INCREASE_LIMIT_STEP 1000

typedef struct {
    float Position[3];
    float Color[4];
    float Size;
} Vertex;


@interface DynamicVertexArray : NSObject {
    unsigned long limit;
}

@property int count;
@property Vertex* myData;

- (id) initWithMomentaryLimit:(unsigned long) limit;
- (unsigned long) addVertex: (Vertex) vertex;
- (void) removeVerticesFromIndex:(unsigned long) index;
- (unsigned long) getSize;
- (void*) getDataFromIndex:(unsigned long) index;
- (unsigned long) getCurrentSizeLimit;

@end
