//
//  Canvas.m
//  AirPaint2
//
//  Created by Philipp Sessler on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CC3GLMatrix.h"
#import "Canvas.h"
#import "Line.h"

@implementation Canvas

@synthesize lines;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = NO;
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

}

- (void)setupContext {   
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);        
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];    
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);    
}

- (void)setupFrameBuffer {    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);   
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
   
    // create NSString with content of shader file
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // create openGL object to represent the shader; shaderType either vertex or fragment
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // giving openGL the sourceCode of the shader
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // compile shader at runtime
    glCompileShader(shaderHandle);
    
    // if shader compiling fais, give some output
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // compile vertex and fragment shaders
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    // link the shaders unto a complete program
    programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // display error message if linking has failed
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // tell openGL to use this program when given vertix info
    glUseProgram(programHandle);
    
    // get a pointer to the input values for the vertex shader
    positionSlot = glGetAttribLocation(programHandle, "Position");
    colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    thicknessSlot = glGetAttribLocation(programHandle, "Thickness");
    middleSlot = glGetAttribLocation(programHandle, "Middle");

    texCoordSlot = glGetAttribLocation(programHandle, "TextureCoord");
    
    // enable use of these arrays (disabled by default)
    glEnableVertexAttribArray(positionSlot);
    glEnableVertexAttribArray(colorSlot);
    glEnableVertexAttribArray(thicknessSlot);
    glEnableVertexAttribArray(middleSlot);
    glEnableVertexAttribArray(texCoordSlot);

    projectionUniform = glGetUniformLocation(programHandle, "Projection");
    textureUniform = glGetUniformLocation(programHandle, "Textu");
    modelViewUniform = glGetUniformLocation(programHandle, "ModelView");
    scaleFactorUniform = glGetUniformLocation(programHandle, "ScaleFactor");
    
}

- (void) setupBrushTexture {
    
    CGContextRef	brushContext;
	GLubyte			*brushData;
    
    // Create a texture from an image; dimensions must be a power of 2.
    CGImageRef brushImage = [UIImage imageNamed:@"particle.png"].CGImage;
    size_t brushImage_width = CGImageGetWidth(brushImage);
    size_t brushImage_height = CGImageGetHeight(brushImage);


    if(brushImage) {

        brushData = (GLubyte *) calloc(brushImage_width * brushImage_height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework. 
        brushContext = CGBitmapContextCreate(brushData, brushImage_width, brushImage_height, 8, brushImage_width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)brushImage_width, (CGFloat)brushImage_height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &brushTexture);
        // Bind the texture name. 
        glBindTexture(GL_TEXTURE_2D, brushTexture);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, brushImage_width, brushImage_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);
        
    }
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);    
}

- (void) setModelViewWithTransitionX: (float) x Y:(float)y {
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(x, y, 0.0)];
    glUniformMatrix4fv(modelViewUniform, 1, 0, modelView.glMatrix);
    
}

/*
- (GLuint)setupTexture:(NSString *)fileName {    
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, 
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);    
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

*/
- (void) clear {
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


- (void)prepareRendering {
    
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self clear];
    
    [self setupBrushTexture];

    vertexArray = [[DynamicVertexArray alloc] initWithMomentaryLimit:VERTEX_ARRAY_INITIAL_SIZE];
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);

    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), 0);
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(thicknessSlot, 1, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
  
     
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    //float h = 4.0 * self.frame.size.height / self.frame.size.width;
   // [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:-0.01 andFar:1.01];
    [projection populateFromFrustumLeft:0 andRight:480 andBottom:320 andTop:0 andNear:-20.0 andFar:2.00];
    glUniformMatrix4fv(projectionUniform, 1, 0, projection.glMatrix);
    
    
    glUniform1i(textureUniform, 0);
    [self setModelViewWithTransitionX:0 Y:0];
}

- (void) renderLinesToIndex:(int) index {
    
    [self clear];

    if(index!=-1) {
        Line *line = [self.lines objectAtIndex:index];
        glDrawArrays(GL_POINTS, 0, [line getLastPositionInVertexArray]+1);
    } 
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void) updateVBO {
    NSLog(@"updateVBO called: size: %lu", [vertexArray getCurrentSizeLimit]);
    
 //   glGenBuffers(1, &vertexBuffer);
 //   glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);

    glBufferData(GL_ARRAY_BUFFER,  [vertexArray getCurrentSizeLimit], (void *)[vertexArray myData], GL_STREAM_DRAW);
}


// --------------------------- END OF PRIVATE MEHTODS -----------------------------------
// --------------------------------------------------------------------------------------

- (id)init 
{
 
    CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
    self = [super initWithFrame:
            CGRectMake(0, 0, screenBounds.height, screenBounds.width)];
    if (self) {        
    
        appDelegate = [[UIApplication sharedApplication] delegate];

        currentScaleFactor = 1.0;
        [self setAutoresizingMask: UIViewAutoresizingNone];    
        
        self.lines = [[NSMutableArray alloc] init];
            
        sumSubDraw = 0;
        
        // setting up OpenGL
        [self setupLayer];       
        [self setupContext];    
        [self setupDepthBuffer];
        [self setupRenderBuffer];        
        [self setupFrameBuffer];     
        [self compileShaders];
        [self prepareRendering];
        [self updateVBO];
    }
    
    return self;
}

