<!--- Imports prices from a wddx file (prices.xml) on the server
stored in the httpdocs/xml_inbound directory

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Convert the xml file to wddx
2) import into tblPrices
--->	

<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="import Delivery Schedules";
VARIABLES.logFileName="crontsklog";
VARIABLES.importXMLFileName="deliveryschedules.xml";

//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;

// Sage Line 200 ColdFusion DSN
VARIABLES.crontaskdsn=APPLICATION.dsn;
// Favourites DB
//VARIABLES.FavDB_dsn="veFavDb";
//line break 
VARIABLES.linebreak = "#chr(13)##chr(10)#";
// dev of prod mode?
VARIABLES.isProduction = isProductionServer();

//email params
if (VARIABLES.isProduction) {
	VARIABLES.inbound_path="/var/www/orders.vegetarianexpress.co.uk/web/xml_inbound/";
	VARIABLES.logPath = "/var/www/orders.vegetarianexpress.co.uk/web/logs/";
	VARIABLES.email_notify=true;
	VARIABLES.email_notification_to = "webmaster@vegetarianexpress.co.uk";
	VARIABLES.email_notification_cc = "willmatier@vegexp.co.uk";
	VARIABLES.email_notification_from = "crontask@vegetarianexpress.co.uk";
} else {
	VARIABLES.inbound_path="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/xml_inbound/";
	VARIABLES.logPath = "/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";
	VARIABLES.email_notify=false;
	VARIABLES.email_notification_to = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_cc = "";
	VARIABLES.email_notification_from = "dev-crontask@vegetarianexpress.co.uk";
}
// *** END OF VARS *** //


/*******************************************************************************
*  TASK INITIALISATION													       *
*******************************************************************************/
VARIABLES.logger = application.crontsklog;


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - STARTED.");

// 1) Convert products.xml to query object
qDS = getWDDXfromFilename(VARIABLES.inbound_path, importXMLFileName, VARIABLES.logger);


// 2) Insert them into a temporary table (importIntoTblAuthCustomerList)
if (isQuery(qDS))  {
	isComplete = importIntoTblDeliverySchedule(qDS);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	abortTask(VARIABLES.logger);
}

// stop the clock
VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s");

//email results
//emailLogFiles(isComplete=true, logFileName=VARIABLES.logFileName, crontaskName=VARIABLES.cronTaskName);
/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>


<cffunction name="importIntoTblDeliverySchedule" output="false" returntype="any" hint="truncates and inserts price data">
<cfargument name="q" type="query" required="true" hint="a query containing  price data">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<!--- truncate --->
<cftry>
	<cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	delete from tblDeliverySchedule
	</cfquery>
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblDeliverySchedule", "TBLDELIVERYSCHEDULE",  "TRUNCATE", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	abortTask(VARIABLES.logger);
	</cfscript>
</cfcatch>
</cftry>

<!--- import custmanagedlist data --->
<cfloop query="ARGUMENTS.q">
<cftry>
	<cfquery name="chk"  datasource="#VARIABLES.crontaskdsn#">
     select 1 from tblDeliverySchedule where AccountID = '#CUSTOMER#' and day = '#DAY#'
	</cfquery>

    <cfif chk.recordcount eq 0>
        <cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
        INSERT INTO tblDeliverySchedule
        (ACCOUNTID, DAY, VAN, DELIVERYDROP, DAYOFWEEK)
        VALUES('#CUSTOMER#', '#DAY#', #VAN#, '#DELIVERYDROP#', #DAYOFWEEK#)
        </cfquery>
    </cfif>

	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: importIntoTblDeliverySchedule - ADDED #ARGUMENTS.q.recordcount# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>
	
<cfcatch type="any">
	<cfrethrow /> 
		
	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblDeliverySchedule", "TBLDELIVERYSCHEDULE",  "INSERT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
	
	<cfbreak />
		
</cfcatch>
</cftry>
</cfloop>

<cfreturn ret />

</cffunction>