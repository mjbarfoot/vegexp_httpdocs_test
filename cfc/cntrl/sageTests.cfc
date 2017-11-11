<!--- 
	Filename: 	 /cfc/cntrl/sageTests.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Methods for product related control panel events
	Date: 		 29/09/2006
	Revisions:
--->

<cfcomponent output="false" name="event" displayname="event" hint="Methods for control panel events">

<!--- / Object declarations / --->
<cfscript>
VARIABLES.cntrl_do 	= createObject("component", "cfc.cntrl.do"); 
// get the sage Gateway
VARIABLES.sageGW=createObject("component", "cfc.sagegw.sageWSGW");
</cfscript>

<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript> 
return this;
</cfscript>
</cffunction> 

<!--- *** GetCustomerList LIST *** --->
<cffunction name="ListCustomersByPartialPostcode" access="public" returnType="any" output="false">
<cfscript>
var Str="";
if (isdefined("form.fldSubmit")) {
Str = VARIABLES.sageGW.ListCustomersByPartialPostcode(form.postcode);
return HTMLEditFormat(trim(Str));	
} else {
Str = getForm("Postcode");	
return Str;	
}
</cfscript>
</cffunction>


<!--- *** GetCustomerList LIST *** --->
<cffunction name="PlaceSalesOrder" access="public" returnType="any" output="false">
<cfscript>
var Str="";
Str = VARIABLES.sageGW.testSalesOrder();
return HTMLEditFormat(trim(Str));
</cfscript>
</cffunction>


<cffunction name="CancelSalesOrder" access="public" returnType="any" output="false">
<cfscript>
var Str="";
if (isdefined("form.fldSubmit")) {
Str = VARIABLES.sageGW.CancelSalesOrder(form.OrderNumber);
return HTMLEditFormat(trim(Str));	
} else {
Str = getForm("OrderNumber");	
return Str;	
}
</cfscript>
</cffunction>

<!--- <cffunction name="DeleteSalesOrder" access="public" returnType="any" output="false">
<cfscript>
var Str="";
if (isdefined("form.fldSubmit")) {
Str = VARIABLES.sageGW.DeleteSalesOrder(form.OrderNumber);
return HTMLEditFormat(trim(Str));	
} else {
Str = getForm("OrderNumber");	
return Str;	
}
</cfscript>
</cffunction>
 --->


<!--- *** GetCustomerList LIST *** --->
<cffunction name="ListCustomers" access="public" returnType="any" output="false">

<cfscript>
var Str="";
Str = VARIABLES.sageGW.ListCustomers();
return HTMLEditFormat(trim(Str));
</cfscript>

</cffunction>


<cffunction name="getForm" access="private" returntype="string" outoutpu="false">
<cfargument name="formname" required="true" type="string" />

<cfswitch expression="#ARGUMENTS.formname#">
<cfcase value="postcode">
	<cfxml variable="myContent">
	<cfoutput>
	<form id="frmPartPostcode" name="frmPartPostcode" method="post">
 		<span>Please specify a partial postcode:</span><br />
		<label for="postcode">Partial Postcode:</label> 
		<input type="text" id="postcode" name="postcode" size="8" /> 
		<input type="submit" id="fldSubmit" name="fldSubmit" value="submit" />		
		</form> 
	</cfoutput>
	</cfxml>
</cfcase>
<cfcase value="OrderNumber">
	<cfxml variable="myContent">
	<cfoutput>
	<form id="frmOrderNumber" name="frmOrderNumber" method="post">
 		<span>Please specify an OrderNumber:</span><br />
		<label for="OrderNumber">OrderNumber:</label> 
		<input type="text" id="OrderNumber" name="OrderNumber" size="8" /> 
		<input type="submit" id="fldSubmit" name="fldSubmit" value="submit" />		
		</form> 
	</cfoutput>
	</cfxml>
</cfcase>
<cfdefaultcase>
<!--- nothing --->
</cfdefaultcase>
</cfswitch>


<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>

</cffunction>



</cfcomponent>