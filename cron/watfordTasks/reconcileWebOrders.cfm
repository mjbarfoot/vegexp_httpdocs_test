<!--- Reconcile Web Orders: 

Retrives the days orders from Sage and checks them against the Order from the website
to verify any that our missing and send an alert detailing status. 

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2012
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Query Orders table in VE Website for todays orders both complete and incomplete
2) Format results into table
3) Collate incomlplete orders into a detailed report. 
@param: days integer number of days to reconcile
--->	


<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/


VARIABLES.logFileName="rec_log";
VARIABLES.xmlOut="";

VARIABLES.isComplete = false;
VARIABLES.crontaskName="Reconcile Web Orders";
VARIABLES.crontaskDesc="Reconilliation Web Orders Report produced daily at midday and 3pm";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["reconcileWebOrdersLog"] = structnew();
VARIABLES.LOGGERS["reconcileWebOrdersLog"].name = "reconcileWebOrdersLog";

//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;

//URL Params
VARIABLES.rec_days = 1;

If (  isdefined("URL.Days")) {
	VARIABLES.rec_days = URL.Days;
}


// *** END OF VARS *** //

/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/

// *** setup the files to write output to. 
// favlog.log to record progress, favOut.xml to save the favourites xml, dataLog.log 
setUpFileWriters();

// *** copy Sales Orders into our Favourites DB  
q = getCompleteSalesOrdersFromWebsite(VARIABLES.rec_days);

// did we get a query object?
if (isQuery(q)) {
	ordersCompleteXML = "";
	ordersCompleteXML  = saveXML(q);
} else {
	abortTask(getLogger("reconcileWebOrdersLog"), VARIABLES.LOGGERS["reconcileWebOrdersLog"].name);
}

// *** copy Sales Orders into our Favourites DB  
q = getFailedSalesOrdersFromWebsite(VARIABLES.rec_days);

// did we get a query object?
if (isQuery(q)) {
	ordersIncompleteXML = "";
	ordersIncompleteXML  = saveXML(q);
} else {
	abortTask(getLogger("reconcileWebOrdersLog"), VARIABLES.LOGGERS["reconcileWebOrdersLog"].name);
}

If (isdefined("URL.emailReport")) {
	VARIABLES.isComplete = emailReport(ordersCompleteXML,ordersIncompleteXML);
} else {
	VARIABLES.isComplete = showView(ordersCompleteXML,ordersIncompleteXML);	
}


</cfscript>


<cffunction name="getCompleteSalesOrdersFromWebsite" output="false" returntype="any" hint="retrieves Sales Order data from the VE Orders Website">
<cfargument name="days" required="true" type="numeric" hint="The number of days going backwards from today to retrieve sales orders for">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="qGetOrders" datasource="#VARIABLES.veappdate_dsn#"  result="qRes" blockfactor="100">
	select WebOrderID, AccountID, OrderTime, OrderStatus, OrderStatusError from tblOrder 
	where OrderTime >= <CFQUERYPARAM CFSQLTYPE="CF_SQL_TIMESTAMP" VALUE="#DATEADD('D',(-1 * ARGUMENTS.DAYS),NOW())#"> 
	and OrderStatus = 'complete'
	order by OrderTime desc
	</cfquery>
	
	<cfscript>	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("reconcileWebOrdersLog").write("#timeformat(now(), 'H:MM:SS')# Success: qGetOrders - fetched #qGetOrders.recordcount# records in #tickinterval# ms");
	ret = qGetOrders;
	</cfscript>

