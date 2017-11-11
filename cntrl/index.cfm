<cfparam name="url.ev" default="default" />
<cfparam name="url.value" default="default" />
<cfscript>
request.ev = createObject("component", "cfc.cntrl.event").init();
content=request.ev.request(url.ev, url.value);
</cfscript>

<cfinclude template="/views/cntrl/default.cfm" />