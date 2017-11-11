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
VARIABLES.crontaskName="upload Prices and Price Bands";
VARIABLES.crontaskDesc="Exports Sage Prices and Price Bands from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getPricesLog"] = structnew();
VARIABLES.LOGGERS["getPricesLog"].name = "getPricesLog";
VARIABLES.LOGGERS["prices.xml"] = structnew();
VARIABLES.LOGGERS["prices.xml"].name = "prices.xml";

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
qPR = getPrices();

// did we get a query object?
if (isQuery(qPR))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writePricesXML(qPR);
	if (NOT isComplete) abortTask(getLogger("getPricesLog"));
} else {
	abortTask(getLogger("getPricesLog"));
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("prices.xml", getLogger("getPricesLog"));
if (isComplete) {
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getPricesLog"), VARIABLES.LOGGERS["getPricesLog"].name);
}



/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getPrices" output="false" returntype="any" hint="extracts product data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT S.CODE as STOCKCODE, PR.PRICE, B.NAME AS BANDNAME, B.DESCRIPTION AS BANDDESCRIPTION
	FROM STOCKITEM S, PRODUCTGROUP P, STOCKITEMPRICE PR, PRICEBAND B
	WHERE S.PRODUCTGROUPID = P.PRODUCTGROUPID
    AND S.ITEMID = PR.ITEMID
    AND B.PRICEBANDID = PR.PRICEBANDID
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getPricesLog").write("#timeformat(now(), 'H:MM:SS')# Success: getPrices - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getPrices", "AUTHORISEDLIST",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getPricesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="writePricesXML" output="false" returntype="boolean" hint="writes out products as WDDX packet">
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
getLogger("prices.xml").write(trim(qXml));
getLogger("getPricesLog").write("#timeformat(now(), 'H:MM:SS')# Success: authorisedListsXML - Wrote Prices Lists XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>

