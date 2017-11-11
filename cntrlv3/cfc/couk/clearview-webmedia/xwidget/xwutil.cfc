<!--- 
	Component: xwutil.cfc
	File: /cfc/xwtable/xwutil.cfc
	Description: utility functions
	Author: Matt Barfoot
	Date: 02/04/20006
	Revisions:
	--->
	
<cfcomponent name="xwutil" displayname="xwutil" output="false" hint="xWidget utility functions">
	
<!--- Utility functions --->
<cffunction name="parsedQS" access="public" returntype="string" output="false">
<cfargument name="allowedParams" type="string" required="true" default="false" />
<cfargument name="xmlFormat" type="boolean" required="false" default="false" />
<cfscript>
/* Supercedes original parseQS below. (Note: Keep for reference)
- Original filter worked by removing specified parameters.

- This filter will work by using the allowedParams argument containing a list of keys 
which can be contained with the querystring. 
*/
var qS = ""; // the new query string we are constructing
var aP = ARGUMENTS.allowedParams;

// if no allowed parameters are specified, return an empty string
if (NOT len(aP)) {
return "";	
} else {
	for (i=1; i lte listlen(aP); i=i+1) { //iterate over allowed params
		// if an allowed param is found
		if (findNocase(listGetAt(aP,i),cgi.query_string)) {
			qs = qs & "&" & listGetAt(cgi.query_string, listContainsNoCase(cgi.query_string, listGetAt(aP,i),"&"), "&");
			//qS = listDeleteAt(qS, listContainsNoCase(qS, listGetAt(aP,i),"&"));
		}		
	}
	//return and format for xml if set
	return IIF(ARGUMENTS.xmlFormat, DE(xmlformat(qS)), DE(qS));
}
</cfscript>
</cffunction>


<cffunction name="parsedQS_orig" access="public" returntype="string" output="false">
<cfargument name="xmlFormat" type="boolean" required="false" default="false" />
<cfscript>
var qS = cgi.QUERY_STRING;
var qS_list="";
var qS_substring="";
	
	//remove any url parameters used in the table because they are generated again
	if (listlen(qS, "&") neq 0) {
		//iterate through the querystring
		for (i=1; i LTE listlen(qS, "&"); i=i+1) {
			//extract the url parameter at this position in the list
			qs_substring=ListGetAt(qS, i, "&"); 
			
			// if it contains one of a set of url parameters delete it from the query string
			if (FindNoCase("tblreset=", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}	
			
			if (FindNoCase("tblchangepg", qs_substring) neq 0) {
					qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}	
			
			if (FindNoCase("tblsort=", qs_substring) neq 0) {
					qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}	
		
			if (FindNoCase("tblfilter=", qs_substring) neq 0) {
					qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("pageid=", qs_substring) neq 0) {
					qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("ev=basket", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}	
			
			if (FindNoCase("action=Expand", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("action=Contract", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}			
		
			if (FindNoCase("action=Add", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			
			if (FindNoCase("action=enable", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("action=disable", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("categoryid=", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			
			if (FindNoCase("ProductID=", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			//filter search parameter removed. This is different from 
			//the other searches because it is case sensitive. 
			if (Find("q=", qs_substring) neq 0) {
					qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
				
		}	
		
	}

		
	if (qS_list neq "") {
	qS=replace(qS, qS_list,"");
	} 
	
	//replace the question mark
	qS=replace(qS, "?", "");
	
	//is is just purely a question mark
	if (left(qS, 1) eq "&") {
		qS=replace(qS, "&", ""); //replace the first occurence only
	}

	//format for XML?
	if (ARGUMENTS.xmlFormat) {
	qS=replace(qS, "&", "&amp;", "ALL");	
	}
//return "#trim(qS)#";

return qS;
</cfscript>
</cffunction>

<cffunction name="throw" access="public">
<cfargument name="detail" type="string">

<cfthrow detail="#ARGUMENTS.detail#">

</cffunction>

<cffunction name="location" access="public">
<cfargument name="url" type="string" />
<cfargument name="query_String" type="string" />

<cfif ARGUMENTS.query_string neq "?">
	<cflocation url="#ARGUMENTS.url#?#parsedQS()#" addtoken="false">
<cfelse>
	<cflocation url="#ARGUMENTS.url#" addtoken="false">
</cfif>

</cffunction>

<cffunction name="encode_TH_ID" access="public" returntype="string" output="false">
<cfargument name="strIn" type="string" required="true">
<cfset var strOut =  ""/>
<cfset strOut = ReReplace(ARGUMENTS.strIn, "`", "", "ALL")/>
<cfset strOut = replace(strOut, " ", "--", "ALL") />
<cfreturn strOut>
</cffunction>

<cffunction name="decode_TH_ID" access="public" returntype="string" output="false">
<cfargument name="strIn" type="string" required="true">
<cfset var strOut =""/>
<cfset strOut = replace(ARGUMENTS.strIn, "--", " ", "ALL") />
<cfreturn strOut>	
</cffunction>	
	
</cfcomponent>