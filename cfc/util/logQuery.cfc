<cfcomponent displayname="logQuery" hint="Log Query Utility" output="false">


<cfset VARIABLES.DSN = "" />
<cfset VARIABLES.LOGGER = "" />

<cffunction name="init" output="false" accesss="public" hint="component constructor" returntype="cfc.util.logQuery">
	<cfargument name="dsn" type="string" required="true" />
	<cfargument name="logger" type="cfc.util.abstractLogger" required="true" />
	<cfset VARIABLES.dsn = ARGUMENTS.dsn />
	<cfset VARIABLES.logger = ARGUMENTS.logger />
<cfreturn THIS/>
</cffunction>


<cffunction name="get" output="false" access="public" hint="searches for a string and returns all matching log records" returntype="string">
<cfargument name="days" required="false" default="1" hint="the number of days from today to search back from" />
<cfargument name="fromDate" required="false" hint="the date to search from" type="date" />
<cfargument name="toDate" required="false"  hint="the date to search from" type="date" />
<cfargument name="logType" required="false" default="" hint="the types of log to search for" type="string" />
<cfargument name="logText" required="false" default="" hint="the text to search for" type="string" />


<cfset var ret = "">
<cfset q = getLogResults(ARGUMENTS) />

<cfif isquery(q)>
	<cfsavecontent variable="ret">
		<cfloop query="q"><cfoutput>#LOGTYPE# #TS# #MESSAGE##chr(13)##chr(10)#</cfoutput></cfloop>
	</cfsavecontent>
<cfelse>
	<cfscript>VARIABLES.logger.error("getLogResults failed to return a query object!");</cfscript>
</cfif>

<cfreturn ret />

</cffunction>



<cffunction name="match" output="false" access="public" hint="searches for a string and returns matching text" returntype="string">
<cfargument name="days" required="false" default="1" hint="the number of days from today to search back from" />
<cfargument name="fromDate" required="false" hint="the date to search from" type="date" />
<cfargument name="toDate" required="false"  hint="the date to search from" type="date" />
<cfargument name="logType" required="false" default="" hint="the types of log to search for" type="string" />
<cfargument name="logText" required="false" default="" hint="the text to search for" type="string" />


<cfset var ret = "">
<cfset q = getLogResults(ARGUMENTS) />

	<cfif q.recordcount eq 1>
		<cfreturn q.message />
	<cfelse>
		<cfreturn "" />
	</cfif>
</cffunction>


<cffunction name="getLogResults" output="false" access="private" hint="returns a log query object" returntype="query">
<cfargument name="args" type="struct" required="true">


<cfscript>
var tsFrom = now();	
if (NOT isdefined("ARGUMENTS.args.fromDate")) {
	tsFrom = dateadd("d",(-1*ARGUMENTS.args.DAYS),now());
}

if (NOT isdefined("ARGUMENTS.args.toDate")) {
	tsTO = now();
}



var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var linebreak = "#chr(13)##chr(10)#";

</cfscript>


<cfquery name="myQry" datasource="#VARIABLES.dsn#" result="myQryRes">
SELECT LOGTYPE, TS, MESSAGE FROM tblLOG WHERE
<cfif ARGUMENTS.args.logType neq "">
LOGTYPE = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#UCASE(ARGUMENTS.args.LOGTYPE)#" /> AND 
</CFIF>
<cfif ARGUMENTS.args.logText neq "">
MESSAGE LIKE  <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#ARGUMENTS.args.LOGTEXT#%" /> AND		
</CFIF>
TS BETWEEN
<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#tsFrom#">
AND
<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#tsTo#">
ORDER BY ID ASC
</cfquery>

<cfreturn myQry/>

</cffunction>


</cfcomponent>





<!--- 
<cffunction name="search" output="false" access="public" hint="searches for a string and returns matching text" returntype="string">
<cfargument name="days" required="false" default="1" hint="the number of days from today to search back from" />
<cfargument name="fromDate" required="false" hint="the date to search from" type="date" />
<cfargument name="toDate" required="false"  hint="the date to search from" type="date" />
<cfargument name="logType" required="false" default="" hint="the types of log to search for" type="string" />
<cfargument name="logText" required="false" default="" hint="the text to search for" type="string" />



<cfscript>
var tsFrom = now();	
if (NOT isdefined("ARGUMENTS.fromDate")) {
	tsFrom = dateadd("d",(-1*ARGUMENTS.DAYS),now());
}

if (NOT isdefined("ARGUMENTS.toDate")) {
	tsTO = now();
}



var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var linebreak = "#chr(13)##chr(10)#";

</cfscript>

<cftry>	
<cfquery name="myQry" datasource="#VARIABLES.dsn#" result="myQryRes">
SELECT MESSAGE FROM tblLOG WHERE
<cfif ARGUMENTS.logType neq "">
LOGTYPE = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#UCASE(ARGUMENTS.LOGTYPE)#" />
				 AND 
</CFIF>
<cfif ARGUMENTS.logText neq "">
MESSAGE LIKE  <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#ARGUMENTS.LOGTEXT#%" /> AND		
</CFIF>
TS BETWEEN
<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#tsFrom#">
AND
<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#tsTo#">
</cfquery>


	
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	application.querylog.write("#timeformat(now(), 'H:MM:SS')# Query OK (#tickinterval# ms), count:#myQry.recordcount# SQL: #REreplace(rereplace(myQryRes.sql,'\s+',' ','ALL'), '/\r\n+|\r+|\n+|\t+/i', ' ', 'ALL')# params: #ArrayToList(myQryRes.sqlparameters)#");
	</cfscript>
	
	<cfif myQry.recordcount eq 1>
		<cfreturn myQry.message />
	<cfelse>
		<cfreturn myQryRes.sql/>	
	</cfif>
	
<cfcatch type="database">
	<cfrethrow />

	<cfreturn "" />
</cfcatch>
</cftry>



</cffunction>
 --->

