<!--- 
	Component: util.cfc
	File: /cfc/cntrl/util.cfc
	Description: utility functions for control panel
	Author: Matt Barfoot
	Date: 20/11/20006
	Revisions:
	--->
	
<cfcomponent name="util" displayname="util" output="false" hint="utility functions">


<cffunction name="file" description="cffile actions" access="public" output="false" returntype="any">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="myFileName" type="string" required="false" default="" />
	<cfargument name="myFormField" type="string" required="false" default="" />

<cfswitch expression="#lcase(ARGUMENTS.action)#">
<cfcase value="upload">
		<!--- UPLOAD THE FILE TO THE SERVER --->
		<cffile action="upload"
		destination="#APPLICATION.var_DO.getVar('TempDir')#"
		nameConflict="overwrite"
		fileField="#ARGUMENTS.myFormField#" />

	<cfreturn cffile />	
</cfcase>
<cfcase value="read">
	<cffile action="read" file="#APPLICATION.var_DO.getVar('TempDir')#/#ARGUMENTS.myFileName#" variable="myReadFile" />
	<cfreturn myReadFile>
</cfcase>
<cfdefaultcase>
	<cfreturn "No action specified - nothing to do ... ">
</cfdefaultcase>
</cfswitch>
</cffunction>


<cffunction name="dump" description="cfdump" access="public" output="true" returntype="any">
<cfargument name="var2Dump" type="any" required="true" />
	<cfsavecontent variable="myDump">
	<cfdump var=#ARGUMENTS.var2Dump# />
	</cfsavecontent>
	<cfreturn myDump />
</cffunction>

</cfcomponent>