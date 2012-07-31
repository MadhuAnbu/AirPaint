//
//  Line.m
//  AirPaint2
//
//  Created by Philipp Sessler on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Line.h"

@implementation Line

@synthesize start, end, color, width, count, middle;



- (id) initWithStart:(CGPoint) p1 endPoint:(CGPoint) p2 color:(Color) col 
           lineWidth:(float) size {
    
    p1.y = FRAME_HEIGHT - p1.y;
    p2.y = FRAME_HEIGHT - p2.y;

   // printf("color: (%f,%f,%f) \n", color.r, color.g, color.b);
    self.middle = CGPointMake((p1.x + p2.x) /2, (p1.y + p2.y)/2);

    self.start = p1;
    self.end = p2;
    self.color = col;
    self.width = size;
    
    self.count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
        
      return self;
}


- (void) savePointsToArray:(DynamicVertexArray*)array {
    
    for(int i = 0; i < self.count; i++) {        
        
        Vertex vertex;
        
        vertex.Position[0] = (self.start.x + (self.end.x - self.start.x) * ((GLfloat)i / (GLfloat)self.count));
        vertex.Position[1] = (self.start.y + (self.end.y - self.start.y) * ((GLfloat)i / (GLfloat)self.count));
        vertex.Position[2] = 0;
        
      
        vertex.Color[0] = self.color.r;
        vertex.Color[1] = self.color.g;
        vertex.Color[2] = self.color.b;
        vertex.Color[3] = self.color.alpha;
       
        
        vertex.Size = self.width;
        
        int pos = [array addVertex:vertex];
        
        if(i==0) firstPositionInVertexArray = pos;
        if(i==(self.count-1)) lastPositionInVertexArray = pos;
    
    }
}


- (void) transformWithTranslation:(CGPoint) delta {
        
    delta.y = -delta.y;
    
    CGPoint p1 = self.start;
    CGPoint p2 = self.end;
    
    p1.x += delta.x;
    p1.y += delta.y;
    p2.x += delta.x;
    p2.y += delta.y;
    
    self.start = p1;
    self.end = p2;
}


- (int) getLastPositionInVertexArray {
    return lastPositionInVertexArray;
}

- (int) getFirstPositionInVertexArray {
    return firstPositionInVertexArray;
}

- (void) updateVertexArray:(DynamicVertexArray*) array {
    
    for (int i = firstPositionInVertexArray, c = 0; i <= lastPositionInVertexArray; i++, c++) {
        
        
        [array data][i].Position[0] = (self.start.x + (self.end.x - self.start.x) * ((GLfloat)c / (GLfloat)self.count));
        [array data][i].Position[1] = (self.start.y + (self.end.y - self.start.y) * ((GLfloat)c / (GLfloat)self.count));
        [array data][i].Position[2] = 0;
       
      
    }
       
}

- (NSString*) description 
{
    return [NSString stringWithFormat:@"(%f, %f)->(%f,%f)", start.x, start.y, end.x, end.y];
}
@end
