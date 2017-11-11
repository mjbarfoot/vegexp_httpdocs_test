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
VARIABLES.crontaskName="upload Delivery Schedule";
VARIABLES.crontaskDesc="Exports the Delivery Schedules from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getDeliveryScheduleLog"] = structnew();
VARIABLES.LOGGERS["getDeliveryScheduleLog"].name = "getDeliveryScheduleLog";
VARIABLES.LOGGERS["deliveryschedules.xml"] = structnew();
VARIABLES.LOGGERS["deliveryschedules.xml"].name = "deliveryschedules.xml";


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
qDS = getDeliverySchedules();

// did we get a query object?
if (isQuery(qDS))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writeDeliveryScheduleXML(qDS);
	if (NOT isComplete) abortTask(getLogger("getDeliveryScheduleLog"));
} else {
		abortTask(getLogger("getDeliveryScheduleLog"), VARIABLES.LOGGERS["getDeliveryScheduleLog"].name);
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("deliveryschedules.xml", getLogger("getDeliveryScheduleLog"));
if (isComplete) {
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getDeliveryScheduleLog"), VARIABLES.LOGGERS["getDeliveryScheduleLog"].name);
}


/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getDeliverySchedules" output="false" returntype="any" hint="extracts product data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT CUSTOMER, DAY, VAN, DELIVERYDROP, DAYOFWEEK FROM DELIVERYSCHEDULE
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getDeliveryScheduleLog").write("#timeformat(now(), 'H:MM:SS')# Success: getDeliverySchedules - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getDeliverySchedules", "DELIVERYSCHEDULE",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getDeliveryScheduleLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="writeDeliveryScheduleXML" output="false" returntype="boolean" hint="writes out products as WDDX packet">
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
getLogger("deliveryschedules.xml").write(trim(qXml));
getLogger("getDeliveryScheduleLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeDeliveryScheduleXML - Wrote Delivery Schedules XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>


