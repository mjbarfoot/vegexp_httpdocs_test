<!--- 
	cron task: crontsk_emlIncompleteOrders.cfm
	File: /cron/crontsk_emlIncompleteOrders.cfm
	Description: retrieves incomplete orders and emails a specified email adress
	Author: Matt Barfoot
	Date: 05/07/2006
	Revisions:
	--->

<cfscript>
//create log files
if (not isdefined("APPLICATION.crontsklog")) { 
APPLICATION.crontsklog 			= createObject("component", "cfc.logwriter.logwriter").init("D:\JRun4\servers\vegexp\cfusion-war\logs\", "crontsklog");
APPLICATION.var_DO 			= 			createObject("component", "cfc.global.var_do").init();
}

VARIABLES.taskStart=getTickCount();

//write crontask started
APPLICATION.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Crontask: 'Email Incomplete Web Orders'................................ Started" );


// get the shop Data Object save order data to the web db
VARIABLES.shopDO				=	createObject("component", "cfc.shop.do").init();
VARIABLES.eml					=	createObject("component", "cfc.shop.dispatchMsg");

//retrieve incomplete orders
VARIABLES.qryIncompleteOrders 	= VARIABLES.shopDO.getIncompleteOrders();

APPLICATION.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Crontask: 'Email Incomplete Web Orders'................................ Found #VARIABLES.qryIncompleteOrders.recordCount# records" );

// if there any any incomplete orders email them

if (VARIABLES.qryIncompleteOrders.recordCount neq 0) {
//send confirmation to customer
	VARIABLES.msg = structnew();
	VARIABLES.msg.title = "These orders are incomplete and require action";
	VARIABLES.msg.body = VARIABLES.qryIncompleteOrders;
	VARIABLES.eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress"),"weborders@vegexp.co.uk","VE Incomplete Orders Reminder", VARIABLES.msg, "/views/emlIncompleteOrders.cfm");

}


VARIABLES.taskEnd=getTickCount();
VARIABLES.taskElapsedTime=decimalformat((VARIABLES.taskEnd-VARIABLES.taskStart)/1000);

APPLICATION.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Crontask: 'Email Incomplete Web Orders'................................ Completed in #VARIABLES.taskElapsedTime# s" );

WriteOutput("<h1>Crontask: Email Incomplete Web Orders Completed. Email sent to: #APPLICATION.var_DO.getVar('salesEmailAddress')# Completed in #VARIABLES.taskElapsedTime# s</h1");
</cfscript>