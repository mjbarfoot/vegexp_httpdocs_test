<!--- 
	Component: xwtable_do.cfc
	File: /cfc/request.xwtable/request.xwtable_do.cfc
	Description: Builds a query based upon supplied parameters
	Author: Matt Barfoot
	Date: 02/04/20006
	Revisions:
	--->

<cfcomponent name="request.xwtable_do" displayname="request.xwtable_do" output="false" hint="builds a sql query for request.xwtable">

<cffunction name="doQuery" access="public" hint="performs a sql query against the specified dsn">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
//grab the query columns 
var query_columns		 =request.xwtable.getValue(arguments.tblname, "querycolumnprimarykey") & "," & request.xwtable.getValue(arguments.tblname, "querycolumnlist");
var query_dsn 	 		 =request.xwtable.getValue(arguments.tblname, "query.dsn");
var query_table	 		 =request.xwtable.getValue(arguments.tblname, "query.table");
var wherestatement 		 =request.xwtable.getValue(arguments.tblname, "wherestatement");  
var wherecol			 =request.xwtable.getValue(arguments.tblname, "wherecol");  
var whereclause 		 =request.xwtable.getValue(arguments.tblname, "whereclause");  
var sortcol				 =request.xwtable.getValue(arguments.tblname, "sortcol");  
var sortorder			 =request.xwtable.getValue(arguments.tblname, "sortorder");  
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
</cfscript>
	


	<cfquery name="myTableQuery"  datasource="#query_dsn#">
	SELECT 
	<!---loop through the header rows ommiting anything matching custom--->
	<cfloop from="1" to="#listlen(query_columns)#" index="listpos">
		<!---check not last column in column list, if so trail with a comma --->
		<cfif listpos neq listlen(query_columns)>
		#ListGetAt(query_columns, listpos)#,
		<cfelse> <!---last in column list, no comma--->
		#ListGetAt(query_columns, listpos)#
		</cfif>	
	</cfloop>
	FROM #query_table#
	<!---WHERE CLAUSE: rudimentary handling of where statement, clause and column--->
	<cfif wherestatement neq "">
	WHERE #PreserveSingleQuotes(wherestatement)# 
	</cfif>
	<cfif wherestatement eq "" AND wherecol neq "" AND whereclause neq "">
	WHERE #wherecol# LIKE '%#whereclause#%'
	<cfelseif wherestatement neq "" AND wherecol neq "" AND whereclause neq "">
	AND #wherecol# LIKE '%#whereclause#%'
	</cfif>
	<!---ORDER BY CLAUSE---->
	<cfif sortcol neq "">
	ORDER BY #sortcol# #sortorder#
	</cfif>
	</cfquery>

<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
application.querylog.write("#timeformat(now(), 'H:MM:SS')#	Query on tlbProducts for xwtable #tblname# completed in #tickinterval# ms");
querytxt="#timeformat(now(), 'H:MM:SS')#	Query parameters	Wherestatment:  #wherestatement# wherecol: #wherecol# whereclause: #whereclause#";
application.querylog.write(querytxt);
</cfscript>

<cfreturn myTableQuery>
</cffunction>

</cfcomponent>	