(function() {
  var BEAT_MIN, analyser, audioBuffer, audioContext, audioURL, beat, beatCutOff, beatDecayRate, beatHit, beatHoldTime, beatTime, binCount, buffer, context, cube, cubeShaderInfo, dropArea, freqByteData, init, initSound, isPlayingAudio, level, levelBins, levelHistory, levelsCount, levelsData, loadSampleAudio, onBeat, onTogglePlay, render, source, startSound, stopSound, timeByteData, update, uvs, volSens, waveData;

  context = new GLOW.Context({
    clear: {
      red: 1,
      blue: 1,
      green: 1
    }
  });

  document.getElementById('container').appendChild(context.domElement);

  waveData = [];

  levelsData = [];

  level = 0;

  levelHistory = [];

  audioURL = '//api.soundcloud.com/tracks/165004741/stream?client_id=208ce4c90456c10dc9e91cd427ebff5a';

  volSens = 1.0;

  beatHoldTime = 36;

  beatDecayRate = 0.96;

  BEAT_MIN = 0.38;

  beat = 1.0;

  beatHit = 0.0;

  beatCutOff = 0;

  beatTime = 0;

  freqByteData = null;

  timeByteData = null;

  levelsCount = 16;

  binCount = null;

  levelBins = null;

  isPlayingAudio = false;

  source = null;

  buffer = null;

  audioBuffer = null;

  dropArea = null;

  audioContext = null;

  analyser = null;

  init = function() {
    var i, length, _i, _results;
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
    analyser = audioContext.createAnalyser();
    analyser.smoothingTimeConstant = 0.8;
    analyser.fftSize = 1024;
    analyser.connect(audioContext.destination);
    binCount = analyser.frequencyBinCount;
    levelBins = Math.floor(binCount / levelsCount);
    freqByteData = new Uint8Array(binCount);
    timeByteData = new Uint8Array(binCount);
    length = 256;
    _results = [];
    for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
      _results.push(levelHistory.push(0));
    }
    return _results;
  };

  initSound = function() {
    source = audioContext.createBufferSource();
    return source.connect(analyser);
  };

  loadSampleAudio = function() {
    var request;
    stopSound();
    initSound();
    request = new XMLHttpRequest();
    request.open("GET", audioURL, true);
    request.responseType = "arraybuffer";
    request.onload = function() {
      return audioContext.decodeAudioData(request.response, function(buffer) {
        audioBuffer = buffer;
        return startSound();
      }, function(e) {
        return console.log(e);
      });
    };
    return request.send();
  };

  onTogglePlay = function() {
    if (ControlsHandler.audioParams.play) {
      return startSound();
    } else {
      return stopSound();
    }
  };

  startSound = function() {
    source.buffer = audioBuffer;
    source.loop = true;
    source.start(0.0);
    return isPlayingAudio = true;
  };

  stopSound = function() {
    isPlayingAudio = false;
    if (source) {
      source.stop();
      return source.disconnect();
    }
  };

  onBeat = function() {
    beatHit = Math.random();
    if (beat < 0 || Math.random() < 0.8) {
      return beat = beat * -1;
    }
  };

  update = function() {
    var i, j, sum, _i, _j, _k, _l;
    if (!isPlayingAudio) {
      return;
    }
    if (source.context.currentTime > 52) {
      stopSound();
    }
    analyser.getByteFrequencyData(freqByteData);
    analyser.getByteTimeDomainData(timeByteData);
    for (i = _i = 0; 0 <= binCount ? _i < binCount : _i > binCount; i = 0 <= binCount ? ++_i : --_i) {
      waveData[i] = ((timeByteData[i] - 128) / 128) * volSens;
    }
    for (i = _j = 0; 0 <= levelsCount ? _j < levelsCount : _j > levelsCount; i = 0 <= levelsCount ? ++_j : --_j) {
      sum = 0;
      for (j = _k = 0; 0 <= levelBins ? _k < levelBins : _k > levelBins; j = 0 <= levelBins ? ++_k : --_k) {
        sum += freqByteData[(i * levelBins) + j];
      }
      levelsData[i] = sum / levelBins / 256 * volSens;
    }
    sum = 0;
    for (j = _l = 0; 0 <= levelsCount ? _l < levelsCount : _l > levelsCount; j = 0 <= levelsCount ? ++_l : --_l) {
      sum += levelsData[j];
    }
    level = sum / levelsCount;
    levelHistory.push(level);
    levelHistory.shift(1);
    if (level > beatCutOff && level > BEAT_MIN) {
      onBeat();
      beatCutOff = level * 1.4;
      return beatTime = 0;
    } else {
      if (beatTime <= beatHoldTime) {
        return beatTime += 1;
      } else {
        beatCutOff *= beatDecayRate;
        return beatCutOff = Math.max(beatCutOff, BEAT_MIN);
      }
    }
  };

  init();

  loadSampleAudio();

  uvs = new Float32Array([0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.5, 0.5, 0.75, 0.5, 0.75, 0.25, 1.0, 0.25, 1.0, 0.5, 0.25, 0.65, 0.125, 0.40, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.25, 0.75, 0.25, 0.75, 0.5, 0.5, 0.65, 0.25, 0.65, 0.25, 0.5, 0.5, 0.5, 0, 1, 1, 1, 1, 0, 0, 0]);

  cubeShaderInfo = {
    vertexShader: window.getShaderSync('vertex'),
    fragmentShader: window.getShaderSync('fragment'),
    data: {
      transform: new GLOW.Matrix4(),
      cameraInverse: GLOW.defaultCamera.inverse,
      cameraProjection: GLOW.defaultCamera.projection,
      level: new GLOW.Float(),
      beat: new GLOW.Float(),
      beatHit: new GLOW.Float(),
      time: new GLOW.Float(),
      vertices: GLOW.Geometry.Cube.vertices(500),
      uvs: uvs,
      normals: GLOW.Geometry.Cube.normals()
    },
    indices: GLOW.Geometry.Cube.indices(),
    primitives: GLOW.Geometry.Cube.primitives()
  };

  cube = new GLOW.Shader(cubeShaderInfo);

  GLOW.defaultCamera.localMatrix.setPosition(0, 0, 1500);

  GLOW.defaultCamera.update();

  cube.transform.addRotation(0.1, 0.2, 0);

  render = function() {
    if (!isPlayingAudio) {
      return requestAnimationFrame(render);
    }
    context.cache.clear();
    context.clear();
    update();
    cube.level.set(level);
    cube.beat.set(beat);
    cube.beatHit.set(beatHit);
    cube.time.add(0.01);
    cube.transform.addRotation(0.00008, 0.00008, 0);
    cube.draw();
    return requestAnimationFrame(render);
  };

  requestAnimationFrame(render);

}).call(this);

//# sourceMappingURL=script.js.map
