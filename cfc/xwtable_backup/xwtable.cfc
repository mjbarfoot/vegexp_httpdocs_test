<!--- 
	Component: xwtable.cfc
	File: xwtable.cfc
	Description: Holds a table model
	Author: Matt Barfoot
	Date: 24/02/2006
	Revisions:
	02/04/2006 -----------------------------------------------
	1) Renamed xwtable : xWidget table
	2) split cfc: myxwtable (model) xwtable (controller) xwtable_factory (view) so that ajax calls 
	to the controller can reference any table stored in session scope
	--->
<cfcomponent name="xwtable" displayname="table"  output="false" hint="xWidget table controller">

<!--- / Object declarations / --->
<cfobject component="cfc.xwtable.xwutil" 			name="xwutil">
<cfobject component="cfc.xwtable.xwtable_do" 		name="xwtable_do">
 

<cffunction name="init" access="public" output="false" hint="creates an xWidget table">
<cfargument name="tblname" required="true" type="string" />
	<cfscript>
	if (not isdefined("session.xwtable.#arguments.tblname#")) {
	"session.xwtable.#arguments.tblname#" = createObject("component", "cfc.xwtable.myxwtable").init(arguments.tblname);		
	}	
	
	return this;
	</cfscript>
</cffunction>

<cffunction name="loadDesign" access="public" output="true" hint="loads a table design to make the table from">
<cfargument name="tblname" required="true" type="string" />
<cfargument name="design" required="true" type="string" />
<cfinclude template="design-#arguments.design#.cfm" />
</cffunction>


