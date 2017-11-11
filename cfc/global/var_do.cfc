<!--- 
	Filename: 	 /cfc/globar/var_do.cfm 
	Created by:  Matt Barfoot- Clearview Webmedia Limited
	Purpose:     Sets and Gets Vars for the systems
	Date: 		 05/07/2006
	Revisions:
--->

<cfcomponent output="false" name="vars" displayname="vars" hint="">
	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//

// get the ...
//VARIABLES.myObject=createObject("component", "cfc.myObject.myObject").init();

//return a copy of this object
return this;
</cfscript>
</cffunction> 

 <!--- *** get METHOD *** --->
<cffunction name="getVar" access="public" returntype="any" output="false">
<cfargument name="varName" type="string" required="true" />

<cftry>
	<cfquery name="qryGetVar" datasource="#APPLICATION.dsn#">
	SELECT varValue
	FROM tblGlobalVars 
	WHERE varName =  '#ARGUMENTS.varName#'
	AND UCASE(SERVER_NAME) = '#UCASE(CGI.SERVER_NAME)#'
	</cfquery>

	<cfif qryGetVar.recordcount eq 1>
		<cfreturn qryGetVar.varValue />
	<cfelse>
		<cfreturn "" />
	</cfif>	
<cfcatch type="database">
		<cfreturn "" />
</cfcatch>
</cftry>	

</cffunction>

 <!--- *** set METHOD *** --->
<cffunction name="setVar" access="public" returntype="any" output="false">
<cfargument name="varName" 	type="string" required="true" />
<cfargument name="varValue" type="string" required="true" />
<cftry>
	<cfquery name="qrySetVar" datasource="#APPLICATION.dsn#">
	UPDATE  tblGlobalVars
	SET varValue = '#ARGUMENTS.varValue#'
	WHERE varName = '#ARGUMENTS.varName#'
	AND UCASE(SERVER_NAME) = '#UCASE(CGI.SERVER_NAME)#'
	</cfquery>
	
	<cfreturn true />
<cfcatch type="database">
	<cfreturn false />
</cfcatch>
</cftry>

</cffunction>


</cfcomponent>