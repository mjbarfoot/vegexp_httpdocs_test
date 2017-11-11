<cfcomponent name="dblogger" extends="cfc.util.abstractLogger" displayname="dblogger" hint="writes logs to the ve app db table" output="false">

<cfset VARIABLES.maxmessagelength=250/>
<cfset VARIABLES.cronTaskList =""  />


<cffunction name="init" output="false" accesss="public" hint="component constructor">
	<cfargument name="dsn" type="string" required="true" />
	<cfscript>
	SUPER.init(ARGUMENTS.DSN);
	</cfscript>
	<cfset VARIABLES.cronTaskList = getCronTaskList()  /> 
<cfreturn THIS/>
</cffunction> 




<cffunction name="getCronTaskList" access="private" output="false" returntype="string">
	<cfset ret = ArrayNew()/>
	<cfquery name="myQry" datasource="#VARIABLES.dsn#">
		select taskname from tblCrontask order by id
	</cfquery>
	
	<cfset temp = ArraySet(ret, 1,myQry.recordcount, "")> 
	
	<cfloop query="myQry">
		<cfset ret[currentrow] = "#taskname#"/>
	</cfloop>
	
<!--- 	<cfscript>APPLICATION.APPLOG.WRITE("CronTaskList:" & ArrayToList(ret));</cfscript> --->
	<cfreturn ArrayToList(ret) />
	
</cffunction>

<cffunction name="info" output="false" access="public" hint="logs an info event" returntype="void">
	<cfargument name="MESSAGE" type="string" required="true" />
	<cfscript>
	commit("INFO", left(message,VARIABLES.maxmessagelength));
	</cfscript>
</cffunction>

<cffunction name="error" output="false" access="public" hint="logs an info event" returntype="void">
	<cfargument name="MESSAGE" type="string" required="true" />
	<cfscript>
	commit("ERROR", left(message,VARIABLES.maxmessagelength));
	</cfscript>
</cffunction>


<cffunction name="fatal" output="false" access="public" hint="logs an info event" returntype="void">
	<cfargument name="MESSAGE" type="string" required="true" />
	<cfscript>
	commit("FATAL", left(message,VARIABLES.maxmessagelength));
	</cfscript>
</cffunction>


<cffunction name="debug" output="false" access="public" hint="logs an info event" returntype="void">
	<cfargument name="MESSAGE" type="string" required="true" />
	<cfscript>
	commit("DEBUG", left(message,VARIABLES.maxmessagelength));
	</cfscript>
</cffunction>


<cffunction name="cron" output="false" access="public" hint="logs cron messages" returntype="void">
	<cfargument name="TASKNAME" type="string" required="true" />
	<cfargument name="MESSAGE" type="string" required="true" />
		<cfif listFind(ucase(VARIABLES.cronTaskList), ucase(ARGUMENTS.TASKNAME)) neq 0>
			<cfscript>commit("#ucase(ARGUMENTS.TASKNAME)#", left(message,VARIABLES.maxmessagelength));</cfscript>
		</cfif>
</cffunction>



<cffunction name="commit" output="false" access="private" hint="commits log to database" returntype="void">
<cfargument name="LOGTYPE" type="string" required="true" />
<cfargument name="MESSAGE" type="string" required="true" />

<cftry>
	<cfquery name="myQry" datasource="#VARIABLES.dsn#">
	INSERT INTO tblLOG (LOGTYPE, TS, MESSAGE) VALUES ('#ARGUMENTS.LOGTYPE#', <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">, '#ARGUMENTS.MESSAGE#')
	</cfquery>
<cfcatch type="database">
	<cfrethrow />

	<cfreturn false />
</cfcatch>
</cftry>


</cffunction>



</cfcomponent>