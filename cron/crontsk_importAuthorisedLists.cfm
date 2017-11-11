<!--- Imports authorised lists from a wddx file (authorisedLists.xml) on the server
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
VARIABLES.crontaskName="import Authorised Lists";
VARIABLES.logFileName="crontsklog";
VARIABLES.importXMLFileName="authorisedlists.xml";

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
VARIABLES.logger.write("CRONJOB: #VARIABLES.crontaskName# - STARTED.","INFO");

// 1) Convert products.xml to query object
qAL = getWDDXfromFilename(VARIABLES.inbound_path, importXMLFileName, VARIABLES.logger);


// 2) Insert them into a temporary table (importIntoTblAuthCustomerList)
if (isQuery(qAL))  {
	isComplete = importIntoTblAuthManagedList(qAL);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	abortTask(VARIABLES.logger);
}

// stop the clock
VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);
VARIABLES.logger.write("CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s","INFO");

//email results
//emailLogFiles(isComplete=true, logFileName=VARIABLES.logFileName, crontaskName=VARIABLES.cronTaskName);
/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>


<cffunction name="importIntoTblAuthManagedList" output="false" returntype="any" hint="truncates and inserts cust managed list data">
<cfargument name="q" type="query" required="true" hint="a query containing customer managed list data">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<!--- truncate --->
<cftry>
	<cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	DELETE FROM tblAuthManagedList
	</cfquery>
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblAuthManagedList", "TBLAUTHMANAGEDLIST",  "TRUNCATE", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write(formattedError, "ERROR");
	abortTask(VARIABLES.logger);
	</cfscript>
</cfcatch>
</cftry>

<!--- import custmanagedlist data --->
<cfloop query="ARGUMENTS.q">
<cftry>
    <cfquery name="chk" datasource="#VARIABLES.crontaskdsn#">
        SELECT 1 FROM tblAuthManagedList where code = <cfqueryparam cfsqltype = "cf_sql_varchar" value="#CODE#" />
    </cfquery>

    <cfif chk.recordcount eq 0>
        <cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
        INSERT INTO tblAuthManagedList
        (CODE, DESCRIPTION, LISTTYPE)
        VALUES('#CODE#','#DESCRIPTION#', <cfqueryparam cfsqltype = "cf_sql_bit" value="#ALLOWED#" />)
        </cfquery>
    </cfif>

	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("Success: importIntoTblAuthManagedList - ADDED #ARGUMENTS.q.recordcount# records (#tickinterval# s)", "INFO");
		ret=true;
		</cfscript> 
	</cfif>
	
<cfcatch type="any">

<cfrethrow/>
	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblAuthManagedList", "TBLAUTHMANAGEDLIST",  "INSERT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write(formattedError, "ERROR");
	</cfscript>

    <cfif Application.AppMode eq "Development">
        <cfrethrow />
    </cfif>

	<cfbreak />
		
</cfcatch>
</cftry>
</cfloop>

<cfreturn ret />

</cffunction>