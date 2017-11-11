<!--- 
	Component: myxwtable.cfc
	File: myxwtable.cfc
	Description: Holds table properties
	Author: Matt Barfoot
	Date: 02/04/20006
	Revisions: 
	
	05/04/2006: Added property "customcolumntypelist". This can be used to differentiate custom columns.
	A custom column can now be a URI with the primary key or it can call a custom function defined in the component xwcustomfunctions.cfc
	and pass and query columns. The returned variable must be a string and any formatted desired should be done by the custom function. 
	Formatting still not support on custom columns. 
	
	19/04/2006: Added property "querycolumnbindlist". It may be necessary to specify columns to be included in the query, but are not
	but are part of a custom function. Before if a column type was query then it would pick the corresponding column from the querycolumnlist.
	By adding a this new property the columns that are included in the query are seperated from the columns which appear in the table.
	
	14/07/2006: Added property "whereStatementUpdated". If xwtable runs the query and where where clause for the query is changed the 
	query is to be rerun. The above property flag is set to True when this is the case. The getTable method checks this flag 
	to see if the query needs to be rerun. By default the flag is True because initially no query has been run!
	
	--->
	
<cfcomponent name="myxwtable" displayname="myxwtable" output="false" hint="holds table properties and get and set values">

<cffunction name="init" access="public" output="false" hint="sets default properties">
<cfargument name="tblname" required="true" type="string" />

<cfscript>
variables.name = "#arguments.tblname#";

variables.status = "initialising...";


//URL Parameters
variables.URL = cgi.script_name; //default to the current web page
variables.allowedParams = ""; // list of "passthrough" querystring parameters

/* if the URL set initially contains query params, then this means
are to be set universally. We need to strip them off and variables.URL 
and put them here instead. They can then be safely added
each time a link is constructed */
variables.queryString_prepend=""; 

//formatting properties
variables.width = "";
variables.colwidths = "";
variables.alignment = "";
variables.class = "";

//column list, type and format
variables.columnnamelist="";
variables.columntypelist="";
variables.columnformatlist="";
variables.columnSortable="";

//content properties
variables.caption = "";
variables.summary = "";
variables.type = "";

//query properites
variables.query.dsn="";
variables.query.table="";
variables.query.username="";
variables.query.password="";
variables.sqlquery="";
variables.sqlquery_setexternal="false"; //query set outside of xwtable, don't use do.

//query columnlist and primary key
variables.querycolumnprimarykey="";
variables.querycolumnlist="";
variables.querycolumnbindlist=""; //added 19/04/2006

//custom column list
// custom column value list can include bind primary key from the query using :{query column}
// example: <a href="javascript:void(0)" onclick="editUser(':myquerycolumn')">edit</a> 
//
variables.customcolumnvaluelist=""; 
variables.customcolumntypelist=""; // addded 05/04/2006

// ************ optional attributes *************//

//show table caption
variables.showcaption = "Yes";

// show bottom border on last row?
variables.showLastRowBottomBorder = "0";

//footer style
variables.footerNavStyle = "Google";

//show table footer 
variables.showFooter = "Yes";

//enable filter
variables.enableFilter = "Yes";

//sortable? 
variables.sortable=true;

//boolean list of whether to show column titles
variables.columnShowHideTitleList=""; 

//show next of n text
variables.showNextofNtext="1";

//show nav at top
variables.showNavAtTop="1";

//show nav at bottom
variables.showNavAtBottom="0";


//default properties
variables.startrow = 1;
variables.endrow = 10;
variables.rowsPerPage = 10;
variables.currentPage = 1;
variables.cfcurl="";
variables.wherestatement="";
variables.wherestatementUpdated=true;

variables.sortcol="";
variables.sortorder="asc";
variables.sortUpdated=false;

variables.totalpages=0;
variables.wherecol="";
variables.whereclause="";
variables.wherecolUpdated=false;

//column formats
variables.dateformat="dateformat(:rowval, 'dd/mm/yyyy')";
variables.timeformat="timeformat(:rowval, 'H:MM TT')";

return this;
</cfscript>
</cffunction>


<cffunction name="dump" displayname="dump" output="true" access="public">
<cfdump var="#variables#">
</cffunction>


<cfscript>
// get the value of a var
function getVar(NameOfVar) {
	if (isdefined("variables.#ARGUMENTS.NameOfVar#"))  {
		return evaluate("variables.#ARGUMENTS.NameOfVar#");
	} else {
		return "var not found";
	}
}


// set function for setting parameters
function setVar(NameOfVar, varValue) {
	if (isdefined("variables.#ARGUMENTS.NameOfVar#")){ 
	
		//SPECIAL CASE: are we updating the whereStatement, 
		if (lcase(ARGUMENTS.NameOfVar) eq "wherestatement") {
			isWhereStatementDifferent(varValue);
		}
		
		"variables.#NameofVar#" = ARGUMENTS.varValue;
		
		//SPECIAL CASE: updating the URL, update after setting value
		if (lcase(ARGUMENTS.NameOfVar) eq "URL") {
			parseURL();	
		}
	
	}  else {
		return "var not found";
	}
}

function getQuery(NameOfQuery) {
	if (isdefined("variables.#ARGUMENTS.NameOfQuery#"))  {
		return evaluate("variables." & ARGUMENTS.NameOfQuery);
	} else {
		return "var not found";
	}
}

function setQuery(NameOfVar, QueryVal) {
	if (isdefined("variables.#ARGUMENTS.NameOfVar#"))  {
		"variables.#ARGUMENTS.NameOfVar#" = arguments.QueryVal;
	} else {
		return "var not found";
	}
}

/*  check if the new whereStatement is different to the old one.
if they are different, set the wherestatement updated flag to true

When the getTable method runs in xwtable.cfc if this flag is set
the query will be executed/refreshed. This means a query is only
execuated on the database if required, because of changed sql parameters */

function isWhereStatementDifferent(newWhereStatement) {
	
	if (ARGUMENTS.newWhereStatement neq variables.wherestatement) {	
	variables.wherestatementUpdated=true;
	}
}


function parseURL() {
	//does it contain any query string params
	if (find("?",VARIABLES.URL)) {
	 	VARIABLES.queryString_prepend = mid(VARIABLES.URL,(find("?",VARIABLES.URL)+1),len(VARIABLES.URL));
	 	VARIABLES.URL = replace(VARIABLES.URL, "?" & VARIABLES.queryString_prepend, "");
	}
}
</cfscript>
	
</cfcomponent>