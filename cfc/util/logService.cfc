<cfcomponent name="logService" displayname="logService" hint="logService" output="false">

<cfset VARIABLES.dblogger = "" />
<cfset VARIABLES.logQuery = "" />
<cfset VARIABLES.dsn  = "" />

<cffunction name="init" output="false" returntype="cfc.util.logService" hint="constructor for log service">
<cfargument name="dsn" type="string" required="true" />

	<cfset VARIABLES.dsn = ARGUMENTS.dsn />
	<cfset VARIABLES.dblogger = createObject("dblogger").init(VARIABLES.dsn) />
	<cfset VARIABLES.logQuery = createObject("logQuery").init(VARIABLES.dsn, VARIABLES.dblogger) />
	<Cfreturn this />
</cffunction>


<cffunction name="get" output="false" returntype="Any"  hint="attempts to return requested object">
<cfargument name="componentName" required="true" type="string" />
<cfif isdefined("VARIABLES.#ARGUMENTS.componentName#") AND IsObject(evaluate("VARIABLES." & ARGUMENTS.componentName))>
	<cfreturn evaluate("VARIABLES." & ARGUMENTS.componentName) />
</cfif>
</cffunction>

</cfcomponent>