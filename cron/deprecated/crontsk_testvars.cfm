<cfscript>
if (not isdefined("APPLICATION.crontsklog")) { 
APPLICATION.crontsklog 			= createObject("component", "cfc.logwriter.logwriter").init("D:\JRun4\servers\vegexp\cfusion-war\logs\", "crontsklog");
APPLICATION.var_DO 			= 			createObject("component", "cfc.global.var_do").init();
}


APPLICATION.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Crontask: Test cron task" );
</cfscript>
<cfoutput>
SERVERNAME = #cgi.SERVER_NAME#
#APPLICATION.var_DO.getVar("salesEmailAddress")#
#Application.Appmode#
</cfoutput>
