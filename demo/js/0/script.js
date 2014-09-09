(function() {
  var container, context, cube, cubeShaderInfo, render;

  context = new GLOW.Context({
    clear: {
      red: 1,
      green: 1,
      blue: 1
    }
  });

  container = document.getElementById('container');

  container.appendChild(context.domElement);


  /*
    GLOW.Shader takes an object with the following properties:
      vertexShader: the vertex shader code
      fragmentShader: the fragment shader code
      data: the uniform, attribute and texture data
      indices: the primitive's index data
      primitives: the type of primitives (defaults to GL.TRIANGLES if left out)
   */

  cubeShaderInfo = {
    vertexShader: window.getShaderSync('vertex'),
    fragmentShader: window.getShaderSync('fragment'),
    data: {
      transform: new GLOW.Matrix4(),
      cameraInverse: GLOW.defaultCamera.inverse,
      cameraProjection: GLOW.defaultCamera.projection,
      time: new GLOW.Float(),
      vertices: GLOW.Geometry.Cube.vertices(500),
      uvs: GLOW.Geometry.Cube.uvs(),
      normals: GLOW.Geometry.faceNormals(GLOW.Geometry.Cube.vertices(), GLOW.Geometry.Cube.indices())
    },
    indices: GLOW.Geometry.Cube.indices(),
    primitives: GLOW.Geometry.Cube.primitives()
  };

  cube = new GLOW.Shader(cubeShaderInfo);

  GLOW.defaultCamera.localMatrix.setPosition(0, 0, 1500);

  GLOW.defaultCamera.update();

  cube.transform.addRotation(0.01, 0.3, 0);

  render = function() {
    context.cache.clear();
    context.clear();
    cube.time.add(0.01);
    cube.transform.addRotation(0.0005, 0.0003, 0.0002);
    cube.draw();
    return requestAnimationFrame(render);
  };

  requestAnimationFrame(render);

}).call(this);

//# sourceMappingURL=script.js.map
