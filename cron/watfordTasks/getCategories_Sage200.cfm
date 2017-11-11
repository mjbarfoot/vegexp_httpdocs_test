<!--- Gets a list of categories from Sage 200. The Aspidistra
web service does not retrieve code and name, only code
which isn't a great deal of use.'

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Extract query
2) Covert to WDDX
3) Write to filesystem
4) FTP to Server
--->	

<!--- include common utility functions --->
<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/

VARIABLES.crontaskName="upload Categories";
VARIABLES.crontaskDesc="Exports Sage Products Categories from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getCategoriesLog"] = structnew();
VARIABLES.LOGGERS["getCategoriesLog"].name = "getCategoriesLog";
VARIABLES.LOGGERS["categories.xml"] = structnew();
VARIABLES.LOGGERS["categories.xml"].name = "categories.xml";

//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;
// *** END OF VARS *** //


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/

// *** setup the files to write output to. 
// products.xml and getproducts.log for wddx xml and log file for cron task progress respectively
setUpFileWriters();

// *** 1) Extract product data from database
q = getCategoriesFromSage();

// did we get a query object?
if (isQuery(q))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writeCategoriesXML(q);
	if (NOT isComplete) abortTask(getLogger("getCategoriesLog"), VARIABLES.LOGGERS["getCategoriesLog"].name);
} else {
	abortTask(getLogger("getCategoriesLog"), VARIABLES.LOGGERS["getCategoriesLog"].name);
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("categories.xml", getLogger("getCategoriesLog"));
if (isComplete) {
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getCategoriesLog"), VARIABLES.LOGGERS["getCategoriesLog"].name);
}


/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getCategoriesFromSage" output="false" returntype="any" hint="extracts product data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT CODE AS CATEGORYID, DESCRIPTION AS CATEGORY
	FROM PRODUCTGROUP
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getCategoriesLog").write("#timeformat(now(), 'H:MM:SS')# Success: getCategoriesFromSage - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getCategoriesFromSage", "PRODUCTGROUP",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getCategoriesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="writeCategoriesXML" output="false" returntype="boolean" hint="writes out products as WDDX packet">
<cfargument name="q" type="query" required="true" hint="a query containing product data" />

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cfwddx action="cfml2wddx" input="#ARGUMENTS.q#" output="categoriesXML" />


<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
getLogger("categories.xml").write(trim(categoriesXML));
getLogger("getCategoriesLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeCategoriesXML - Wrote Categories XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>

