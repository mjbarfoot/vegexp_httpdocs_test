<!--- 
	Filename: /cfc/cntrl/do.cfc 
	Created by:  Matt Barfoot on 15/04/2006 Clearview Webmedia Limited
	Purpose:  Administrative data object for CRUD operations
--->

<cfcomponent name="do" displayname="do"  output="false" hint="Administrative data object for CRUD operations">

<!--- / Object declarations / --->
<cfscript>
util 	= createObject("component", "cfc.shop.util");
</cfscript>

<cffunction name="setCategoryDisabled" output="false" returntype="void" access="public">
<cfargument name="categoryid" required="true"  type="string" />
<cfargument name="disabled" required="true"  type="numeric" />

<cfquery name="qrySetCategoryEnabled"  datasource="#APPLICATION.dsn#">
UPDATE tblCategory
SET DISABLED = #ARGUMENTS.Disabled#
WHERE CategoryID = #ARGUMENTS.categoryid#
</cfquery>

</cffunction>

<cffunction name="updateEmail" output="false" returntype="string" access="public">
<cfargument name="AccountID" type="string" required="true" />
<cfargument name="emailAddress" type="string" required="true" />

<cfquery name="qryChkAccount"  datasource="#APPLICATION.dsn#">
SELECT firstname, lastname, company 
FROM tblUsers
WHERE AccountID = '#trim(ARGUMENTS.AccountID)#'
</cfquery>

<cfif qryChkAccount.recordcount eq 1>
	<cfquery name="qryUpdateEmail"  datasource="#APPLICATION.dsn#">
	UPDATE tblUsers
	SET emailAddress = '#ARGUMENTS.emailAddress#'
	WHERE AccountID = '#ARGUMENTS.AccountID#'
	</cfquery>

<cfreturn "<span style='color:Navy;font-weight:bold'>Successfully updated email address to #ARGUMENTS.emailAddress# for #qryChkAccount.firstname# #qryChkAccount.lastname# of #qryChkAccount.company#" />	
<cfreturn>

<cfelse>
	<cfreturn "<span style='color:red'>AccountID: #trim(ARGUMENTS.AccountID)# not found, please try again</span>" />
</cfif>

</cffunction>




</cfcomponent>