<cfcatch type="any">
	<cfrethrow/>
	<cfscript>
	formattedError=returnFormattedQueryError("getSalesOrdersFromSage", "SOPORDERRETURN,SLCUSTOMERACCOUNT",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("reconcileWebOrdersLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>


<cffunction name="getFailedSalesOrdersFromWebsite" output="false" returntype="any" hint="retrieves Sales Order data from the VE Orders Website">
<cfargument name="days" required="true" type="numeric" hint="The number of days going backwards from today to retrieve sales orders for">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="qGetOrders" datasource="#VARIABLES.veappdate_dsn#"  result="qRes" blockfactor="100">
	select WebOrderID, AccountID, OrderTime, OrderStatus, OrderStatusError from tblOrder 
	where OrderTime >= <CFQUERYPARAM CFSQLTYPE="CF_SQL_TIMESTAMP" VALUE="#DATEADD('D',(-1 * ARGUMENTS.DAYS),NOW())#"> 
	and OrderStatus <> 'complete'
	order by OrderTime desc
	</cfquery>
	
	<cfscript>	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("reconcileWebOrdersLog").write("#timeformat(now(), 'H:MM:SS')# Success: qGetOrders - fetched #qGetOrders.recordcount# records in #tickinterval# ms");
	ret = qGetOrders;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getSalesOrdersFromSage", "SOPORDERRETURN,SLCUSTOMERACCOUNT",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("reconcileWebOrdersLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>


<cffunction name="saveXML" access="public" returntype="string" output="false">
<cfargument name="q" type="query" required="true" hint="The passed query">

<cfset ret = "">
<!--- WebOrderID, AccountID, OrderTime, OrderStatus, OrderStatusDesc --->



	<!--- build the content on to an xml variable --->
	<cfsavecontent variable="ret">	
	<cfoutput>
		<table id="myOrders">
		<thead>
		<tr>
			<th>WebOrderID</th>
			<th style="text-align:left;">AccountID</th>
			<th style="text-align:left;">Time Placed</th>
			<th style="text-align:left;">Order Status</th>
			<th style="text-align:left;">Order Status Error</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="ARGUMENTS.q">
		<cftry>	
				<cfxml variable="myStrXML">
					<cfoutput>#xmlformat(replace(replace(OrderStatusError,'Error posting order to sage: ',''),'<?xml version="1.0" encoding="utf-8"?>',''))#</cfoutput>
				</cfxml>

					<Cfset myresult = xmlsearch(myStrXML,"//soap:Reason")>
					<cfset errorStr=xmlformat(myresult[1].XmlChildren[1].xmlText)/>
		<cfcatch type="any">
			<cfset errorStr=xmlformat(OrderStatusError)>
		</cfcatch>	
		</cftry>	
		<tr>
			<td>#xmlformat(WebOrderID)#</td>
			<td id="AC_#currentrow#" style="text-align:left;">#xmlformat(AccountID)#</td>
			<td id="OT_#currentrow#" style="text-align:left;">#dateformat(OrderTime, "dd/mm/yyyy")# #timeformat(OrderTime, "HH:mm:ss")# </td>
			<td id="OS_#currentrow#" style="text-align:left;">#xmlformat(OrderStatus)#</td>
			<td id="SD_#currentrow#" style="text-align:left;">#errorStr#</td>
		</tr>
		</cfloop>
		</tbody>
		</table>
	</cfoutput>
	</cfsavecontent>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset ret=replace(toString(ret), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset ret=reReplace(ret, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn ret>

</cffunction>


<cffunction name="emailReport" access="public" returntype="string" output="true">
<cfargument name="ordersCompleteXML" required="true" type="string" hint="The complete orders XML">
<cfargument name="ordersIncompleteXML" required="true" type="string" hint="The Incomplete orders XML">


<cfmail to="#VARIABLES.email_notification_to#" from="#VARIABLES.email_notification_from#" subject="VE Orders Website - Order Reconcilliation Report" type="HTML">
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
##wrapper {margin-left: 100px; margin-right: auto; width: 820px; padding: 1em; border: 1px solid ##177730;}
##logo {background: url(http://<cfoutput>#server_name#:#server_port#</cfoutput>/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
##header {height: 20px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: ##177730; color: white; padding-left: 1em;}
h2 {font-size: 1.2em; background-color: ##177730; color: white; padding-left: 1em;}
p {magin-bottom: 1.6em;}
p a {color: ##177730;}

/* Check Out Container, Table etc */
##orderContainer {background-color: White; font-size: 0.9em; padding:0.7em; margin-top: 0.6em; }
##orderContainer div.chkoutSec {margin: 1em 0em;}
##orderContainer div.chkoutSec span.chkoutSecTitle {position: relative; border-bottom: 1px solid ##177730; font-weight: bold; font-size: 0.9em; display: block; padding-bottom: 0.4em; margin-top:0.4em;}

/* myBasketItems Table */
##myOrders {font-size: 0.9em; width: 800px; border: none !important; border-bottom:1px solid ##CBE7B3; border-collapse: collapse;} 
##myOrders th {text-align:left; padding: 3px; border-right: none !important; border-left: none !important; border-bottom: 1px solid ##CBE7B3; background-color: ##CBE7B3;} 
##myOrders td {padding: 3px;  border-right: none !important; border-left: none !important;  border-bottom: 1px solid ##CBE7B3;}
##myOrders td a.basketItemDelete {color: Black; text-decoration: none;	font-weight: Bold;}
##myOrders td a.basketItemDelete:hover {color: Black; text-decoration: none;	font-weight: Bold; text-decoration: underline;}

</style>
</head>
<body>
<div id="wrapper">
<!--- <div id="logo"></div> --->
	<h1>Web Order Reconcillation Report</h1>
	<div id="orderContainer">
		<h2>Web Orders Posted Successfully to Sage ( Created in the last #VARIABLES.rec_days# days )</h2>
		#ARGUMENTS.ordersCompleteXML#
		<p/></p>
		<h2>Web Orders NOT in Sage ( Created in the last #VARIABLES.rec_days# days)</h2>
		#ARGUMENTS.ordersIncompleteXML#
	</div>
</div>
</body>
</html>		
</cfoutput>
</cfmail>

</cffunction>

<cffunction name="showView" access="public" returntype="string" output="true">
<cfargument name="ordersCompleteXML" required="true" type="string" hint="The complete orders XML">
<cfargument name="ordersIncompleteXML" required="true" type="string" hint="The Incomplete orders XML">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
##wrapper {margin-left: 100px; margin-right: auto; width: 820px; padding: 1em; border: 1px solid ##177730;}
##logo {background: url(http://<cfoutput>#server_name#:#server_port#</cfoutput>/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
##header {height: 20px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: ##177730; color: white; padding-left: 1em;}
h2 {font-size: 1.2em; background-color: ##177730; color: white; padding-left: 1em;}
p {magin-bottom: 1.6em;}
p a {color: ##177730;}

/* Check Out Container, Table etc */
##orderContainer {background-color: White; font-size: 0.9em; padding:0.7em; margin-top: 0.6em; }
##orderContainer div.chkoutSec {margin: 1em 0em;}
##orderContainer div.chkoutSec span.chkoutSecTitle {position: relative; border-bottom: 1px solid ##177730; font-weight: bold; font-size: 0.9em; display: block; padding-bottom: 0.4em; margin-top:0.4em;}

/* myBasketItems Table */
##myOrders {font-size: 0.9em; width: 800px; border: none !important; border-bottom:1px solid ##CBE7B3; border-collapse: collapse;} 
##myOrders th {text-align:left; padding: 3px; border-right: none !important; border-left: none !important; border-bottom: 1px solid ##CBE7B3; background-color: ##CBE7B3;} 
##myOrders td {padding: 3px;  border-right: none !important; border-left: none !important;  border-bottom: 1px solid ##CBE7B3;}
##myOrders td a.basketItemDelete {color: Black; text-decoration: none;	font-weight: Bold;}
##myOrders td a.basketItemDelete:hover {color: Black; text-decoration: none;	font-weight: Bold; text-decoration: underline;}

</style>
</head>
<body>
<div id="wrapper">
<!--- <div id="logo"></div> --->
	<h1>Web Order Reconcillation Report</h1>
	<div id="orderContainer">
		<h2>Web Orders Posted Successfully to Sage ( Created in the last #VARIABLES.rec_days# days )</h2>
		#ARGUMENTS.ordersCompleteXML#
		<p/></p>
		<h2>Web Orders NOT in Sage ( Created in the last #VARIABLES.rec_days# days)</h2>
		#ARGUMENTS.ordersIncompleteXML#
	</div>
</div>
</body>
</html>		
</cfoutput>


</cffunction>


