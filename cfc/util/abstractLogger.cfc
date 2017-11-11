<cfcomponent name="abstractLogger" displayname="logger interface" hint="logger interface" output="false">

<cfset VARIABLES.DSN = "" />

<cffunction name="init" output="false" accesss="public" hint="component constructor">
	<cfargument name="dsn" type="string" required="true" />
	<cfset VARIABLES.dsn = ARGUMENTS.dsn />
<cfreturn THIS/>
</cffunction>

<cffunction name="getDSN" access="private" returntype="string">
	<cfreturn VARIABLES.dsn />
</cffunction>


<cffunction name="info" output="false" access="public" hint="logs an info event">
	<cfargument name="MESSAGE" type="string" required="true" />
</cffunction>

<cffunction name="error" output="false" access="public" hint="logs an info event">
	<cfargument name="MESSAGE" type="string" required="true" />
</cffunction>


<cffunction name="fatal" output="false" access="public" hint="logs an info event">
	<cfargument name="MESSAGE" type="string" required="true" />
</cffunction>


<cffunction name="debug" output="false" access="public" hint="logs an info event">
	<cfargument name="MESSAGE" type="string" required="true" />
</cffunction>


</cfcomponent>