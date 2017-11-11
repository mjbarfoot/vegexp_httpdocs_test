<!--- 
	Filename: /cfc/departments/whereClauseHandler.cfc 
	Created by:  Matt Barfoot on 15/04/2006 Clearview Webmedia Limited
	Purpose:  Generates a safe where clause to use when querying the products database
--->


<cfcomponent name="whereClauseHandler" displayname="whereClauseHandler"  output="false" hint="Generates a safe where clause to use when querying the products database">

<!--- / Object declarations / --->
<cfscript>
</cfscript>

<cffunction name="init" output="false" access="public">

<cfreturn this> 

</cffunction>

<cffunction name="getClause" output="false" returntype="string" access="public">
<cfargument name="department_id" required="true" type="numeric" />

<cfscript>
var whereClause = "department = " & ARGUMENTS.department_id;

//If  categoryID is defined add it to the where clause
if (isdefined("url.categoryID") and url.CategoryID neq "ALL") {		
	whereClause = whereClause & " AND StockCategoryNumber = '" & safeUrlParam(url.CategoryID) & "'";
} 

if (session.shopper.prod_filter neq "All") {
	//use direct mapping between the prod_filter parameter and database column
	whereClause = whereClause & " AND #session.shopper.prod_filter# = True";	
}

return whereClause;
</cfscript>

</cffunction>

<cffunction name="getSearchClause" output="false" returntype="string" access="public">
<cfargument name="department_id" required="false" type="numeric" />


<cfscript>
var whereClause = "";

if (isdefined("ARGUMENTS.department_id")) {
	whereClause = "department = " & ARGUMENTS.department_id;
}

if (isdefined("url.pQ")) {
	if (len(whereClause)) {
	whereClause = whereClause & " AND ";
	}
	
	whereClause = whereClause & "(stockcode like '%#safeUrlParam(pQ)#%' OR description like '%#safeUrlParam(pQ)#%')";
} 

if (session.shopper.prod_filter neq "All") {
	if (len(whereClause)) {
	whereClause = whereClause & " AND ";
	}
	//use direct mapping between the prod_filter parameter and database column
	whereClause = whereClause & "#session.shopper.prod_filter# = True";	
}

return whereClause;
</cfscript>
</cffunction>


<cffunction name="safeUrlParam" output="false" returntype="string" access="public">
<cfargument name="paramValue" required="true" type="string" />

<cfreturn ReplaceList(ARGUMENTS.paramValue, "^,[,<,>,`,~,!,/,@,\,##,},$,%,:,;,),(,_,^,{,&,*,=,|,',+,],+,$", " , , , , , , , , , , , , , , , , , , , , ,")>

</cffunction>

</cfcomponent>