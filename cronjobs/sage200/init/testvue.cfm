<!DOCTYPE html>
<html>
  <head>
    <title>Sage 200 Orders Website Integration</title>
    <script src="https://unpkg.com/vue"></script>
    <style>
      h1 {font-family: system-ui; font-size: 2em;}
      div {font-family: system-ui; font-size: 11px;};
      iframe {background-color: black; border: 0px;};
    </style>

  </head>
  <body>
    <h1>Sage 200 Orders Website Integration</h1>
    <div id="app">
         {{ message }}
    </div>

    <script>
  var app = new Vue({
    el: '#app',
    data: {
      message: 'Hello Vue!'
    }
  })
</script>

    <div id="nav">
        <button id="install" name="install DB">Install DB</button>
        <button id="setup_data" name="Setup Data">Setup Data</button>
    </div>
    <iframe id="install-iframe" src="" height="300px" width="750px" />

  </body>
</html>
