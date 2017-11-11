<cfcomponent displayname="registrationBean" hint="contains details about the status of a user registration" output="false">

<!---
constructor - returns an instance of this class
@return an instance of this class
--->
<cffunction name="init" output="false" access="public" returntype="cfc.security.registrationBean" hint="constructor">
<cfscript>initVars();</cfscript>
<cfreturn THIS />
</cffunction>

<cffunction name="initVars" output="false" access="public" returntype="void" hint="intialises vars">
<cfscript>
VARIABLES.instance.status = 0;
VARIABLES.instance.message="";
VARIABLES.instance.isComplete=false;
</cfscript>
</cffunction>

<cffunction name="getMessage" output="false" access="public" returntype="string" hint="returns a message set by the registraiton process for the user">

<cfreturn VARIABLES.instance.message />
</cffunction>

<cffunction name="setMessage" output="false" access="public" returntype="boolean" hint="sets the message to be returned to the user">
<cfargument name="message" type="string" required="true" hint="the message to set">
<cfset VARIABLES.instance.message=ARGUMENTS.message />
<cfreturn true/>
</cffunction>

<cffunction name="getStatus" output="false" access="public" returntype="numeric" hint="provides a numerical status indicator: 0 started, 1 - saved, 2 - sent to sage, 3 - complete">

<cfreturn VARIABLES.instance.status/>
</cffunction>

<cffunction name="setStatus" output="false" access="public" returntpe="boolean" hint="sets numerical status indicating progress of registration">
<cfargument name="status" type="numeric" required="true" hint="status indicator as a numeric value ">
<cfset VARIABLES.instance.status=ARGUMENTS.status />
<cfreturn true/>
</cffunction>

<cffunction name="setIsComplete" output="false" access="public" returntype="boolean" hint="sets the isComplete flag">
<cfargument name="isComplete" type="boolean" required="true" hint="whether the registration is complete">
<cfset VARIABLES.instance.isComplete=ARGUMENTS.isComplete>
<cfreturn true/>
</cffunction>

<cffunction name="isComplete" output="false" access="public" returntype="boolean" hint="returns true if the registration is complete">

<cfreturn VARIABLES.instance.isComplete />

</cffunction>

</cfcomponent>