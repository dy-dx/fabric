#ifdef GL_ES
    precision highp float;
#endif

uniform   float   time;
uniform   float   level;
uniform   float   beat;
uniform   float   beatHit;
varying   float   light;
varying   vec2    uv;

// void main( void )
// {
//   float x = uv.x*1.0;
//   float y = uv.y*1.0;
//   float sinTime = sin( time );
//   float cosTime = cos( time );

//   float r = ( sin( x * cosTime * 5.0 ) + cos( y * 6.0 + time + cosTime ) )
//               * ( sinTime * 0.25 + 0.25 )
//               + 0.5;

//   float g = ( sin( cosTime ) * cos( y * cosTime ) )
//                 * 0.2
//                 + 0.5;

//   float b = ( sin( x * sinTime * 5.0 + time ) + cos( y * 5.0 * cosTime + time * cosTime ) )
//                * ( cosTime * 0.25 + 0.25 ) + 0.5;

//   gl_FragColor = vec4( r, g, b, 1.0 );
//   // gl_FragColor *= light;
// }




// 2D noise code from
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}


float turbulence(vec2 position, float lacunarity, float gain)
{
    float sum = 0.0;
    float scale = 1.0;
    float totalGain = 1.0;
    const int octaves = 2;
    for (int i = 0; i < octaves; ++i)
    {
        sum += totalGain * snoise(position*scale);
        scale *= lacunarity;
        totalGain *= gain;
    }
    return abs(sum);
}


void main(void)
{
  // vec2 p = gl_FragCoord.xy / iResolution.xy;
  level;
  beat;
  beatHit;

  vec2 p = uv / (0.001/gl_FragCoord.w);
  float q = turbulence(p, 1.0 + 12.0*beatHit, 0.8);

  vec3 col = vec3( 1.0, 0.9, 0.0 );

  float r = snoise( vec2(400.0 + time*1.2 + q*2.0, 1.0) );
  // r+0.1*sin(2.0*time + p.y*0.01)
  // 0.3*snoise( p )
  col *= smoothstep( r, r+0.08*beat, 0.3);

  gl_FragColor = vec4(col, 1.0) * light;
}
