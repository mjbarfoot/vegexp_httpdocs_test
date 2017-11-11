<!--- *************************************************************
INITIATION
******************************************************************* --->
<cfscript>
/***********************************************************
			LOGGING INITIALISATION
***********************************************************/
//default
VARIABLES.logtype="file";
VARIABLES.days="-3";

		
//server specific log configuration
switch (cgi.SERVER_NAME) {
case "localhost": case "clearview": case "vegexp.clearview.local":
				  VARIABLES.AppMode="development";
				  VARIABLES.logpath="C:\ColdFusion8\wwwroot\";					  
				  VARIABLES.logtype="file";
				  VARIABLES.showDebug=true;
				  ;
				  break;
default: 	      VARIABLES.AppMode="production";
				  VARIABLES.logpath="";
   				  VARIABLES.logtype="file";
				  VARIABLES.showDebug=false;
				  ;				  	
				
}

//create log files
favlog 			= createObject("component", "logwriter").init(VARIABLES.logpath, "favlog", VARIABLES.logtype);
favOut			= createObject("component", "logwriter").init(VARIABLES.logpath, "favOut.xml", VARIABLES.logtype, true);
dateLog 		= createObject("component", "logwriter").init(VARIABLES.logpath, "dateLog.log", VARIABLES.logtype, true);
VARIABLES.isSuccessful=true;


job_tickBegin=getTickCount();
job_tickEnd=0;
job_tickinterval=0;
favlog.write("#timeformat(now(), 'H:MM:SS')# Start *** VE Package and Send Favourites Data");

</cfscript>


<!--- *************************************************************
COPY SALES RECORDS OF ITEMS ORDERED TO ACCESS DB TABLE
******************************************************************* --->

<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
linebreak = "#chr(13)##chr(10)#";
</cfscript>


<cftry>
<cfquery name="qGetSOPITEM" datasource="veSageDb" result="qRes">
select ORDER_NUMBER, STOCK_CODE, DESCRIPTION, QTY_ORDER from SOP_ITEM
</cfquery>

<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetSOPITEM, fetched #qGetSOPITEM.recordcount# records in #tickinterval# ms");
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetSOPITEM SQL: #replace(qRes.sql, linebreak, ' ', 'ALL')#");
</cfscript>

<cfcatch type="database">
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query qGetSOPITEM failed in #tickinterval# ms");
	</cfscript>	
</cfcatch>
</cftry>


<!--- initialise counter and timer vars --->
<cfset i=1 />
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>


<cfquery name="tSOPITEMs" datasource="veAccessDB">
delete from SOP_ITEM_LOCAL
</cfquery>
<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Table SOP_ITEM_LOCAL truncated");
</cfscript>


