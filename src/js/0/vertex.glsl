uniform     mat4    transform;
uniform     mat4    cameraInverse;
uniform     mat4    cameraProjection;

attribute   vec3    vertices;
attribute   vec3    normals;
attribute   vec2    uvs;

varying     vec2    uv;
varying     float   light;

void main(void)
{
  uv = uvs;
  light = dot(
    normalize( mat3( transform[0].xyz, transform[1].xyz, transform[2].xyz ) * normals ),
    vec3( 0.0, 0.0, 1.0 )
  );
  gl_Position = cameraProjection * cameraInverse * transform * vec4( vertices, 1.0 );
}
