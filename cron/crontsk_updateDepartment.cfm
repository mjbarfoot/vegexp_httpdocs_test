<!--- Updates the Department based upon the product category
Created for: Vegetarian Express
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk
--->

<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="Update Department";
VARIABLES.logFileName="crontsklog";


//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;

// Sage Line 200 ColdFusion DSN
VARIABLES.crontaskdsn=APPLICATION.dsn;

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
	VARIABLES.email_notification_from = "crontask@vegexp.co.uk";
} else {
	VARIABLES.inbound_path="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/xml_inbound/";
	VARIABLES.logPath = "/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";
	VARIABLES.email_notify=false;
	VARIABLES.email_notification_to = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_cc = "";
	VARIABLES.email_notification_from = "dev-crontask@vegetarianexpress.co.uk";
}

/*******************************************************************************
 *  TASK INITIALISATION													       *
*******************************************************************************/
VARIABLES.logger = application.crontsklog;

/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - STARTED.");

updateDepartment();

// stop the clock
VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s");
/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>


<cffunction name="updateDepartment">
<cfquery name="qryGetProducts" datasource="#APPLICATION.dsn#">
select * from tblProducts
</cfquery>

<cfset updatecount=0>
<cfset errorCount=0>
<cfloop query="qryGetProducts">
	
		
	<cfquery name="qryGetDepartmentID" datasource="#APPLICATION.dsn#">
	<cfif isNumeric(StockCategoryNumber)>
	SELECT distinct departmentid FROM tblCategory WHERE categoryid = #stockcategorynumber#
	<cfelse>
	SELECT 0 as departmentid FROM dual
	</cfif>
	</cfquery>
	
	<!--- if a valid category exists, update the stockIDs department--->
	<cfif qryGetDepartmentID.recordcount eq 1>
		
		<cftry>
		<cfquery name="qryUpdateDepartment" datasource="#APPLICATION.dsn#">
		update tblProducts
		set department = #qryGetDepartmentID.departmentid#
		where StockID = #StockID#
		</cfquery>
		
		<cfset updatecount=updatecount+1>
		
		<cfcatch type="database">
		<cfset errorCount=errorCount+1>
			<cfscript>
			formattedError=returnFormattedQueryError("qryUpdateDepartment", "qryUpdateDepartment",  "TRUNCATE", cfcatch);
			tickEnd=getTickCount();
			tickinterval=decimalformat((tickend-tickbegin)/1000);
			VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - ERROR: Update Failed: Error updating department for #StockID# #formattedError#" );
			</cfscript>
		</cfcatch>
		</cftry>
	
	<!--- some stock items use categories no longer in use, so just disabled them--->
	<cfelse>
		
		<cftry>
		<cfquery name="qryUpdateDepartment" datasource="#APPLICATION.dsn#">
		update tblProducts
		set department = 0
		where StockID = #StockID#
		</cfquery>
		
		<cfset updatecount=updatecount+1>
		
		<cfcatch type="database">
		<cfset errorCount=errorCount+1>
			<cfscript>
				formattedError=returnFormattedQueryError("qryUpdateDepartment", "qryUpdateDepartment",  "TRUNCATE", cfcatch);
				tickEnd=getTickCount();
				tickinterval=decimalformat((tickend-tickbegin)/1000);
				VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - ERROR: Update Failed: Error updating department for #StockID# - SQL Error:  #formattedError#" );
			</cfscript>
		</cfcatch>
		</cftry>
		
	</cfif>
	
</cfloop>
</cffunction>




