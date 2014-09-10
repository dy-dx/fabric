(function() {
  'use strict';
  var id, script;

  id = parseInt(location.hash.split('#')[1], 10) || 1;

  window.getShaderSync = function(name) {
    var url;
    url = "../src/js/" + id + "/" + name + ".glsl";
    return $.ajax({
      type: 'GET',
      url: url,
      async: false
    }).responseText;
  };

  script = document.createElement('script');

  script.setAttribute('type', 'text/javascript');

  script.setAttribute('src', "js/" + id + "/script.js");

  document.body.appendChild(script);

}).call(this);

//# sourceMappingURL=script.js.map
