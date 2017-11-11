<cfcomponent output="false">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="CronJobID" type="numeric" default="0">
	<cfproperty name="CronJobName" type="string" default="">
	<cfproperty name="CronJobDesc" type="string" default="">
	<cfproperty name="CronJobFile" type="string" default="">
	<cfproperty name="CronStatus" type="string" default="">
	<cfproperty name="Frequency" type="numeric" default="0">
	<cfproperty name="FreqUnit" type="string" default="">
	<cfproperty name="LastRun" type="date" default="">
	<cfproperty name="NextRun" type="date" default="">

	<cfscript>
		//Initialize the CFC with the default properties values.
		variables.CronJobID = 0;
		variables.CronJobName = "";
		variables.CronJobDesc = "";
		variables.CronJobFile = "";
		variables.CronStatus = "";
		variables.Frequency = 0;
		variables.FreqUnit = "";
		variables.LastRun = "";
		variables.NextRun = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="tblCronScheduleWiz">
		<cfreturn this>
	</cffunction>
	<cffunction name="getCronJobID" output="false" access="public" returntype="any">
		<cfreturn variables.CronJobID>
	</cffunction>

	<cffunction name="setCronJobID" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.CronJobID = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<cffunction name="getCronJobName" output="false" access="public" returntype="any">
		<cfreturn variables.CronJobName>
	</cffunction>

	<cffunction name="setCronJobName" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.CronJobName = arguments.val>
	</cffunction>

	<cffunction name="getCronJobDesc" output="false" access="public" returntype="any">
		<cfreturn variables.CronJobDesc>
	</cffunction>

	<cffunction name="setCronJobDesc" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.CronJobDesc = arguments.val>
	</cffunction>

	<cffunction name="getCronJobFile" output="false" access="public" returntype="any">
		<cfreturn variables.CronJobFile>
	</cffunction>

	<cffunction name="setCronJobFile" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.CronJobFile = arguments.val>
	</cffunction>

	<cffunction name="getCronStatus" output="false" access="public" returntype="any">
		<cfreturn variables.CronStatus>
	</cffunction>

	<cffunction name="setCronStatus" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.CronStatus = arguments.val>
	</cffunction>

	<cffunction name="getFrequency" output="false" access="public" returntype="any">
		<cfreturn variables.Frequency>
	</cffunction>

	<cffunction name="setFrequency" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Frequency = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>

	<cffunction name="getFreqUnit" output="false" access="public" returntype="any">
		<cfreturn variables.FreqUnit>
	</cffunction>

	<cffunction name="setFreqUnit" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.FreqUnit = arguments.val>
	</cffunction>

	<cffunction name="getLastRun" output="false" access="public" returntype="any">
		<cfreturn variables.LastRun>
	</cffunction>

	<cffunction name="setLastRun" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsDate(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.LastRun = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid date"/>
		</cfif>
	</cffunction>

	<cffunction name="getNextRun" output="false" access="public" returntype="any">
		<cfreturn variables.NextRun>
	</cffunction>

	<cffunction name="setNextRun" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsDate(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.NextRun = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid date"/>
		</cfif>
	</cffunction>



</cfcomponent>