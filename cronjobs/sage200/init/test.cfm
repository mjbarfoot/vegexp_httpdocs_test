<cfscript>
writeOutput("
<style>
     p {color:  ##00ff00; font-style: Lucida Console;};
</style>");
writeOutput("<p>Here I am</p>");
cfflush();
sleep(1000);
writeOutput("<p>Here I am 1 second later!</p>");
sleep(1000);
writeOutput('<script language="JavaScript">parent.document.getElementById("install-iframe").src="/sage200sync/init/test2.cfm";</script>');
</cfscript>