<cffunction name="reset" access="private" output="false" hint="resets table">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
evaluate("StructDelete(SESSION.xwtable, """ & arguments.tblname & """)");
xwutil.location(cgi.script_name, xwutil.parsedQS());
</cfscript>
</cffunction>

<cffunction name="sort" access="private" output="false" hint="resets table">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
var sortcol		=getValue(arguments.tblname, "sortcol");
var sortorder	=getValue(arguments.tblname, "sortorder");

	//first sort 
	if (sortcol eq "") {
	setValue(arguments.tblname, "sortcol", url.tblsort);
	} 
	// if the columns match swap the sortorder
	else if (url.tblsort eq sortcol) {
	setValue(arguments.tblname, "sortorder", IIF(sortorder eq "asc", DE("desc"), DE("asc")));
	} 
	// if the columns don't
	else if  (url.tblsort neq sortcol) {
		setValue(arguments.tblname, "sortcol", url.tblsort);
		setValue(arguments.tblname, "sortorder", "asc");
	}
</cfscript>
</cffunction>

<cffunction name="changepage" access="private" output="false" hint="resets table">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
	var currentpage	=getValue(arguments.tblname, "currentPage");
	var totalPages	=getValue(arguments.tblname, "totalPages");
	
	
	switch (url.tblchangepg) {
	case "first":	
		setValue(arguments.tblname, "currentPage", "1");
		;		
		break;
	case "next": 
		if (url.pageID lt totalpages) {
			setValue(arguments.tblname, "currentPage", (url.pageid+1));
		}	
		;
		break;
	case "prev": 
		if (url.pageID gt 1) {
		setValue(arguments.tblname, "currentPage", (url.pageid-1));
		}
		;
		break;
	case "last":
		setValue(arguments.tblname, "currentPage", totalpages);
		;
		break;
	default: 
	setValue(arguments.tblname, "currentPage", "1");
	;
	}
</cfscript>
</cffunction>

<cffunction name="filter" access="private" output="false" hint="resets table">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
	if (url.tblfilter eq "null" AND url.q eq "null") {
		setValue(arguments.tblname, "wherecol", "");
		setValue(arguments.tblname, "whereclause", "");
	} else {
		setValue(arguments.tblname, "wherecol", url.tblfilter);
		setValue(arguments.tblname, "whereclause", url.q);
		//new search based upon filter so set the currentpage to 1
		setValue(arguments.tblname, "currentpage", "1");
	}
</cfscript>
</cffunction>

<cffunction name="getTable" access="public" hint="returns the table XHTML">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
var currentpage	="";
var totalpages	="";
var recordcount ="";
var rowsperpage ="";
var startrow	="";
var xwfactory 	="";

//reset handler
if (isdefined("url.tblreset") AND url.tblreset eq "true") {
reset(arguments.tblname);
}

// sort action handler
if (isdefined("url.tblsort") AND url.tblsort neq "") {
sort(arguments.tblname);
}

// next of n record handler
if (isdefined("url.tblchangepg") AND url.tblchangepg neq "") {
changepage(arguments.tblname);
}

// next of n record handler
if (isdefined("url.tblfilter") AND url.tblfilter neq "") {
filter(arguments.tblname);
}


/* ********** QUERY HANDLER ***********
Run the query if the query has not been set already and is therefore empty i.e. "" */
if (NOT isQuery(getQuery(arguments.tblname, "sqlquery")) AND getQuery(arguments.tblname, "sqlquery") eq "" AND getValue(arguments.tblname, "WhereStatement") eq "") {
setQuery(arguments.tblname, "sqlquery", xwtable_do.doQuery(arguments.tblname));
} 
// if a whereStatement exists and has been updated then rerun the query.
else if (getValue(arguments.tblname, "WhereStatement") neq "" AND getValue(arguments.tblname, "WhereStatementUpdated")) {
setQuery(arguments.tblname, "sqlquery", xwtable_do.doQuery(arguments.tblname));
//set the flag back to false after the query is run
setValue(arguments.tblname, "WhereStatementUpdated", "false"); 
} 
	




currentpage	=getValue(arguments.tblname, "currentPage");
totalpages	=getValue(arguments.tblname, "TotalPages");
rowsperpage =getValue(arguments.tblname, "rowsPerPage");

//get the recordcount
recordcount = getValue(arguments.tblname, "sqlquery.recordcount");

//xwutil.throw("currentpage: #currentpage# recordcount: #recordcount#");
startrow=min((currentpage-1)*rowsPerPage+1,max(recordcount, 1));
setValue(arguments.tblname, "startrow", startrow); //set the startrow
setValue(arguments.tblname, "endrow", Min(startrow+rowsPerPage-1,recordCount)); //set the endrow
setValue(arguments.tblname, "totalpages", Ceiling(recordCount/rowsPerPage)); //set the total pages


//build the table as XML (XHTML 1.0) and return as a string 
xwfactory = createObject("component", "cfc.xwtable.xwtable_factory").init(arguments.tblname);
return xwfactory.makeTable();
</cfscript>
</cffunction>

<!--- getter method --->
<cffunction name="getValue" access="public" output="false" hint="gets a table value">
<cfargument name="tblname" required="true" type="string" />
<cfargument name="tblvarname" required="true" type="string" />
	<cfscript>
	return evaluate("session.xwtable." & arguments.tblname & ".getVar('" & arguments.tblvarname & "')");
	</cfscript>
</cffunction>

<!--- setter method --->
<cffunction name="setValue" access="public" output="false" hint="sets a table value">
<cfargument name="tblname" required="true" type="string" />
<cfargument name="tblvarname" required="true" type="string" />
<cfargument name="tblvarvalue" required="true" type="string" />
	<cfscript>
	return evaluate("session.xwtable." & arguments.tblname & ".setVar(""" & arguments.tblvarname & """,""" &  arguments.tblvarvalue & """)");
	</cfscript>
</cffunction>

<!--- getter Query method --->
<cffunction name="getQuery" access="public" output="false" hint="gets a table query" returntype="any">
<cfargument name="tblname" required="true" type="string" />
<cfargument name="tblqryname" required="true" type="string" />
	<cfscript>
	return evaluate("session.xwtable." & arguments.tblname & ".getQuery('" & arguments.tblqryname & "')");
	</cfscript>
</cffunction>

<cffunction name="setQuery" access="public" output="false" hint="sets a query value">
<cfargument name="tblname" required="true" type="string" />
<cfargument name="tblqryname" required="true" type="string" />
<cfargument name="tblqryvalue" required="true" type="query" />
	<cfscript>
	//	xwutil.throw("#tblname# #tblqryname# #de(tblqryvalue)#");
	evaluate("session.xwtable.#arguments.tblname#.setQuery(" & de(arguments.tblqryname) & ",arguments.tblqryvalue)");
	
	</cfscript>
</cffunction>


</cfcomponent>