- (void) addAndRenderLineWithStartPoint:(CGPoint) start endPoint:(CGPoint) end color:(Color) col lineWidth:(float) size {
        
   // [self clear];
    
    // add line
    Line *line = [[Line alloc] initWithStart:start endPoint:end color:col lineWidth:size];
    [line savePointsToArray:vertexArray];
    [self.lines addObject:line];

    // draw line
  /*
    
    glBufferData(GL_ARRAY_BUFFER,  [vertexArray getSize], [vertexArray data], GL_STREAM_DRAW);
    glDrawArrays(GL_POINTS, 0, [vertexArray count]);
     
  */
    /*
    
    glBufferData(GL_ARRAY_BUFFER, [line count], 
                 [vertexArray getDataFromIndex:[line getFirstPositionInVertexArray]], GL_STREAM_DRAW);
    
    glDrawArrays(GL_POINTS, 0, 1);
     */
    
  /*
    
    NSLog(@"firstPositionInVertexArray: %i, line count: %i, drawArrayCount; %i", [line getFirstPositionInVertexArray ], [line count], [vertexArray count]);

    
    glBufferData(GL_ARRAY_BUFFER,  sizeof(Vertex) * [line count], 
                 [vertexArray getDataFromIndex:[line getFirstPositionInVertexArray]], GL_STREAM_DRAW);
*/
    
    /*
    glBufferSubData(GL_ARRAY_BUFFER, 
                    0, 
                    [line count]*sizeof(Vertex),
                    [vertexArray getDataFromIndex:[line getFirstPositionInVertexArray]] );
    
    
    glDrawArrays(GL_POINTS,  0,  [line count]);
    */
    
    
    /*
    // does kind of work but gets slow
    glBufferSubData(GL_ARRAY_BUFFER, 
                    [line getFirstPositionInVertexArray] * sizeof(Vertex), 
                    [line count]*sizeof(Vertex),
                    [vertexArray getDataFromIndex:[line getFirstPositionInVertexArray]] );
    
    glDrawArrays(GL_POINTS,  0,  [vertexArray count]);
    */
   
    /*
    // does work, but get's slow
    // only works in the simulator?!?!
    glBufferSubData(GL_ARRAY_BUFFER,
                    [line getFirstPositionInVertexArray] * sizeof(Vertex), 
                    [line count]*sizeof(Vertex),
                    [vertexArray getDataFromIndex:[line getFirstPositionInVertexArray]] );
    
    
    glDrawArrays(GL_POINTS, [line getFirstPositionInVertexArray],  [line getLastPositionInVertexArray]+1-[line getFirstPositionInVertexArray]);
     */
    
    glBufferSubData(GL_ARRAY_BUFFER,
                    0,
                    [vertexArray count]*sizeof(Vertex),
                    [vertexArray myData] );
    
    
    glDrawArrays(GL_POINTS, [line getFirstPositionInVertexArray],  [line getLastPositionInVertexArray]+1-[line getFirstPositionInVertexArray]);
    
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
    // move cursor to last point of line
    [[appDelegate.canvasViewController pencilCursor] movePencilCursorTo: [line end] traverse:YES];
}



- (void) eraseToIndex:(int) index finished:(bool) finished {
    
    if([self.lines count] == 0) 
        return ;
    
    [self clear];
    
    if(finished) {
        
        int numb;
        if(index == -1)
            numb = [self.lines count];
        else  
            numb = [self.lines count] - index;

        // index of the last vertex in the vertex array that should be render
        
        int lastVertexIndexToRender;
        if(index != -1) {
            lastVertexIndexToRender = [(Line*)[self.lines objectAtIndex:index] getLastPositionInVertexArray] + 1;
        } else {
            index = 0;
            lastVertexIndexToRender = [(Line*)[self.lines objectAtIndex:index] getFirstPositionInVertexArray];
        }
        
        NSLog(@"remove lines in range: index %i, numb: %i", index, numb);
        
        [self.lines removeObjectsInRange:NSMakeRange(index, numb)];
        
        [vertexArray removeVerticesFromIndex:lastVertexIndexToRender];
        
        glBufferData(GL_ARRAY_BUFFER,  [vertexArray getSize], [vertexArray myData], GL_STREAM_DRAW);
        glDrawArrays(GL_POINTS, 0, [vertexArray count]);

        [context presentRenderbuffer:GL_RENDERBUFFER];

        
    } else {
        
        [appDelegate.canvasViewController eraseViewController].eraseToIndex = index;
        
        CGPoint pointToMoveCursorTo;
        if(index == -1) {
            pointToMoveCursorTo = [(Line*)[self.lines objectAtIndex:0] start];
        } else {
            pointToMoveCursorTo = [(Line*)[self.lines objectAtIndex:index] end];
        }
        
        // move cursor
        [[appDelegate.canvasViewController pencilCursor] movePencilCursorTo: pointToMoveCursorTo traverse:YES];
        
        // render lines
        [self renderLinesToIndex:index];
    }
    
    
}

- (void) eraseAndDisplay:(bool) display {
    [self clear];
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

// copyright:
// http://stackoverflow.com/questions/8980847/iphone-take-augmented-reality-screenshot-with-avcapturevideopreviewlayer

- (UIImage *) getSnapshotImage
{
    NSInteger x = 0;
    NSInteger y = 0;
    NSInteger width = self.frame.size.width;
    NSInteger height = self.frame.size.height;
    NSInteger dataLength = width * height * 4;
    
    NSUInteger i;
    for ( i=0; i<100; i++ )
    {
        glFlush();
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, (float)1.0/(float)60.0, FALSE);
    }
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    //
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    //
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    //
    NSInteger widthInPoints;
    NSInteger heightInPoints;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
    {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        //
        CGFloat scale = self.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else
    {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        //
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    //
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   // autoreleased image
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}




@end
