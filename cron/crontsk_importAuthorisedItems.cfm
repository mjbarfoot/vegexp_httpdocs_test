<!--- Imports authorised lists from a wddx file (authorisedItems.xml) on the server
stored in the httpdocs/xml_inbound directory

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Convert the xml file to wddx
2) import into tblAuthManagedList
--->	

<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="import Authorised Items";
VARIABLES.logFileName="crontsklog";
VARIABLES.importXMLFileName="authoriseditems.xml";

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
qAI = getWDDXfromFilename(VARIABLES.inbound_path, importXMLFileName, VARIABLES.logger);


// 2) Insert them into a temporary table (importIntoTblAuthCustomerList)
if (isQuery(qAI))  {
	isComplete = importIntoTblAuthManagedItem(qAI);
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


<cffunction name="importIntoTblAuthManagedItem" output="false" returntype="any" hint="truncates and inserts authorised item data">
<cfargument name="q" type="query" required="true" hint="a query containing  managed item data">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<!--- truncate --->
<cftry>
	<cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	delete from tblAuthManagedItem
	</cfquery>
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblAuthManagedItem", "TBLAUTHMANAGEDITEM",  "TRUNCATE", cfcatch);
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
    <cfquery name="chk" datasource="#VARIABLES.crontaskdsn#">
       SELECT 1 FROM tblAuthManagedItem where LIST = '#LIST#' and STOCKCODE = '#STOCKCODE#'
    </cfquery>

    <cfif chk.recordcount eq 0>
        <cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
        INSERT INTO tblAuthManagedItem
        (LIST, STOCKCODE, DISCOUNT)
        VALUES('#LIST#','#STOCKCODE#', #IIF(VAL(DISCOUNT), DISCOUNT, 0)#)
        </cfquery>
    </cfif>

	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: importIntoTblAuthManagedItem - ADDED #ARGUMENTS.q.recordcount# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>
	
<cfcatch type="any">
	<cfthrow detail='list: #ARGUMENTS.Q["list"][currentrow]# stockcode: #ARGUMENTS.Q["stockcode"][currentrow]# discount: #ARGUMENTS.Q["discount"][currentrow]#' /> 
		
	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblAuthManagedItem", "TBLAUTHMANAGEDITEM",  "INSERT", cfcatch);
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