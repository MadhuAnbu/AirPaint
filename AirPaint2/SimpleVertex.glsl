attribute vec4 Position;
attribute vec4 SourceColor; 
attribute float Thickness;
attribute vec4 Middle;

varying vec4 DestinationColor;
uniform mat4 Projection;
uniform mat4 ModelView;

uniform float ScaleFactor;

mat4 projectionMat = mat4( 2.0/480.0, 0.0, 0.0, -1.0,
                                 0.0, 2.0/320.0, 0.0, -1.0,
                                 0.0, 0.0, -2.0, 0.0,
                                 0.0, 0.0, 0.0, 1.0);   
      
 
void main(void) { // 4
    DestinationColor = SourceColor; // 5
    gl_Position = ModelView * Position * projectionMat; // 6
    gl_PointSize = Thickness*2.0;
}