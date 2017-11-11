<!--- Imports managed list data and itmes from a wddx file (custmanagedlists.xml) on the server
stored in the httpdocs/xml_inbound directory

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Fetches all products with stock levels below 50
2) converts stockcodes to an array
3) calls getFreeStockLevels ASPIDISTRA method via Sage Gateway service
4) convert response to XML and identify all stock quantity nodes
5) convert them to two dimension array with stockcode
6) pass them to productDO to update website stock levels

--->	

<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="getLowStockLevels";
VARIABLES.logFileName="crontsklog";

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
VARIABLES.sagegw = createObject("component","cfc.sagegw.sageWSGW").init();
VARIABLES.productsDO = createObject("component","cfc.departments.productsDO").init();

/*******************************************************************************
*  TASK START															       *
*******************************************************************************/
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - STARTED.");

/*******************************************************************************
*  1) Fetches all products with stock levels below 50							*
*******************************************************************************/
q = VARIABLES.productsDO.getLowStockLevels(val(APPLICATION.var_DO.getVar("LowStockThreshold")));
writeOutput("LowStockThreshold is:" & APPLICATION.var_DO.getVar("LowStockThreshold"));
/*******************************************************************************
*  2) converts stockcodes to an array											*
*******************************************************************************/
 
if (isQuery(q))  {

		a = arraynew(1);
		
		for (i=1; i lte q.recordcount; i=i+1) {
				a[i] = q["stockcode"][i];
		}


		writeOutput("returned " & q.recordcount & " records");

		isComplete=true;
		
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	dump(qML);
	abortTask(VARIABLES.logger);
}
/*******************************************************************************
*  3) calls getFreeStockLevels ASPIDISTRA method via Sage Gateway service		*												       *
*******************************************************************************/
SOAPResult = sagegw.getFreeStockLevels(a);

/*******************************************************************************
*  4) convert response to XML and identify all stock quantity nodes				*
*******************************************************************************/
myXMLDoc =  getXML(SOAPResult);

/*******************************************************************************
*  5) convert them to two dimension array with stockcode				      *
*******************************************************************************/
xmlElements = xmlSearch(myXMLDoc, "//*/*/*/*");
b = arraynew(2);

for (i = 1; i LTE ArrayLen(a); i = i + 1) {
b[i][1]=a[i];
b[i][2]= xmlElements[i+1].XmlText;
}        	 	


/*******************************************************************************
*  6) pass them to productDO to update website stock levels					*
*******************************************************************************/
iscomplete = VARIABLES.productsDO.setStockLevel(b);

if (iscomplete) {
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - All done. #i-1# records updated")
	writeOutput("All done. #i-1# records updated");
} else {
	writeOutput("we have a problem houston!");
}


/*******************************************************************************
*  TASK SHUTDOWN													           *
*******************************************************************************/
// stop the clock
VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s");

//email results
//emailLogFiles(isComplete=true, logFileName=VARIABLES.logFileName, crontaskName=VARIABLES.cronTaskName);
/*******************************************************************************
*  TASK END													           *
*******************************************************************************/
       	 	

</cfscript>