<cfloop query="qGetSOPITEM">
<cfif ORDER_NUMBER NEQ -1>
<cftry>
<cfquery name="iSOPITEMs" datasource="veAccessDB">
insert into SOP_ITEM_LOCAL
(ORDER_NUMBER, STOCK_CODE, DESCRIPTION, QTY_ORDER)
VALUES (#ORDER_NUMBER#, '#STOCK_CODE#', '#DESCRIPTION#', #QTY_ORDER#)
</cfquery>

<!--- increment counter --->
<cfset i = i + 1 />

<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_row = i />
	<cfset error_values = "#ORDER_NUMBER#, '#STOCK_CODE#', '#DESCRIPTION#', #QTY_ORDER#" />
	<cfset error_text ="" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfbreak />	
</cfcatch>
</cftry>
</CFIF>
</cfloop>

<cfscript>
if (VARIABLES.isSuccessful) {
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: iSOPITEMs, inserted #i# records in #tickinterval# ms");
} else {
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: iSOPITEMs failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");

}
</cfscript>

<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
<cfoutput>Mission Aborted</cfoutput>
<cfabort />
</cfif>



<!--- *************************************************************
COPY SALES ORDER RECORDS TO ACCESS DB TABLE
******************************************************************* --->
<!--- initialise counter and timer vars --->
<cfset i=1 />
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>

<cftry>
<cfquery name="qGetOrders" datasource="veSageDb"  result="qRes">
SELECT ORDER_NUMBER AS ORDER_NUMBER, ACCOUNT_REF AS ACCOUNT_REF, ORDER_DATE AS ORDER_DATE, DESPATCH_STATUS AS DESPATCH_STATUS
FROM SALES_ORDER
WHERE DESPATCH_STATUS='Complete' And ORDER_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('d',VARIABLES.days,now())#">
</cfquery>
<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetOrders, fetched #qGetOrders.recordcount# records in #tickinterval# ms");
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetOrders SQL: #replace(qRes.sql, linebreak, ' ', 'ALL')#");
</cfscript>
<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_text ="" />
	<cfset error_row = "" />
	<cfset error_values = "" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: qGetOrders failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
	</cfscript>	
</cfcatch>
</cftry>


<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
<cfoutput>Mission Aborted</cfoutput>
<cfabort />
</cfif>

<!--- initialise counter and timer vars --->
<cfset i=1 />
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>

<cfquery name="tSALESORDERS" datasource="veAccessDB">
delete from SALES_ORDER_LOCAL
</cfquery>
<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Table SALES_ORDER_LOCAL truncated");
</cfscript>


<cfloop query="qGetOrders">
<cftry>	
<cfquery name="iOrders" datasource="veAccessDB">
insert into SALES_ORDER_LOCAL
(ORDER_NUMBER, ACCOUNT_REF, ORDER_DATE, DESPATCH_STATUS)
VALUES (#ORDER_NUMBER#, '#ACCOUNT_REF#', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ORDER_DATE#">, '#DESPATCH_STATUS#')
</cfquery>

<!--- increment counter --->
<cfset i = i + 1 />

<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_text ="" />
	<cfset error_row = i />
	<cfset error_values = "#ORDER_NUMBER#, '#ACCOUNT_REF#', #ORDER_DATE#, '#DESPATCH_STATUS#'" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	</cfscript>	
	<cfbreak />
</cfcatch>
</cftry>
</cfloop>

<cfscript>
if (VARIABLES.isSuccessful) {
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: iOrders, inserted #i# records in #tickinterval# ms");
} else {
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: iOrders failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#");

}
</cfscript>

<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
<cfoutput>Mission Failed</cfoutput>
<cfabort />
</cfif>

<!--- *************************************************************
FETCH ALL ORDERS AND DETAILS OF ITEMS ORDERED IN LAST 6 MONTHS
AND COPY INTO OUR ACCESS SUMMARY TABLE
******************************************************************* --->
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>

<cftry>
<cfquery name="qGetOrderItems" datasource="veAccessDB" result="qRes">
SELECT O.ORDER_NUMBER AS ORDER_NUMBER, O.ORDER_DATE AS ORDER_DATE, O.ACCOUNT_REF AS ACCOUNT_REF, S.STOCK_CODE AS STOCK_CODE, S.DESCRIPTION AS DESCRIPTION, S.QTY_ORDER AS QTY_ORDER
FROM SALES_ORDER_LOCAL AS O, SOP_ITEM_LOCAL AS S
WHERE O.ORDER_NUMBER=S.ORDER_NUMBER And O.ORDER_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('m',-6,now())#">
</cfquery>
<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetOrderItems, fetched #qGetOrders.recordcount# records in #tickinterval# ms");
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetOrderItems SQL: #replace(qRes.sql, linebreak, ' ', 'ALL')#");
</cfscript>
<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_text ="" />
	<cfset error_row = i />
	<cfset error_values = "#ORDER_NUMBER#, '#ACCOUNT_REF#', #ORDER_DATE#, '#DESPATCH_STATUS#'" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: qGetOrderItems failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
	</cfscript>	
</cfcatch>
</cftry>


<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfoutput>Mission Failed</cfoutput>
<cfabort />
</cfif>

<!--- initialise counter and timer vars --->
<cfset i=1 />
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>

<cfquery name="tOrderItems" datasource="veAccessDB">
delete from  tblOrderItem
</cfquery>
<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Table tblOrderItem truncated");
</cfscript>


<cfloop query="qGetOrderItems">

<cftry>
<cfquery name="iOrderItems" datasource="veAccessDB">
insert into tblOrderItem
(ORDER_NUMBER, ORDER_DATE, ACCOUNT_REF, STOCK_CODE, DESCRIPTION, QTY_ORDER )
VALUES (#ORDER_NUMBER#, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ORDER_DATE#">, '#ACCOUNT_REF#', '#STOCK_CODE#', '#DESCRIPTION#', #QTY_ORDER#)
</cfquery>

<!--- increment counter --->
<cfset i = i + 1 />

<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_row = i />
	<cfset error_values = "#ORDER_NUMBER#, #ORDER_DATE#, '#ACCOUNT_REF#', '#STOCK_CODE#', '#DESCRIPTION#', #QTY_ORDER#" />
	<cfset error_text ="" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	</cfscript>	
	<cfbreak />	
</cfcatch>
</cftry>
</cfloop>

<cfscript>
if (VARIABLES.isSuccessful) {
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: iOrderItems, inserted #i# records in #tickinterval# ms");
} else {
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: iOrderItems failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");

}
</cfscript>

<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
<cfoutput>Mission Failed</cfoutput>
<cfabort />
</cfif>


<!--- *************************************************************
WE CAN NOW SELECT THE DISTINCT ITEMS ORDER AND THE TOTAL ORDER COUNT
GROUPED BY ACCOUNTID AND ORDER ITEM. THIS IS THEN COPIED TO OUR
FAVOURITES SUMMARY TABLE
******************************************************************* --->
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>

<cftry>
<cfquery name="qGetFavourites" datasource="veAccessDB" result="qRes">
SELECT ACCOUNT_REF AS AccountID, STOCK_CODE AS StockCode, COUNT(*) AS OrderCount, SUM(QTY_ORDER) AS QtyToDate, MAX(ORDER_DATE) AS LastOrderDate
FROM tblOrderItem
GROUP BY ACCOUNT_REF, STOCK_CODE
HAVING COUNT(*)>=1
ORDER BY ACCOUNT_REF, STOCK_CODE
</cfquery>
<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetFavourites, fetched #qGetOrders.recordcount# records in #tickinterval# ms");
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: qGetFavourites SQL: #replace(qRes.sql, linebreak, ' ', 'ALL')#");
</cfscript>
<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_text ="" />
	<cfset error_row = 1 />
	<cfset error_values = "" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: qGetFavourites failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
	</cfscript>	
</cfcatch>
</cftry>



<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
<cfoutput>Mission Failed</cfoutput>
<cfabort />
</cfif>

<!--- initialise counter and timer vars --->
<cfset i=1 />
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>

<cfquery name="tFavourites" datasource="veAccessDB">
delete from tblFavourite
</cfquery>
<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Table tblFavourite	 truncated");
</cfscript>


<cfloop query="qGetFavourites">
<cftry>	
<cfquery name="iFavourites" datasource="veAccessDB">
insert into tblFavourite
(AccountID, StockCode, OrderCount, QtyToDate, LastOrderDate)
VALUES ('#AccountID#', '#StockCode#', #OrderCount#, #QtyToDate#, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LastOrderDate#">)
</cfquery>
<!--- increment counter --->
<cfset i = i + 1 />
<cfcatch type="database">
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_row = i />
	<cfset error_values = "'#AccountID#', '#StockCode#', #OrderCount#, #LastOrderDate#" />
	<cfset error_text ="" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	</cfscript>	
	<cfbreak />	
</cfcatch>
</cftry>
</cfloop>

<cfscript>
if (VARIABLES.isSuccessful) {
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: iFavourites, inserted #i# records in #tickinterval# ms");
} else {
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: iFavourites failed trying to insert records, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
}
</cfscript>

<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfoutput>Mission Failed</cfoutput>
<cfabort />
</cfif>



<!--- initialise counter and timer vars --->
<cfset i=1 />
<cfscript> 
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;
</cfscript>



<!--- ****************************************************************
UPDATE THE LASTORDERQUANTITY COLUMN
********************************************************************** --->

<cfquery name="gOrderItemsMaxDate" datasource="veAccessDB">
select   ACCOUNT_REF, STOCK_CODE, MAX(ORDER_DATE) AS MAXORDERDATE  FROM TBLORDERITEM
GROUP BY ACCOUNT_REF, STOCK_CODE
</cfquery>

<cfloop query="gOrderItemsMaxDate">
<cftry>
<cfquery name="gQtyLastOrder" datasource="veAccessDB">
select  ACCOUNT_REF, STOCK_CODE, QTY_ORDER
FROM TBLORDERITEM
WHERE ACCOUNT_REF = '#ACCOUNT_REF#'
AND STOCK_CODE = '#STOCK_CODE#'
AND ORDER_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#MAXORDERDATE#">
</cfquery>

<cfquery name="uFavourites" datasource="veAccessDB">
UPDATE TBLFAVOURITE
SET LASTORDERQUANTITY = #gQtyLastOrder.QTY_ORDER#
WHERE ACCOUNTID = '#gQtyLastOrder.ACCOUNT_REF#'
AND STOCKCODE = '#gQtyLastOrder.STOCK_CODE#'
</cfquery>

<!--- increment counter --->
<cfset i = i + 1 />


<cfcatch type="database">
	<cfrethrow />
	<cfset VARIABLES.isSuccessful=false />
	<cfset error_row = i />
	<cfset error_values = "'#gQtyLastOrder.Account_ref#', '#gQtyLastOrder.Stock_Code#', #gQtyLastOrder.QTY_ORDER#"/>
	<cfset error_text ="" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	</cfscript>	
	<cfbreak />	
</cfcatch>
</cftry>
</cfloop>

<cfscript>
if (VARIABLES.isSuccessful) {
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Query: uFavourites, inserted #i# records in #tickinterval# ms");
} else {
	favlog.write("#timeformat(now(), 'H:MM:SS')# Error - Query: uFavourites failed trying to update LastOrderQuantity, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
}
</cfscript>

<!--- If it failed abort mission! --->
<cfif NOT isSuccessful>
	<cfscript>
	favlog.write("#timeformat(now(), 'H:MM:SS')# Mission Aborted");
	</cfscript>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
<cfoutput>Mission Failed</cfoutput>
<cfabort />
</cfif>



<cfquery name="qFavourites" datasource="veAccessDB">
select * from tblFavourite
</cfquery>



<!--- *************************************************************
CONVERT TO WDDX
******************************************************************* --->
<cfwddx action="cfml2wddx" input="#qFavourites#" output="xmlFavaourites" />
<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Converted gFavourites query to XML");
</cfscript>


<!--- *************************************************************
WRITE TO FILE
******************************************************************* --->
<cftry>
<cffile action = "delete"  file = "C:\ColdFusion8\wwwroot\favOut.xml">
<cffile action = "delete"  file = "C:\ColdFusion8\wwwroot\dateLog.log">
<cfcatch type="any"></cfcatch>
</cftry>


<cfscript>
favOut.write(xmlFavaourites);
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Wrote Favourites XML to filesystem");
</cfscript>



<!--- *************************************************************
NOW FTP THE DATA TO THE WEB SERVER WHERE THE IMPORT JOB WILL PICK IT UP
******************************************************************* --->

<cftry>
<cfftp action = "open" username = "vegexp" connection = "veWebServer" password = "V1e1G0e2X7p6" server = "ftp.vegetarianexpress.co.uk" stopOnError = "Yes" timeout="3600" />
<cfftp connection = "veWebServer" action = "CHANGEDIR"   stopOnError = "Yes"  directory = "/httpdocs/xml_inbound/" />
<cfftp connection = "veWebServer" action = "putFile" name = "uploadFile" transferMode = "ascii" 
localFile = "C:\ColdFusion8\wwwroot\favOut.xml" failIfExists="No" timeout="3600" remoteFile = "favourites.xml" />

<cfftp action = "close" connection = "veWebServer" stopOnError = "Yes">

<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - FTP: Uploaded favOut.xml to /httpdocs/xml_inbound/favOut.xml");
isSuccessful=true;
</cfscript>
<cfcatch type="any">
<cfscript>
favlog.write("ERROR DURING FTP OPERATION: Failed to upload favOut.xml to /httpdocs/xml_inbound/favOut.xml");
isSuccessful=false;
</cfscript>
</cfcatch>
</cftry>


<!--- *************************************************************
NOW WRITE DATE LOG TO FILESYSTEM
******************************************************************* --->
<cftry>
<cfscript>
dateLog.write("#now()#");
dateLog.write(VARIABLES.days);
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - Wrote dateLog.log to filesystem");
isSuccessful=true;
</cfscript>
<cfcatch type="any">
favlog.write("ERROR : Failed to write dateLog.log to filesystem");
isSuccessful=false;
</cfcatch>
</cftry>


<!--- *************************************************************
NOW FTP THE datelog TO THE WEB SERVER WHERE THE IMPORT JOB WILL PICK IT UP
******************************************************************* --->
<cftry>
<cfftp action = "open" username = "vegexp" connection = "veWebServer" password = "V1e1G0e2X7p6" server = "ftp.vegetarianexpress.co.uk" stopOnError = "Yes" />
<cfftp connection = "veWebServer" action = "CHANGEDIR"   stopOnError = "Yes"  directory = "/httpdocs/xml_inbound/" />
<cfftp connection = "veWebServer" action = "putFile" name = "uploadFile" transferMode = "ascii" 
localFile = "C:\ColdFusion8\wwwroot\dateLog.log" remoteFile = "datelog.log" failIfExists="No" />
<cfftp action = "close" connection = "veWebServer" stopOnError = "Yes">

<cfscript>
favlog.write("#timeformat(now(), 'H:MM:SS')# Success - FTP: Uploaded datalog.log to /httpdocs/xml_inbound/datelog.log");
isSuccessful=true;
</cfscript>
<cfcatch type="any">
<cfscript>
favlog.write("ERROR DURING FTP OPERATION: Failed to upload dataLog.log to /httpdocs/xml_inbound/datelog.log");
isSuccessful=false;
</cfscript>
</cfcatch>
</cftry>




<cfscript>
job_tickEnd=getTickCount();
job_tickinterval=decimalformat((job_tickEnd-job_tickbegin)/1000);
favlog.write("#timeformat(now(), 'H:MM:SS')# End   *** VE Package and Send Favourites Data - Completed in #job_tickinterval# ms");
</cfscript>

<cfif isSuccessful>
<cfmail to="webmaster@vegetarianexpress.co.uk" from="cron@vegetarianexpress.co.uk" subject="VE Favourites Upload Successful" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Successful. Attached is log file.
</cfmail>
<cfelse>
<cfmail cc="webmaster@vegetarianexpress.co.uk" to="willmatier@vegexp.co.uk" from="cron@vegetarianexpress.co.uk" subject="ERROR: VE Favourites upload - see Attached CronLog" type="text">
<cfmailparam file = "#VARIABLES.logpath#favlog_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
Crontask: Upload Favourites Errored. Please read attached log file and take action if required.
</cfmail>
</cfif>
