<cfoutput>testcase: Eventlog reader</cfoutput>
<cfscript>
myapplog 			= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "applog", "db");
</cfscript>

<cfset logOutput = myapplog.read() />
<cfoutput>Log Length: #len(logOutput)# 	<br /> #logOutput#<Br/><Br/></cfoutput>
<cfoutput>#application.sageWSlog.read()#</cfoutput>
