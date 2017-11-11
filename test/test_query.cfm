<cfset logtype = "INFO" />
<cfset logtext = "ACK">
<cfset tsFrom = now() - 1 />
<cfset tsTo = now() />
<cfset variables.dsn = "vegexp_mysql">

<cfquery name="myQry" datasource="#VARIABLES.dsn#" result="myQryRes">
SELECT MESSAGE FROM tblLOG WHERE
<cfif logType neq "">
LOGTYPE = '#UCASE(LOGTYPE)#' AND 
</CFIF>
<cfif logText neq "">
MESSAGE LIKE '%#LOGTEXT#%' AND		
</CFIF>
TS BETWEEN
<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#tsFrom#">
AND
<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#tsTo#">
</cfquery>

<cfdump var="#myQryRes#">