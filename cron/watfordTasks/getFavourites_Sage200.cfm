<!--- Get Favourites Data: Retrieves data out of a SQLServer Sage 200 database
for a given data range and analyses to provide the following data:
AccountID, StockCode, OrderCount, QtyToDate, LastOrderDate, LastOrderQuantity
This is used by the website to provide customers with their favourites tab

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) truncate fav db tables ready for import of data from sage
2) copy n days worth of orders into Orders table
3) copy related Order lines into OrderLines table
4) copy grouped data into tblFavourites so we have 1 row for each account ref and stock_code with the last order date
5) check all orders in Sage last month to find out which accounts have ordered which lines and how many times each item has been ordered
6) update our output table tblFavourites with this data and also the last order quantity
7) export the table as wddx xml and a log file with containing the number of days specified
8) ftp to the server
9) email the log file of how it all went
--->	


<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="upload Favourites";
VARIABLES.crontaskDesc="Exports Customer Favourites from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getFavouritesLog"] = structnew();
VARIABLES.LOGGERS["getFavouritesLog"].name = "getFavouritesLog";
VARIABLES.LOGGERS["favourites.xml"] = structnew();
VARIABLES.LOGGERS["favourites.xml"].name = "favourites.xml";
VARIABLES.LOGGERS["dateLog.log"] = structnew();
VARIABLES.LOGGERS["dateLog.log"].name = "dateLog.log";

//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;
// the number of days to get favourites data for	
VARIABLES.days="-14";

// *** END OF VARS *** //

/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/

// *** setup the files to write output to. 
// logger.log to record progress, favOut.xml to save the favourites xml, dataLog.log 
setUpFileWriters();


// *** truncate tables in the FAV db to get it ready for imports
isComplete = clearUpFavDB();
if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);


// *** copy Sales Orders into our Favourites DB  
q = getSalesOrdersFromSage(VARIABLES.days);

// did we get a query object?
if (isQuery(q)) {
	isComplete = putSalesOrdersInFavDB(q);
	if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
} else {
	abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}



// *** copy the all the items ordered into our Favourites DB 
q = getSalesOrderLinesFromSage();

if (isQuery(q)) {
	isComplete = putSalesOrderItemsInFavDB(q);
	if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
} else {
	abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}

// *** get combined OrderItems query and copy into tblFavourite in Favourites DB
q = getOrderItems();

if (isQuery(q)) {
	isComplete = copyToTblOrderItem(q);
	if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
} else {	
	abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}

// *** from TblOrderItem get a grouped query with account_ref, stock_code, lastorderdate
q = getGroupedAccountAndStockCodes();

if (isQuery(q)) {
	isComplete = copyGroupedDataToTblFavourites(q);
	if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
} else {
	abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}



// *** get the last ordered quantity for each item
q = getQtyToDateForLastSixMonthsFromSage(); 
if (isQuery(q)) {
	isComplete = updateQtyToDate(q);
	 if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
} else {	
	 abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}

// *** get the last order quantity from tblOrderItem
q = getLastOrderQuantity(); 

if (isQuery(q)) {
	isComplete = updateLastOrderQuantity(q);
	if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
} else {	
	abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}

// *** clean any rows with null values for order_count or qty to date
isComplete = cleanNullFavourites();
if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);

// *** write favourites to file system as WDDX packets
isComplete = writeFavourites();
if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);

// *** write a datalog file containing the number of days we retrieved order data for
isComplete = writeDatelog();
if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);

// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("favourites.xml",getLogger("getFavouritesLog"));
if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);

// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("dateLog.log", getLogger("getFavouritesLog"));
if (NOT isComplete) abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);


VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);

// *** Job Done
getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# CRONJOB: getFavourites - COMPLETE. Duration #VARIABLES.task_tickinterval#  s");

//emailLogFiles(isComplete=true,logFileName=VARIABLES.logFileName,crontaskName=VARIABLES.crontaskName);

if (isComplete) {
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getFavouritesLog"), VARIABLES.LOGGERS["getFavouritesLog"].name);
}

</cfscript>



<cffunction name="clearUpFavDB" output="false" returntype="boolean" hint="truncates the Fav DB data tables to get it ready for new import of data, returns true if completes successfully">

<cfscript> 
// use a stop watch to time it
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;

var isComplete=false;
</cfscript>

