context = new GLOW.Context( clear: {red: 1, blue: 1, green: 1})
document.getElementById('container').appendChild(context.domElement)



waveData = [] #waveform - from 0 - 1 . no sound is 0.5. Array [binCount]
levelsData = [] #levels of each frequency - from 0 - 1. No sound is 0. Array [levelsCount]
level = 0 # averaged normalized level from 0 - 1
levelHistory = [] #last 256 ave norm levels

# sampleAudioURL = "../src/js/1/flicker.mp3"
audioURL = '//api.soundcloud.com/tracks/165004741/stream?client_id=208ce4c90456c10dc9e91cd427ebff5a'

# ????
volSens = 1.0
beatHoldTime = 36
beatDecayRate = 0.96
BEAT_MIN = 0.38 # minimum volume to trigger a beat

beat = 1.0
beatHit = 0.0
beatCutOff = 0
beatTime = 0

freqByteData = null #bars - bar data is from 0 - 256 in 512 bins. no sound is 0
timeByteData = null #waveform - waveform data is from 0-256 for 512 bins. no sound is 128.
levelsCount = 16 #should be factor of 512

binCount = null #512
levelBins = null

isPlayingAudio = false

source = null
buffer = null
audioBuffer = null
dropArea = null
audioContext = null
analyser = null

init = ->
  audioContext = new (window.AudioContext || window.webkitAudioContext)()
  analyser = audioContext.createAnalyser()
  analyser.smoothingTimeConstant = 0.8 #0<->1. 0 is no time smoothing
  analyser.fftSize = 1024
  analyser.connect(audioContext.destination)
  binCount = analyser.frequencyBinCount # = 512

  levelBins = Math.floor(binCount / levelsCount) #number of bins in each level

  freqByteData = new Uint8Array(binCount)
  timeByteData = new Uint8Array(binCount)

  length = 256
  for i in [0...length]
    levelHistory.push(0)


initSound = ->
  source = audioContext.createBufferSource()
  source.connect(analyser)

#load sample MP3
loadSampleAudio = ->
  stopSound()
  initSound()

  # Load asynchronously
  request = new XMLHttpRequest()
  request.open("GET", audioURL, true)
  request.responseType = "arraybuffer"

  request.onload = ->
    audioContext.decodeAudioData request.response, (buffer) ->
      audioBuffer = buffer
      startSound()
    , (e) -> console.log(e)

  request.send()


onTogglePlay = ->
  if (ControlsHandler.audioParams.play)
    startSound()
  else
    stopSound()

startSound = ->
  source.buffer = audioBuffer
  source.loop = true
  source.start(0.0)
  isPlayingAudio = true


stopSound = ->
  isPlayingAudio = false
  if (source)
    source.stop()
    source.disconnect()


onBeat = ->
  # if Math.random() < 0.8
  beatHit = Math.random()

  if beat < 0 || Math.random() < 0.8
    beat = beat * -1



#called every frame
#update published viz data
update = ->
  return unless isPlayingAudio

  stopSound() if source.context.currentTime > 52

  #GET DATA
  analyser.getByteFrequencyData(freqByteData) #<-- bar chart
  analyser.getByteTimeDomainData(timeByteData) # <-- waveform

  #normalize waveform data
  for i in [0...binCount]
    waveData[i] = ((timeByteData[i] - 128) /128 ) * volSens
  #TODO - cap levels at 1 and -1 ?

  #normalize levelsData from freqByteData
  for i in [0...levelsCount]
    sum = 0
    for j in [0...levelBins]
      sum += freqByteData[(i * levelBins) + j]

    levelsData[i] = sum / levelBins/256 * volSens #freqData maxs at 256

    #adjust for the fact that lower levels are percieved more quietly
    #make lower levels smaller
    #levelsData[i] *=  1 + (i/levelsCount)/2


  #GET AVG LEVEL
  sum = 0
  for j in [0...levelsCount]
    sum += levelsData[j]

  level = sum / levelsCount

  levelHistory.push(level)
  levelHistory.shift(1)

  #BEAT DETECTION
  if (level > beatCutOff && level > BEAT_MIN)
    onBeat()
    beatCutOff = level * 1.4
    beatTime = 0
  else
    if (beatTime <= beatHoldTime)
      beatTime += 1
    else
      beatCutOff *= beatDecayRate
      beatCutOff = Math.max(beatCutOff, BEAT_MIN)




init()
loadSampleAudio()




uvs = new Float32Array [
  # front
  0.25, 0.5,
  0.25, 0.25,
  0.5,  0.25,
  0.5,  0.5,

  # back
  0.75, 0.5
  0.75, 0.25
  1.0,  0.25
  1.0,  0.5

  # left
  # 0.0,  0.5,
  # 0.0,  0.25,
  # 0.25, 0.25,
  # 0.25, 0.5,
  0.25, 0.65,
  0.125, 0.40,
  0.25, 0.25,
  0.25, 0.5,

  # right
  0.5,  0.5
  0.5,  0.25
  0.75, 0.25
  0.75, 0.5

  # up
  0.5,  0.65
  0.25, 0.65
  0.25, 0.5
  0.5,  0.5

  # down
  # ????
  0, 1
  1, 1
  1, 0
  0, 0
]



cubeShaderInfo =
  vertexShader: window.getShaderSync('vertex')
  fragmentShader: window.getShaderSync('fragment')
  data:
    # create uniform data
    transform: new GLOW.Matrix4()
    cameraInverse: GLOW.defaultCamera.inverse
    cameraProjection: GLOW.defaultCamera.projection
    level: new GLOW.Float()
    beat: new GLOW.Float()
    beatHit: new GLOW.Float()
    time: new GLOW.Float()
    # create attribute data
    vertices: GLOW.Geometry.Cube.vertices( 500 )
    # uvs: GLOW.Geometry.Cube.uvs()
    uvs: uvs
    normals: GLOW.Geometry.Cube.normals()
  indices: GLOW.Geometry.Cube.indices()
  primitives: GLOW.Geometry.Cube.primitives()


cube = new GLOW.Shader( cubeShaderInfo )


GLOW.defaultCamera.localMatrix.setPosition( 0, 0, 1500 )
GLOW.defaultCamera.update()



cube.transform.addRotation( 0.1, 0.2, 0 )

render = ->
  return requestAnimationFrame( render ) unless isPlayingAudio
  context.cache.clear()
  context.clear()

  update()
  cube.level.set( level )
  cube.beat.set( beat )
  cube.beatHit.set( beatHit )

  cube.time.add( 0.01 )
  cube.transform.addRotation( 0.00008, 0.00008, 0 )

  cube.draw()

  requestAnimationFrame( render )


requestAnimationFrame( render )
