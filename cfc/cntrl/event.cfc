<!--- 
	Filename: 	 /cfc/cntrl/event.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Methods for control panel events
	Date: 
	Revisions:
--->

<cfcomponent output="false" name="event" displayname="event" hint="Methods for control panel events">


<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
//--- / Object declarations / ----------------------/
VARIABLES.customerEvents =  createObject("component", "cfc.cntrl.customers").init();
VARIABLES.prodEvents =  createObject("component", "cfc.cntrl.products").init();
VARIABLES.sageTests  =  createObject("component", "cfc.cntrl.sageTests").init();
return this;
</cfscript>
</cffunction> 

<cffunction name="request" access="public" returnType="any" output="false">
<cfargument name="evType" type="string" required="true" />
<cfargument name="evValue" type="string" required="true" />

<cfscript>
switch (arguments.evType) {
case "status":    				request.breadcrumb="Status -> #ARGUMENTS.evValue#";
								return status(ARGUMENTS.evValue);
																;			
								break; 		

case "customers":				request.breadcrumb="Customers -> #ARGUMENTS.evValue#";
								return evaluate("VARIABLES.customerEvents.#arguments.evValue#()");
								;
								break;
								
case "products": 				request.breadcrumb="Products -> #ARGUMENTS.evValue#";
								return evaluate("VARIABLES.prodEvents.#arguments.evValue#()");
    							;
								break;

case "tests":					request.breadcrumb="Tests -> #ARGUMENTS.evValue#";
								return evaluate("VARIABLES.sageTests.#arguments.evValue#()");
								;
								break;
								
default: 				request.breadcrumb="Home";		
						return "Holding Page";
											  ;
}

</cfscript>

</cffunction>


<cffunction name="requestXML" access="public" returnType="any" output="false">
<cfargument name="moduleid" type="string" required="true" />
<cfargument name="tabid" type="string" required="true" />

<cfscript>
switch (ARGUMENTS.moduleid) {
case "sage":    				//request.breadcrumb="Status -> #ARGUMENTS.evValue#";
								return summary();
																;			
								break; 		
case "content": 				return evaluate("VARIABLES.prodEvents.#arguments.tabid#()");
    							;
								break;								
default: 				request.breadcrumb="Home";		
						return "Holding Page";
											  ;
}

</cfscript>

</cffunction>


<cffunction name="summary" access="private" returnType="any" output="false">

<cfset var sageGW = createObject("component", "cfc.sagegw.sageWSGW")/>
<cfset var connectStatus = "Status: <span style='color: Green'>" & sageGW.AccountStatus() & "</span>"/>

<cfxml variable="myContent">
<cfoutput>
<div id="podWrappers">
#getPod("Sage Gateway", connectStatus, "sage-summary-gateway-status")#
#getPod("Configuration", sageGW.getConfig(), "sage-summary-gateway-config")#
</div>
</cfoutput>
</cfxml>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>

</cffunction>


<!--- *** STATUS Handler ***  --->
<cffunction name="status" access="private" returnType="any" output="false">
<cfargument name="evValue" type="string" required="true" />

<cfscript>
var Str="";
// get the sage Gateway
sageGW=createObject("component", "cfc.sagegw.sageWSGW");

switch (ARGUMENTS.evValue) {
case "current":    		Str="Status: <span style='color: Green'>" & sageGW.AccountStatus() & "</span>"; 
						//return Str;
						return getView("Sage Gateway", Str, "sage-summary-gateway-status");	
						break; 
case "disconnect": 		if (isdefined("form.fldSubmit")) {
						   	Str=sageGW.DisconnectForMaintenance(form.fldTimeout); 
					 	  	return getView(Str);	
						} else {
							return getForm("disconnect");	
						}		
							
						break; 	

default: 				request.breadcrumb="Home";		
						return "Holding Page";
											  ;
}

</cfscript>


</cffunction>

<cffunction name="getForm" access="private" returntype="string" outoutpu="false">
<cfargument name="formname" required="true" type="string" />


<cfswitch expression="#ARGUMENTS.formname#">
<cfcase value="disconnect">
	<cfxml variable="myContent">
	<cfoutput>
	<form id="frmdisconnect" name="frmdisconnect" method="post">
 		<span>Please specify the interval after which the Sage Web Service will reconnect:</span><br />
		<label for="fldTimeout">Reconnect time (minutes):</label> 
		<input type="text" id="fldTimeout" name="fldTimeout" size="2" /> 
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


<cffunction name="getPod" access="private" returnType="any" output="false">
<cfargument name="title" required="true" type="string" />
<cfargument name="str" required="true" type="string" />
<cfargument name="divid" required="false" type="string" default="" />
<cfxml variable="myContent">
<cfoutput>
<div class="pod" <cfif ARGUMENTS.divid neq "">id="#ARGUMENTS.divid#"</cfif>>
	<div class="podTitle">#ARGUMENTS.title#</div>
	<div class="podDescription">#ARGUMENTS.str#</div>
</div>
</cfoutput>
</cfxml>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>

</cffunction>

</cfcomponent>