<cftry>

	<!--- truncate SOP sales orders --->
	<cfquery name="q" datasource="veFavDB">
	truncate table tblSOPOrder
	</cfquery>
	<!--- truncate SOP sales order itemsl--->
	<cfquery name="q" datasource="veFavDB">
	truncate table tblSOPItem
	</cfquery>
	<!--- truncate tblOrderItem --->
	<cfquery name="q" datasource="veFavDB">
	truncate table tblOrderItem
	</cfquery>
	<!--- truncate tblFavourite --->
	<cfquery name="q" datasource="veFavDB">
	truncate table tblFavourite
	</cfquery>

	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# clearUpFavDB Successful (#tickinterval# s)");
		
	isComplete=true;
	</cfscript>

<cfcatch type="any">

	<cfscript>
	formattedError=returnFormattedQueryError("clearUpFavDB", "tblSOPOrder,tblSOPItem,tblOrderItem,tblFavourite",  "TRUNCATE", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
	

</cfcatch>
</cftry>

<cfreturn isComplete />

</cffunction>

<cffunction name="getSalesOrdersFromSage" output="false" returntype="any" hint="retrieves Sales Order data from the VE Sage 200 Database">
<cfargument name="days" required="true" type="numeric" hint="The number of days going backwards from today to retrieve sales orders for">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="qGetOrders" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT SOR.SOPORDERRETURNID AS ORDER_ID, SOR.DOCUMENTNO AS ORDER_NUMBER, SCA.CUSTOMERACCOUNTNUMBER AS ACCOUNT_REF, SOR.REQUESTEDDELIVERYDATE AS ORDER_DATE, 'COMPLETE' AS DESPATCH_STATUS 
	FROM SOPORDERRETURN SOR, SLCUSTOMERACCOUNT SCA 
	WHERE SCA.SLCUSTOMERACCOUNTID = SOR.CUSTOMERID 
	AND SOR.PROMISEDDELIVERYDATE >= <CFQUERYPARAM CFSQLTYPE="CF_SQL_TIMESTAMP" VALUE="#DATEADD('D',ARGUMENTS.DAYS,NOW())#">
	AND SOR.DOCUMENTNO NOT LIKE '##%' <!--- ADDED TO PARSE OUT STRANGE ORDERS BEGINNING WITH ### --->
	</cfquery>
	
	<cfscript>	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Success: qGetOrders - fetched #qGetOrders.recordcount# records in #tickinterval# ms");
	ret = qGetOrders;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getSalesOrdersFromSage", "SOPORDERRETURN,SLCUSTOMERACCOUNT",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>

<cffunction name="putSalesOrdersInFavDB" output="false" returntype="boolean" hint="loops throught the passed query of Sales Order data and adds it to tblSOPOrders">
<cfargument name="qGetOrders" type="query" required="true" hint="The Sales Orders query">

<cfscript> 
var i = 0;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<cfloop query="ARGUMENTS.qGetOrders">
	<cftry>
		<cfset i = i+1/>
	
		<cfquery name="q" datasource="#VARIABLES.FavDB_dsn#"  result="qRes">
		INSERT INTO tblSOPOrder
		(ORDER_ID, ORDER_NUMBER, ACCOUNT_REF, ORDER_DATE, DESPATCH_STATUS)
		VALUES ('#ORDER_ID#', '#ORDER_NUMBER#', '#trim(ACCOUNT_REF)#', <CFQUERYPARAM CFSQLTYPE="CF_SQL_TIMESTAMP" VALUE="#ORDER_DATE#">, '#DESPATCH_STATUS#')
		</cfquery>		
	
	<cfcatch type="database">
		<cfscript>
		formattedError=returnFormattedQueryError("putSalesOrdersInFavDB", "tblSOPOrder",  "insert", cfcatch, "occurred at order number: #ORDER_ID#");
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
		</cfscript>
		
		<cfset ret = false />
		<cfbreak />
			
	</cfcatch>
	</cftry>

	<!--- if all ok and about to exit loop --->
	<cfif currentrow eq ARGUMENTS.qGetOrders.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Success: putSalesOrdersInFavDB - inserted #i# records in #tickinterval# ms");	
		ret = true;
		</cfscript>
	</cfif>
</cfloop>


<cfreturn ret />

</cffunction>
			
<cffunction name="getSalesOrderLinesFromSage" output="false" returntype="any" hint="retrieves Sales Order Lines for the orders stored in tblSOPOrder">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- get the orders for our specified date range --->
<cftry>
	<cfquery name="g" datasource="#VARIABLES.FavDB_dsn#"  result="qRes">
	SELECT ORDER_ID, ORDER_NUMBER FROM tblSOPOrder
	</cfquery>

<cfcatch type="any">
	<cfset error_text ="" />
	<cfset error_row = "n/a" />
	<cfset error_values = "" />
	<cfif isdefined("cfcatch.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
	<cfif isdefined("cfcatch.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
	<cfif isdefined("cfcatch.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
	<cfif isdefined("cfcatch.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Error: getSalesOrderLinesFromSage failed trying to get Orders from tblSOPOrder, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
	
	</cfscript>	
</cfcatch>
</cftry>


<!--- new query object to hold the data we grab from sage--->
<cfscript>
qOrderLines = querynew("ORDER_ID,ORDER_NUMBER,STOCK_CODE,DESCRIPTION,QTY_ORDER");
</cfscript>


<!--- iterate through them and get the relevant order lines --->
<cfloop query="g">
	
	<!--- get order lines --->
	<cftry>
		<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes">
		SELECT '#ORDER_ID#' as ORDER_ID, '#ORDER_NUMBER#' as ORDER_NUMBER, ItemCode as STOCK_CODE, ItemDescription as DESCRIPTION, LineQuantity as QTY_ORDER FROM SOPOrderReturnLine
		WHERE 	SOPOrderReturnID = '#ORDER_ID#'
		</cfquery>
		
		<!--- the query may return multiple lines so just add each to qOrderLines--->
		<cfloop query="q">
			<cfset temp = QueryAddRow(qOrderLines)>		
			<cfset temp = QuerySetCell(qOrderLines, "ORDER_ID", "#ORDER_ID#") />
			<cfset temp = QuerySetCell(qOrderLines, "ORDER_NUMBER", "#ORDER_NUMBER#") />
			<cfset temp = QuerySetCell(qOrderLines, "STOCK_CODE", "#STOCK_CODE#") />
			<cfset temp = QuerySetCell(qOrderLines, "DESCRIPTION", "#DESCRIPTION#") />
			<cfset temp = QuerySetCell(qOrderLines, "QTY_ORDER", "#QTY_ORDER#") />
		</cfloop>
		
	<cfcatch type="database">
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
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Error: getSalesOrderLinesFromSage getting records from SOPOrderReturnLine, erroring row was #error_row#, tried to insert values #error_values#, error details: #error_text#");
		</cfscript>
		
		<cfset ret=false />
			
		<cfbreak />
	</cfcatch>	
	</cftry>
	

<!--- if loop about to exit, set ret to point to our query object: qOrderLines and send this back instead --->
<cfif currentrow eq g.recordcount>
	<cfset ret = qOrderLines>
</cfif>

</cfloop>
<cfreturn ret />

</cffunction>

<cffunction name="putSalesOrderItemsInFavDB" output="false" returntype="boolean" hint="iterates through passed query and updates FavDB with the Sage Order Line data">
<cfargument name="q" required="true" type="query" hint="a query object containing Sage 200 Order Line Data">

<cfscript> 
var i = 0;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
var formattedError="";
</cfscript>

<cfloop query="q">
	<cfset i = i+1/>
	
	<cftry>
	   <cfquery name="g" datasource="#VARIABLES.FavDB_dsn#"  result="qRes">
		INSERT INTO tblSOPItem
		(ORDER_ID, ORDER_NUMBER, STOCK_CODE, DESCRIPTION, QTY_ORDER)
		values ('#ORDER_ID#', '#ORDER_NUMBER#', '#STOCK_CODE#', '#DESCRIPTION#', #QTY_ORDER#)
		</cfquery>
	<cfcatch type="database">
	
		<cfscript>
		// log error
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		formattedError=returnFormattedQueryError("putSalesOrderItemsInFavDB", "tblSOPItem",  "insert", cfcatch, "occurred at order number: #ORDER_NUMBER#");
		formattedError=returnFormattedQueryError("putSalesOrderItemsInFavDB", "tblSOPItem",  "insert", cfcatch, "OrderID: #Order_ID# Order Number:#ORDER_NUMBER# Stock Code: #STOCK_CODE# Description: #DESCRIPTION# Qty_Order: #QTY_ORDER#");
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
		</cfscript>
		
		
		
		<cfset ret=false />	
		<cfbreak />
		
	</cfcatch>
	</cftry>
	
	<!--- if lastrow of loop, all updates OK --->
	<cfif currentrow eq q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Success: putSalesOrderItemsInFavDB - inserted #i# records (#tickinterval# s)");
		ret = true;
		</cfscript>
	</cfif>	
</cfloop>	

<cfreturn ret />
</cffunction>

<cffunction name="getOrderItems" output="false" returntype="any" hint="gets combined query of order details and items">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="qGetOrderItems" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	SELECT O.ORDER_NUMBER AS ORDER_NUMBER, O.ORDER_DATE AS ORDER_DATE, O.ACCOUNT_REF AS ACCOUNT_REF, S.STOCK_CODE AS STOCK_CODE, S.DESCRIPTION AS DESCRIPTION, S.QTY_ORDER AS QTY_ORDER
	FROM tblSOPOrder AS O, tblSOPItem AS S
	WHERE O.ORDER_NUMBER = S.ORDER_NUMBER
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: getOrderItems - selected #qGetOrderItems.recordcount# records (#tickinterval# s)");
	ret=qGetOrderItems;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("copyToTblOrderItem", "tblSOPItem",  "select", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret>
</cffunction>

<cffunction name="copyToTblOrderItem" output="false" returntype="any" hint="inserts query object into tblOrderItem in Favourites DB">
<cfargument name="q" type="query" required="true" hint="a combined sales order and items query object">	

<cfscript> 
var i = 0;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- iterate and insert order data --->
<cfloop query="ARGUMENTS.q">
<cftry>
	
	<cfset i = i+1/>
	
	<cfquery name="qIns" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	insert into tblOrderItem
	(ORDER_NUMBER, ORDER_DATE, ACCOUNT_REF, STOCK_CODE, DESCRIPTION, QTY_ORDER )
	VALUES (#ORDER_NUMBER#, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ORDER_DATE#">, '#ACCOUNT_REF#', '#STOCK_CODE#', '#DESCRIPTION#', #QTY_ORDER#)
	</cfquery>
			
	<cfcatch type="any">
	
		<cfscript>
			formattedError=returnFormattedQueryError("copyToTblOrderItem", "tblSOPItem",  "select", cfcatch);
			tickEnd=getTickCount();
			tickinterval=decimalformat((tickend-tickbegin)/1000);
			getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
		</cfscript>	
		
		<cfbreak />
		
	</cfcatch>
</cftry>

<cfif currentrow eq ARGUMENTS.q.recordcount>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: copyToTblOrderItem  - inserted #i# records (#tickinterval# s)");
	ret=true;
	</cfscript> 
</cfif>

</cfloop>

<cfreturn ret />

</cffunction>

<cffunction name="getGroupedAccountAndStockCodes" output="false" returntype="any" hint="gets data for how many times items have been ordered">


<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="q" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	SELECT ACCOUNT_REF, STOCK_CODE, MAX(ORDER_DATE) AS LastOrderDate
	FROM tblOrderItem
	GROUP BY ACCOUNT_REF, STOCK_CODE
	HAVING COUNT(*)>=1
	ORDER BY ACCOUNT_REF, STOCK_CODE
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: getGroupedAccountAndStockCodes -  selected #q.recordcount# records (#tickinterval# s)");
	ret=q;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getGroupedAccountAndStockCodes", "tblOrderItem",  "select", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


<cfreturn ret />


</cffunction>

<cffunction name="copyGroupedDataToTblFavourites" output="false" returntype="any" hint="copies a query containing popularity of order items into the tblFavrouites table in Fav DB">
<cfargument name="q" type="query" required="true" hint="the query containing sales order item popularity">	

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- iterate over popularity data --->
<cfloop query="ARGUMENTS.q">
<cftry>
	
	<cfquery name="qIns" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	INSERT INTO TBLFAVOURITE
	(ACCOUNT_REF, STOCK_CODE, LASTORDERDATE)
	VALUES ('#ACCOUNT_REF#', '#STOCK_CODE#', <CFQUERYPARAM CFSQLTYPE="CF_SQL_TIMESTAMP" VALUE="#LASTORDERDATE#">)
	</cfquery>
	
	<!--- about to exit loop, then write log and send back true --->
	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: copyGroupedDataToTblFavourites - inserted #ARGUMENTS.q.recordcount# records (#tickinterval# s)");
		ret= true;
		</cfscript> 
	</cfif>
	
<cfcatch type="database">
	<cfscript>
	formattedError=returnFormattedQueryError("copyGroupedDataToTblFavourites", "tblFavourite",  "insert", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
	
	<cfset ret=false />
	<cfbreak />
</cfcatch>
</cftry>
</cfloop>


<cfreturn ret />

</cffunction>

<cffunction name="getQtyToDateForLastSixMonthsFromSage" output="false" returntype="any" hint="finds the number of times each item in tblFavourites has been ordered in the last six months">


<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cftry>
<!--- get all sales order lines for last 6 months organised by customer account ref and stockcode with qty to date and order count --->
	<cfquery name="qGetQtyToDate" datasource="#VARIABLES.Sage200_dsn#" result="qRes" blockfactor="100">
	SELECT 	C.CUSTOMERACCOUNTNUMBER AS ACCOUNT_REF,
			L.ITEMCODE AS STOCK_CODE,
			COUNT(*) AS ORDER_COUNT,
			SUM(L.DESPATCHRECEIPTQUANTITY) AS DESPATCHED_QTY,
			SUM(L.LINEQUANTITY) AS QTY_TO_DATE
	FROM SOPORDERRETURN S, SOPORDERRETURNLINE L, SLCUSTOMERACCOUNT C
	WHERE S.SOPORDERRETURNID = L.SOPORDERRETURNID
	AND S.CUSTOMERID = C.SLCUSTOMERACCOUNTID 
	AND L.REQUESTEDDELIVERYDATE > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('m',-6,now())#">
	AND S.DOCUMENTSTATUSID = 2
	AND L.LINEQUANTITY =  L.DESPATCHRECEIPTQUANTITY
	GROUP BY C.CUSTOMERACCOUNTNUMBER, L.ITEMCODE
	ORDER BY C.CUSTOMERACCOUNTNUMBER ASC, L.ITEMCODE ASC
	</cfquery>

	<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: getQtyToDateForLastSixMonthsFromSage - selected #qGetQtyToDate.recordcount# records (#tickinterval# s)");
		ret	= qGetQtyToDate;
	</cfscript> 
	
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getQtyToDateForLastSixMonthsFromSage", "SOPORDERRETURN S, SOPORDERRETURNLINE L, SLCUSTOMERACCOUNT C",  "select", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />

</cffunction>

<!--- Notes about this function 
workflow: 
1) passed a query containing 6 months worth of order lines ~ 30K-60K rows (more as turnover increases)
2) in tblFavourite is probably only hundeds of rows
3) iterate over tblFavourite then search 6 month order lines query object using QofQ to find match
4) update tblFavourite with QtyToDate value

Alternative method is to iterate over order lines query (30-60K rows) and match rows from tblFavourites.
This was slow in testing. Using of QoQ to hold query in memory and match against was fast!

If any problems then another table could be introduced to hold order lines query then do the update
as a db statement i.e. 

UPDATE  tblFavourite
SET  QtyToDate = (select  QtyToDate 
FROM my_qty_to_date_table where ACCOUNT_REF = tblFavouite.ACCOUNT_REF 
AND STOCK_CODE = tblFavourite.STOCK_CODE),
ORDER_COUNT = select ORDER_COUNT 
FROM my_qty_to_date_table where ACCOUNT_REF = tblFavouite.ACCOUNT_REF 
AND STOCK_CODE = tblFavourite.STOCK_CODE)

this may be slower still as it just shifts processing overhead to db engine instead
--->
<cffunction name="updateQtyToDate" output="false" returntype="any" hint="updates Order_Count and QtyToDate properties in Fav DB">
<cfargument name="q" type="query" required="true" hint="a query containing Order_Count and QtyToDate">	

<cfscript> 
var i = 0;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- get favourites table data --->
<cfquery name="gFavs" datasource="#VARIABLES.FavDB_dsn#" result="qRes">	
SELECT ACCOUNT_REF, STOCK_CODE FROM TBLFAVOURITE 
</cfquery>

<cfloop query="gFavs">
<cftry>
	<!--- check whether our current row is in the result set which contains last 6 months worth of order lines --->
	<cfquery name="gQtyToDateRec" dbtype="query">
	SELECT ORDER_COUNT, QTY_TO_DATE
	FROM ARGUMENTS.Q
	WHERE ACCOUNT_REF = '#trim(ACCOUNT_REF)#'
	AND STOCK_CODE = '#trim(STOCK_CODE)#'
	</cfquery>
	
	<cfif gQtyToDateRec.recordcount eq 1>
		<cfset i = i + 1/>
		
		<cfquery name="qUpd" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
		UPDATE tblFavourite
		SET ORDER_COUNT = #gQtyToDateRec.ORDER_COUNT#,
			QTYTODATE = #gQtyToDateRec.QTY_TO_DATE#
		WHERE ACCOUNT_REF = '#ACCOUNT_REF#'
		AND STOCK_CODE = '#STOCK_CODE#'		
		</cfquery>
		
	</cfif>

	<!--- last iteration so write log and return value --->
	<cfif currentrow eq gFavs.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: updateQtyToDate - updated #i# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>

<cfcatch type="any">
	<cfrethrow />
	<cfscript>
	formattedError=returnFormattedQueryError("updateQtyToDate", "tblFavourite",  "UPDATE", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	

	<cfbreak />
	
</cfcatch>
</cftry>	
</cfloop>


<cfreturn ret />

</cffunction>

<cffunction name="getLastOrderQuantity" output="false" returntype="any" hint="gets lastOrderQuantity taken from tblOrderItem">

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="q" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	SELECT t1.ACCOUNT_REF, t1.STOCK_CODE, t1.QTY_ORDER as LASTORDERQUANTITY
	FROM tblOrderItem t1 where t1.ORDER_DATE =  
	(select MAX(t2.ORDER_DATE) FROM tblOrderItem t2 where t2.ACCOUNT_REF = t1.ACCOUNT_REF
	and t2.STOCK_CODE = t1.STOCK_CODE)
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: getLastOrderQuantity - selected #q.recordcount# records (#tickinterval# s)");
	ret=q;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getLastOrderQuantity", "tblOrderItem",  "select", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


<cfreturn ret />

</cffunction>

<cffunction name="updateLastOrderQuantity" output="false" returntype="any" hint="updates LastOrderQuantity in tblFavourites in Fav DB">
<cfargument name="q" type="query" required="true" hint="">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- iterate over last quanity query and update each row in tblFavourite --->
<cfloop query="ARGUMENTS.q">
<cftry>
	<cfquery name="qIns" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	UPDATE tblFavourite
	SET LASTORDERQUANTITY = #LASTORDERQUANTITY#
	WHERE ACCOUNT_REF = '#ACCOUNT_REF#'
	AND STOCK_CODE = '#STOCK_CODE#'
	</cfquery>
	
	 
	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: updateLastOrderQuantity - updated #ARGUMENTS.q.recordcount# records (#tickinterval# s)");
		ret= true;
		</cfscript>
	</cfif>
	
	
<cfcatch type="any">
	<cfrethrow />
	<cfscript>
	formattedError=returnFormattedQueryError("updateLastOrderQuantity", "tblFavourite",  "update", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
	<cfbreak />	
	
</cfcatch>
</cftry>
</cfloop>

<cfreturn ret />

</cffunction>

<cffunction name="cleanNullFavourites" output="false" returntype="any" hint="removes any rows from the favourites table which have null values for order_count or qtytodate">

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="q" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	DELETE FROM TBLFAVOURITE
	WHERE ORDER_COUNT IS NULL AND QTYTODATE IS NULL
	</cfquery>
	
	<cfquery name="q" datasource="#VARIABLES.FavDB_dsn#" result="qRes">
	DELETE FROM TBLFAVOURITE
	WHERE STOCK_CODE = ''
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & "Success: cleanNullFavourites (#tickinterval# s)");
	ret=true;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("cleanNullFavourites", "tblFavourite",  "DELETE", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


<cfreturn ret />

</cffunction>

<cffunction name="writeFavourites" output="false" returntype="boolean" hint="writes out tblFavourites as WDDX packet">

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cfquery name="qFavourites" datasource="#VARIABLES.FavDB_dsn#">
select * from tblFavourite order by ACCOUNT_REF ASC, STOCK_CODE ASC
</cfquery>

<cfwddx action="cfml2wddx" input="#qFavourites#" output="xmlFavaourites" />


<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
getLogger("favourites.xml").write(trim(xmlFavaourites));
getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeFavourites - Wrote Favourites XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>

<cffunction name="writeDateLog" output="false" returntype="boolean" hint="writes out datelog as WDDX packet">

<cfscript> 
var ret = false;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
</cfscript>


<cftry>
<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
getLogger("dateLog.log").write("#now()#");
getLogger("dateLog.log").write(VARIABLES.days);
getLogger("getFavouritesLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeDateLog - Wrote dateLog.log to filesystem. (#tickinterval# s)");
ret=true;
</cfscript>
<cfcatch type="any">
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);	
getLogger("getFavouritesLog").write("Error: writeDateLog - Failed to write dateLog.log to filesystem (#tickinterval# s)");
ret=false;
</cfcatch>
</cftry>
<cfreturn ret/>
</cffunction>
