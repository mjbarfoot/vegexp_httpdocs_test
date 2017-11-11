<cfcomponent output="false">

	<cffunction name="getById" output="false" access="remote">
		<cfargument name="id" required="true" />
 		<cfreturn createObject("component", "tblCronScheduleDAOWiz").read(arguments.id)>
	</cffunction>


	<cffunction name="save" output="false" access="remote">
		<cfargument name="obj" required="true" />
 		<cfscript>
			if( obj.getCronJobID() eq 0 )
			{
				return createObject("component", "tblCronScheduleDAOWiz").create(arguments.obj);
			} else {
				return createObject("component", "tblCronScheduleDAOWiz").update(arguments.obj);
			}
		</cfscript>
	</cffunction>


	<cffunction name="deleteById" output="false" access="remote">
		<cfargument name="id" required="true" />
		<cfset var obj = getById(arguments.id)>
		<cfset createObject("component", "tblCronScheduleDAO").delete(obj)>
	</cffunction>



	<cffunction name="getAll" output="false" access="remote" returntype="cfc.data.tblCronSchedule[]">
		<cfset var qRead="">
		<cfset var obj="">
		<cfset var ret=arrayNew(1)>

		<cfquery name="qRead" datasource="veappdata">
			select CronJobID
			from tblCronSchedule
		</cfquery>

		<cfloop query="qRead">
		<cfscript>
			obj = createObject("component", "tblCronScheduleDAO").read(qRead.CronJobID);
			ArrayAppend(ret, obj);
		</cfscript>
		</cfloop>
		<cfreturn ret>
	</cffunction>



	<cffunction name="getAllAsQuery" output="false" access="remote" returntype="query">
		<cfargument name="fieldlist" default="*" hint="List of columns to be returned in the query.">

		<cfset var qRead="">

		<cfquery name="qRead" datasource="veappdata">
			select #arguments.fieldList#
			from tblCronSchedule
		</cfquery>

		<cfreturn qRead>
	</cffunction>




</cfcomponent>