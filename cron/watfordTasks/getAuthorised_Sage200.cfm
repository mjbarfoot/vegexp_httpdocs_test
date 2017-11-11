<!--- Gets authorised lists and items from Sage 200

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk

--->	

<!--- include common utility functions --->
<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="upload Authorised Lists";
VARIABLES.crontaskDesc="Exports Customer Authorised Product Lists from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getAuthorisedLog"] = structnew();
VARIABLES.LOGGERS["getAuthorisedLog"].name = "getAuthorisedLog";
VARIABLES.LOGGERS["authorisedLists.xml"] = structnew();
VARIABLES.LOGGERS["authorisedLists.xml"].name = "authorisedLists.xml";
VARIABLES.LOGGERS["authorisedItems.xml"] = structnew();
VARIABLES.LOGGERS["authorisedItems.xml"].name = "authorisedItems.xml";

//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;

// *** END OF VARS *** //


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/

// *** setup the files to write output to. 
setUpFileWriters();

// *** 1) Extract list and item data from database
qAL = getAuthorisedLists();
qAI = getAuthorisedItems();

// did we get a query object?
if (isQuery(qAL))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writeAuthorisedListsXML(qAL);
	if (NOT isComplete) abortTask(getLogger("getAuthorisedLog"), VARIABLES.LOGGERS["getAuthorisedLog"].name);
} else {
	abortTask(getLogger("getAuthorisedLog"), VARIABLES.LOGGERS["getAuthorisedLog"].name);
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("authorisedLists.xml", getLogger("getAuthorisedLog"));
if (NOT isComplete) abortTask(getLogger("getAuthorisedLog"), VARIABLES.LOGGERS["getAuthorisedLog"].name);



// did we get a query object back?
if (isQuery(qAI))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writeAuthorisedItemsXML(qAI);
	if (NOT isComplete) abortTask(getLogger("getAuthorisedLog"), VARIABLES.LOGGERS["getAuthorisedLog"].name);
} else {
	abortTask(getLogger("getAuthorisedLog"), VARIABLES.LOGGERS["getAuthorisedLog"].name);
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("authorisedItems.xml", getLogger("getAuthorisedLog"));
if (isComplete) {
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getAuthorisedLog"), VARIABLES.LOGGERS["getAuthorisedLog"].name);
}

/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getAuthorisedLists" output="false" returntype="any" hint="extracts product data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT CODE, DESCRIPTION, ALLOWED FROM AUTHORISEDLIST
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getAuthorisedLog").write("#timeformat(now(), 'H:MM:SS')# Success: getAuthorisedLists - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getAuthorisedLists", "AUTHORISEDLIST",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getAuthorisedLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="getAuthorisedItems" output="false" returntype="any" hint="extracts product data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT LIST, STOCKCODE, DISCOUNT FROM AUTHORISEDITEM
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getAuthorisedLog").write("#timeformat(now(), 'H:MM:SS')# Success: getAuthorisedItems - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getAuthorisedItems", "AUTHORISEDITEM",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getAuthorisedLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="writeAuthorisedListsXML" output="false" returntype="boolean" hint="writes out products as WDDX packet">
<cfargument name="q" type="query" required="true" hint="a query containing product data" />

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cfwddx action="cfml2wddx" input="#ARGUMENTS.q#" output="qXml" />


<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
getLogger("authorisedLists.xml").write(trim(qXml));
getLogger("getAuthorisedLog").write("#timeformat(now(), 'H:MM:SS')# Success: authorisedListsXML - Wrote Authorised Lists XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>

<cffunction name="writeAuthorisedItemsXML" output="false" returntype="boolean" hint="writes out products as WDDX packet">
<cfargument name="q" type="query" required="true" hint="a query containing product data" />

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cfwddx action="cfml2wddx" input="#ARGUMENTS.q#" output="qXml" />


<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
getLogger("authorisedItems.xml").write(trim(qXml));
getLogger("getAuthorisedLog").write("#timeformat(now(), 'H:MM:SS')# Success: authorisedItemsXML - Wrote Authorised Items XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>
