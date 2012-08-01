//
//  Canvas.h
//  AirPaint2
//
//  Created by Philipp Sessler on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CanvasViewController.h"
#import "Line.h"
#import "DynamicVertexArray.h"
#import "AppDelegate.h"

#define kBrushOpacity		(1.0)
#define kBrushPixelStep		3
#define kBrushScale			4
//#define kLuminosity			0.75
#define kLuminosity			1.0
#define kSaturation			1.0

#define VERTEX_ARRAY_INITIAL_SIZE 1500

@class AppDelegate;

@interface Canvas : UIView {
    
    AppDelegate *appDelegate;

    // vertex array
    DynamicVertexArray *vertexArray;

    // ------------ OpenGL stuf --------------
    CAEAGLLayer* eaglLayer;
    EAGLContext* context;
    
    GLuint colorRenderBuffer;
    GLuint depthRenderBuffer;
    GLuint vertexBuffer;

    GLuint programHandle;
        
    // slots for shader attributes
    GLuint positionSlot;
    GLuint colorSlot;
    GLuint thicknessSlot;
    GLuint middleSlot;
    GLuint texCoordSlot;
    
    // shader uniforms
    GLuint projectionUniform;
    GLuint textureUniform;
    GLuint modelViewUniform;
    GLuint scaleFactorUniform;
    
    // textures
    GLuint brushTexture;
    
    float currentScaleFactor;
 
    int sumSubDraw;
}

@property (atomic, retain) NSMutableArray *lines;

- (id)init;
- (void) addAndRenderLineWithStartPoint:(CGPoint) start endPoint:(CGPoint) end 
                                  color:(Color) col lineWidth:(float) size;
- (void) eraseToIndex:(int) index finished:(bool) finished;
- (void) eraseAndDisplay:(bool) display;
- (UIImage *) getSnapshotImage;
- (void) updateVBO;

@end

