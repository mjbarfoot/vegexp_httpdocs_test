<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="import Favourites";
VARIABLES.logFileName="crontsklog";
VARIABLES.favourites_filename = "favourites.xml";
VARIABLES.params_filename = "datelog.log";

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
qFavourites = getWDDXfromFilename(VARIABLES.inbound_path, VARIABLES.favourites_filename, VARIABLES.logger);

date_params = getDateParams();

// find out how many days are included in this file and also the end date of the favourites included
start_of_days= "-";
end_of_date = "}";
date_params = trim(date_params);
endofline = find(end_of_date, date_params)+1;
favourites_enddate = mid(date_params, find("{ts",date_params), 27);
favourites_days_included = trim(mid(date_params, find("'}",date_params)+2, len(date_params)));

//delete all favourites older than 6 months
deleteOldFavourites();

//remove any favourites included within our new data set
deleteFavouritesDueToBeReplaced(favourites_enddate,favourites_days_included);

///insertFavourites
insertFavourites(qFavourites);


// stop the clock
VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);
VARIABLES.logger.write("CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s","INFO");
/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>


<!--- RETRIEVE THE PARAM FILE  --->
<cffunction name="getDateParams">
	<cffile action="read" charset="utf-8" file="#VARIABLES.inbound_path##VARIABLES.params_filename#" variable="date_params" />
	<cfreturn date_params />
</cffunction>



<!--- DELETE FROM FAVOURITES OLDER THAN 6 MONTHS --->
<cffunction name="deleteOldFavourites">
	<cfquery name="tFavourites" datasource="#APPLICATION.dsn#">
	delete from tblFavourite
	where FavLastModifiedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('m',-6,now())#" />
	</cfquery>
</cffunction>


<!--- DELETE FROM FAVOURITES ANY DATA INCLUDED IN OUR NEW DATA SET --->

<cffunction name="deleteFavouritesDueToBeReplaced">

	<cfargument name="favourites_enddate" type="string" required="true" />
	<cfargument name="favourites_days_included" type="numeric" required="true" />

	<cfset deleteFromDate = DATEADD('d',favourites_days_included,favourites_enddate) />

	<cfquery name="tFavourites" datasource="#APPLICATION.dsn#">
	delete from tblFavourite
	where LastOrderDate >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#deleteFromDate#" />
	</cfquery>
</cffunction>


<!--- INSERT NEW FAVOURITES --->
<cffunction name="insertFavourites">
	<cfargument name="qFavourites" type="query" required="true" />

	<cfloop query="qFavourites">
	<cfquery name="chkFav" datasource="#APPLICATION.dsn#">
	select 1 from tblFavourite where AccountID = '#ACCOUNT_REF#' and stockcode = '#Stock_Code#'
	</cfquery>

	<cfif chkFav.recordcount eq 1>
		<cfquery name="uFavourites" datasource="#APPLICATION.dsn#">
		UPDATE tblFavourite
		SET LastOrderQuantity = '#LastOrderQuantity#',
		LastOrderDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LastOrderDate#" />,
		OrderCount = #Order_Count#,
		QtyToDate = #QtyToDate#,
		FavLastModifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
		WHERE AccountID = '#ACCOUNT_REF#'
		AND StockCode = '#STOCK_CODE#'
		</cfquery>
	<cfelse>
		<cfquery name="iFavourites" datasource="#APPLICATION.dsn#">
		INSERT INTO tblFavourite
		(AccountID, Stockcode, LastOrderQuantity, LastOrderDate, OrderCount, QtyToDate, FavLastModifiedDate)
		values (
		'#ACCOUNT_REF#',
		'#STOCK_CODE#',
		'#LastOrderQuantity#',
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#LastOrderDate#" />,
		#Order_Count#,
		#QtyToDate#,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
		)
		</cfquery>
	</cfif>
	</cfloop>
</cffunction>