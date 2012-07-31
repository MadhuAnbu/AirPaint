varying lowp vec4 DestinationColor; // 1
uniform sampler2D Textu;

void main(void) { // 2
    gl_FragColor = texture2D(Textu, gl_PointCoord) * DestinationColor;
}