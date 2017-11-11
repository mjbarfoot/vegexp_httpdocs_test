<!--- Gets customer managed lists and items from Sage 200

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
VARIABLES.crontaskDesc="Exports Customer Managed Product Lists from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getCustMagedListsLog"] = structnew();
VARIABLES.LOGGERS["getCustMagedListsLog"].name = "getCustMagedListsLog";
VARIABLES.LOGGERS["custmanagedlists.xml"] = structnew();
VARIABLES.LOGGERS["custmanagedlists.xml"].name = "custmanagedlists.xml";

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
qCL = getCustManagedLists();

// did we get a query object?
if (isQuery(qCL))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writeCustManagedListsXML(qCL);
	if (NOT isComplete) abortTask(getLogger("getCustMagedListsLog"), VARIABLES.LOGGERS["getCustMagedListsLog"].name);
} else {
	abortTask(getLogger("getCustMagedListsLog"), VARIABLES.LOGGERS["getCustMagedListsLog"].name);
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("custmanagedlists.xml", getLogger("getCustMagedListsLog"));
if (isComplete) {	
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getCustMagedListsLog"), VARIABLES.LOGGERS["getCustMagedListsLog"].name);
}


/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getCustManagedLists" output="false" returntype="any" hint="extracts managed list data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
SELECT     CustomerAccountNumber AS ACCOUNT_REF, AnalysisCode5, AnalysisCode9
FROM         dbo.SLCustomerAccount AS SCA
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getCustMagedListsLog").write("#timeformat(now(), 'H:MM:SS')# Success: getCustManagedLists - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getPrices", "SLCUSTOMERACCOUNT,SLCUSTOMERANALYSISHEADVALUE,SYSTRADERANALYSISVALUE",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getCustMagedListsLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="writeCustManagedListsXML" output="false" returntype="boolean" hint="takes a query and writes to filesystem as WDDX XML packet">
<cfargument name="q" type="query" required="true" hint="a query containing customer managed lists data" />

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
getLogger("custmanagedlists.xml").write(trim(qXml));
getLogger("getCustMagedListsLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeCustManagedListsXML - Wrote customer managed Lists XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>


