//
//  Line.h
//  AirPaint2
//
//  Created by Philipp Sessler on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicVertexArray.h"

#define kBrushPixelStep		1
#define FRAME_HEIGHT 320

typedef struct {
    float r;
    float g;
    float b;
    float alpha;
} Color;

@interface Line : NSObject {

   // Vertix *pointerToData;
   // size_t dataSize;
    
    int firstPositionInVertexArray;
    int lastPositionInVertexArray;
}

@property int count;

@property CGPoint middle;

@property CGPoint start;
@property CGPoint end;
@property Color color;
@property float width;

- (id) initWithStart:(CGPoint) p1 endPoint:(CGPoint) p2 color:(Color) col 
          lineWidth:(float) size;
- (void) savePointsToArray:(DynamicVertexArray*)array;
- (void) transformWithTranslation:(CGPoint) delta;
- (void) updateVertexArray:(DynamicVertexArray*) array;
- (int) getLastPositionInVertexArray;
- (int) getFirstPositionInVertexArray;

@end
