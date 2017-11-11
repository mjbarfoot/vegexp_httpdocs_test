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
</cfcomponent>