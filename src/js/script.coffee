'use strict'

id = parseInt(location.hash.split('#')[1], 10) || 0

window.getShaderSync = (name) ->
  url = "../src/js/#{id}/#{name}.glsl"
  $.ajax(type: 'GET', url: url, async: false).responseText

script = document.createElement('script')
script.setAttribute('type', 'text/javascript')
script.setAttribute('src', "js/#{id}/script.js")
document.body.appendChild(script)
