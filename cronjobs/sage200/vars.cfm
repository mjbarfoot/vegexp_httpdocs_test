<!--- vars.cfm
variables for use in the sync jobs
--->

<cfscript>
VARIABLES.sage200sync = {};
VARIABLES.sage200sync.sage200_dsn = "VEGEXPLIVE";
VARIABLES.sage200sync.syncdb_dsn = "VEORDERSYNC";
VARIABLES.sage200sync.notify = {
"from": "sagesync@vegetarianexpress.co.uk",
"to": "matt.barfoot@clearview-webmedia.co.uk"
};
VARIABLES.kafka = {};
</cfscript>
