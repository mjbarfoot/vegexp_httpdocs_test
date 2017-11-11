<!--- 
	Component: util.cfc
	File: /cfc/xwtable/xwutil.cfc
	Description: utility functions
	Author: Matt Barfoot
	Date: 23/04/20006
	Revisions:
	--->
	
<cfcomponent name="util" displayname="util" output="false" hint="utility functions">
	
<!--- Utility functions --->
<cffunction name="throw" access="public">
<cfargument name="detail" type="string">

<cfthrow detail="#ARGUMENTS.detail#">

</cffunction>

<cffunction name="location" access="public">
<cfargument name="url" type="string" required="true" />
	
	<cfif len(ARGUMENTS.url) eq 0>
		<cfset ARGUMENTS.url eq "index.cfm" />
	</cfif>

	<cflocation url="#ARGUMENTS.url#" addtoken="false">

</cffunction>	

<cffunction name="include" access="public">
<cfargument name="pathToTemplate" type="string" required="true" />

	<cfinclude template="#ARGUMENTS.pathToTemplate#" />

</cffunction>	

<cffunction name="flush" access="public">
	
	<cfflush />
	
</cffunction>

<cffunction name="splitByCR" access="public" returntype="array" output="false">
<cfargument name="str" type="string" required="true" hint="the string containing chr(13)">
<cfscript>
var myStringArray = ArrayNew(1);
// replace chr(10) - linefeed, we are only interested in chr(13) -  Carriage returns
var myChoppedString = replace(ARGUMENTS.str, chr(10), "", "ALL");
var i=1;

//test for existence
if (find(chr(13), ARGUMENTS.str) neq 0) {

//chop up string and apend to array until no more chr(13)s are found, replace chr(10)s
	do  {
	 	//grab all the text up the CR 
	 	myStringArray[i] = left(myChoppedString, (find(chr(13), myChoppedString)-1));
			//trim off the text we just used, ignoring the CR
			myChoppedString = mid(myChoppedString, (find(chr(13), myChoppedString)+1), len(myChoppedString));
			i = i + 1;	
	} while (find(chr(13), myChoppedString) neq 0);

// finished chopping, but see if there is some part of the string left over
	if (len(myChoppedString) gte 1) {
		myStringArray[i] = myChoppedString;
	}
	
	return myStringArray;
} 
// no chr(13) found return empty string	
	else {
return myStringArray;	
}
</cfscript>
</cffunction>

<cffunction name="wddx2cfml" access="public" returntype="any">
<cfargument name="input" required="true" type="string" />

<cfwddx action = "wddx2cfml" input = #ARGUMENTS.input# output = "out">

<cfreturn out />
</cffunction>

<cffunction name="abort" access="public" returntype="void">
	
	<cfabort />
	
</cffunction>

<cffunction name="dump" access="public" output="true" returntype="void">
<cfargument name="dumpvar" required="true" type="any">	
	
	<cfdump var="#ARGUMENTS.dumpvar#">
	
</cffunction>



<cfscript>
/**
 * Function to duplicate the <cfparam> tag within CFSCRIPT.
 * Rewritten by RCamden
 * V2 mods by John Farrar
 * 
 * @param varname 	 The name of the variable. 
 * @param value 	 The default value. If not passed, use  
 * @return Returns the value of the variable parammed. 
 * @author Fred T. Sanders (fred@fredsanders.com) 
 * @version 2, November 13, 2001 
 */
function cfparam(varname) {
	var value = "";
	
	if(arrayLen(Arguments) gt 1) value = Arguments[2];
	if(not isDefined(varname)) setVariable(varname,value);
        return evaluate(varname);
}
</cfscript>


</cfcomponent>