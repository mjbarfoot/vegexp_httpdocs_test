<!--- Specification for setup.cfm
1. Create db and db tables
2. Populate db tables

--->
<cfsavecontent variable="htmlbp">
  <!DOCTYPE html>
  <html>
    <head>
      <title>Installer</title>
      <script src="https://unpkg.com/vue"></script>
      <style>
        h1 {
          font-family: system-ui;
          font-size: 2em;
        };
        div {
          font-family: system-ui;
          font-size: 11px;
        };
        iframe {
          background-color: black;
          border: 0;
        };
      </style>

    </head>
    <body>
      <h1>Sage 200 Orders Website Integration</h1>
      <div id="app">
        <p>{{ message }}</p>
        <button id="install" name="install DB" v-on:click="installDatabase">Install DB</button>
        <button id="setup_data" name="Setup Data" v-on:click="setupData">Setup Data</button>
      </div>

      <script>
        var app = new Vue({
          el: '#app',
          data: {
            message: ''
          },
          methods: {
              installDatabase: function() {
                  this.message = "Installing VEORDERSYNC database";
                  document.getElementById('iAction').src="/sage200sync/init/dbconfig.cfm";
              },
              setupData: function() {
                  this.message = "Adding Initial Sync Data from VESAGELIVE to VEORDERSYNC"
                  document.getElementById('iAction').src="/sage200sync/init/populatedata.cfm";
              }
          }
        });
      </script>
      <iframe id="iAction" style="background-color: black" height="300px" width="750px"/>
    </body>
  </html>
</cfsavecontent>

<cfscript>
  writeOutput(htmlbp);

  //include "dbconfig.cfm" runonce=true; include "db_create_initial_data.cfm" runonce=true;
</cfscript>
