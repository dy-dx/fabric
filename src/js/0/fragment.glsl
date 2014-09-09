#ifdef GL_ES
    precision highp float;
#endif

uniform   sampler2D   texture;
uniform   float       time;
varying   float       light;
varying   vec2        uv;

void main( void )
{
  float x = uv.x;
  float y = uv.y;
  float sinTime = sin( time );
  float cosTime = cos( time );
  float red = ( sin( x * cosTime * 5.0 ) + cos( y * 6.0 + time + cosTime )) * ( sinTime * 0.25 + 0.25 ) + 0.5;
  float green = ( sin( cosTime ) * cos( y * cosTime )) * 0.2 + 0.5;
  float blue = ( sin( x * sinTime * 5.0 + time ) + cos( y * 5.0 * cosTime + time * cosTime )) * ( cosTime * 0.25 + 0.25 ) + 0.5;
  gl_FragColor = vec4( red, green, blue, 1.0 );
  gl_FragColor *= light;
}
