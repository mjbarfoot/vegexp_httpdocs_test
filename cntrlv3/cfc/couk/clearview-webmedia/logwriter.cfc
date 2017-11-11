<!--- 
	Filename: /cfc/logwriter/logwriter.cfc ("The application controller")
	Created by:  Matt Barfoot on 25/03/2006 Clearview Webmedia Limited
	Purpose:  create, read, write, delete operations on log files
	History: 27/10/2006 - Modified to include logging to database too 
--->

<cfcomponent output="false">

	<cfscript>
	this.name			= "logWriter";
	this.displayname	= "logWriter";
	this.hint			= "performs log actions";
	</cfscript>
	
	<cffunction name="init" access="public" output="false" returntype="any" hint="initiates the logwriter component">
	<cfargument name="logdir" type="string" required="true" />
	<cfargument name="logfile" type="string" required="true" />
	<cfargument name="logtype" type="string" required="false" default="file" />
	
	<cfscript>
	this.dblogname 		= arguments.logfile;
	this.logfile 		= arguments.logdir &  arguments.logfile & "_" & dateformat(now(), "yyyy-mm-dd") & ".log";
	this.logtype		= arguments.logtype;
	
	// Check we are not in production mode
	// Also, if logtype is file, then create need to create it if it doesn't exist
	if (application.AppMode neq "production" AND this.logtype eq "file") {
		if (NOT fileLogAction("LogExists")) fileLogAction("create");	
	
	}
	
	return this;
	</cfscript>
	</cffunction>
	
	
	<cffunction name="write" output="false"  access="public" hint="Writes some given text to the log file">
	<cfargument name="content" type="string" required="true" />
	<cfscript>
	if (application.AppMode neq "production") {
		// call either fileLogAction or dbActionLog
		evaluate(this.logtype & 'LogAction("write", arguments.content)');
	}
	</cfscript>
	
	</cffunction>
	
	<cffunction name="read" output="false" access="public" returntype="string" hint="reads the log file">
	
	<cfscript>
	return evaluate(this.logtype & 'LogAction("read")');
	</cfscript>
	
	</cffunction>
	
	<cffunction name="delete" output="false" access="public" hint="reads the log file">
	<!--- does nothing yet --->
	</cffunction>
	
	
	<cffunction name="fileLogAction" output="false" returntype="any" access="private" hint="does the cffile action">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="content" type="string" required="false" />
	
	<cfset var ret="" />
	
	<!--- Check we are not in production mode --->
	<cfif application.AppMode neq "production">
	
		
		<cfswitch expression=#arguments.action#>
		<cfcase value="read">
			<cffile     action = "read" 
						file = "#this.logfile#" 
					    variable = "ret">
		<cfreturn ret>
		</cfcase>
		<cfcase value="create">
			<cffile     action 		= "write" 
						file 		= "#this.logfile#" 
					    addnewline	= "true"
						output 		= "Log started: #dateformat(now(), 'dd/mm/yyyy')# #timeformat(now(), 'h:mm:ss tt')#"
						charset 	= "utf8" >
		
		</cfcase>
		<cfcase value="write">
			<cffile     action 		= "append" 
						file 		= "#this.logfile#" 
					    addnewline	= "true"
						output 		= "#arguments.content#"
						charset 	= "utf8" >
		
		</cfcase>
		<cfcase value="LogExists">
			<cftry>
			<!---- is it possible to read the file --->
			<cffile    	 action 		= "read" 
							file 		= "#this.logfile#" 
						    addnewline	= "true"
							variable = "ret">
			
				<!--- yes it exists --->
				<cfreturn true>
				
				<cfcatch type="any">
				<!--- no it does not exist  --->
				<cfreturn false>
				</cfcatch>
			</cftry>		
		<cfreturn false>			
		</cfcase>
		</cfswitch>
	</cfif>
	</cffunction>
	
	
	<cffunction name="dbLogAction" output="false" returntype="any" access="private" hint="does the cffile action">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="content" type="string" required="false" />
	
	<cfset var ret="" />
		<cfswitch expression=#arguments.action#>
		<cfcase value="read">
			<cfquery name="qryEventLogRead"  datasource="#APPLICATION.dsn#">
			select event, eventdate
			from tblEventLog
			where logname = '#this.dblogname#'
			and eventdate >  #CreateODBCDate(CreateDate(year(now()), month(now()), day(now())))#
			order by eventdate desc	
			</cfquery>
			
			<cfsavecontent variable="ret">
			<div style="font-size:10px; font-family: courier">
			<cfoutput>
			#this.dblogname# entries for #dateformat(now(), "dd/mm/yyyy")# </cfoutput><br />
			----------------------------------------------------------------------<br />
			<cfoutput query="qryEventLogRead">
			#timeformat(eventdate, "HH:MM:SS")#: #event# <br />
			</cfoutput>
			</div>
			</cfsavecontent>
			
			<cfreturn ret />
		</cfcase>
		<cfcase value="write">
			<cfquery name="qryEventLogWrite"  datasource="#APPLICATION.dsn#">
			insert into tblEventLog
			(logname, event, eventdate)
			values ('#this.dblogname#','#arguments.content#',<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />)
			</cfquery>	
		</cfcase>
		</cfswitch>
	</cffunction>
	
	</cfcomponent>