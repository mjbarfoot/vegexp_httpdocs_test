<!--- Imports Product data from a wddx file (products.xml) on the server
stored in the httpdocs/xml_inbound directory

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Convert products.xml to query object
1.1) remove zero padding
1.2) remove client specific product category
2) Insert them into a temporary table (tblProductsPad)
3) Remove any products from website product inventory whose stockcode is not in our temporary holding table
4) Update existing products
5) Add new Ones
6) Set any products to OutOfStock if price is 999.00
7) Check favourites for any items which are no longer stocked

--->	

<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="import Products";
VARIABLES.logFileName="crontsklog";
VARIABLES.productsXMLfilename="products.xml";
VARIABLES.listOfItemsRemoved="";
VARIABLES.listOutOfStock = "";
VARIABLES.listNewProducts = "";
VARIABLES.favouriteProductsRemoved="";
VARIABLES.totalImportProducts="";
VARIABLES.totalProductsAdded=0;
VARIABLES.totalProducstNotAdded=0;
VARIABLES.organicFlagSetCount=0;
VARIABLES.gfFlagSetCount=0;
VARIABLES.veganFlagSetCount=0
//time the task
VARIABLES.time_started=now();
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;

VARIABLES.linebreak = "#chr(13)##chr(10)#";

// dev of prod mode?
VARIABLES.isProduction = isProductionServer();

//email params
if (VARIABLES.isProduction) {
	VARIABLES.inbound_path="/var/www/orders.vegetarianexpress.co.uk/web/xml_inbound/";
	VARIABLES.logPath = "/var/www/orders.vegetarianexpress.co.uk/web/logs/";
	VARIABLES.email_notify=true;
	VARIABLES.email_notification_to = "philipcrawford@vegexp.co.uk";
	VARIABLES.email_notification_cc = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_from = "crontask@vegetarianexpress.co.uk";
} else {
	VARIABLES.inbound_path="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/xml_inbound/";
	VARIABLES.logPath = "/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";
	VARIABLES.email_notify=false;
	VARIABLES.email_notification_to = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_cc = "";
	VARIABLES.email_notification_from = "dev-crontask@vegetarianexpress.co.uk";
}

//setup log file
VARIABLES.logger = APPLICATION.crontsklog;
// *** END OF VARS *** //


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/
VARIABLES.logger.write("#timeformat(now(), 'h:mm:ss tt')# CRONJOB: #VARIABLES.crontaskName# - STARTED");

// 1) Convert products.xml to query object
q = getWDDXfromFilename(VARIABLES.inbound_path, VARIABLES.productsXMLfilename, VARIABLES.logger);


// 1.1) Get rid of padding zeros in stockCategoryNumber
qZeroRemoved = removeStockCatNumPaddedZeros(q);

q1= getWDDXfromFilename(VARIABLES.inbound_path, VARIABLES.productsXMLfilename, VARIABLES.logger);

// 1.2)remove client specific products == category 0925
qProd = removeClientSpecificProducts(qZeroRemoved);

</cfscript>
<!---
<Cfoutput>q1.recordcount: #q1.recordcount# qProd.recordcount: #qProd.recordcount#<Br /></cfoutput>
<cfloop query="q1">
	<cfquery name="chk" dbtype="query">
		select stockcode from qProd where stockcode = '#stockcode#'
	</cfquery>
	
	<cfif chk.recordcount eq 0>
		<!--- <cfoutput>stockcode: #stockcode#, stockcategorynumber: #stockcategorynumber#</cfoutput> --->
	</cfif>
	
</cfloop>

	<cfquery name="chk2" dbtype="query">
		select count(stockcode) from q1 where stockcategorynumber = '0925'
	</cfquery>
	
		<cfquery name="chk3" dbtype="query">
		select count(stockcode) from qProd where stockcategorynumber = '925'
	</cfquery>
	

<cfdump var="#qProd#"> 
<cfdump var="#chk2#">
<cfdump var="#chk3#">
<Cfabort/>--->

<cfscript>

// 2) Insert them into a temporary table (tblProductsPad)
// did we get a query object?
if (isQuery(qProd))  {
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = uploadToProductsPad(qProd);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	dump(qProd);
	abortTask(VARIABLES.logger);
}

// 3) Remove any products from website product inventory whose stockcode is not in our temporary holding table
isComplete = removeOldProducts();
if (NOT isComplete) abortTask(VARIABLES.logger);

// 4) Update existing products
qEP = getExistingProducts();
if (isQuery(qEP)) {
	isComplete = updateExistingProducts(qEP);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	dump(qEP);
	abortTask(VARIABLES.logger);
}


// 5) Add new Ones
qNP = getNewProducts();
if (isQuery(qNP)) {
	isComplete = addNewProducts(qNP);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	dump(qNP);
	abortTask(VARIABLES.logger);
}


// 6) Set any products to OutOfStock if price is 999.00

isComplete = setOutOfStockFlag(qProd);
if (NOT isComplete) abortTask(VARIABLES.logger);

// 7) Check favourites for any items which are no longer stocked
isComplete = removeOldProductsFromFavourites(qProd);
if (NOT isComplete) abortTask(VARIABLES.logger);


updateVeganGFOrg();

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


<cffunction name="removeStockCatNumPaddedZeros" output="false" returntype="any" hint="stips of zero-padding from the Stock Category Number">
<cfargument name="q" type="query" required="true" hint="">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cfloop query="q">
<cftry>
		
	<cfscript>
	QuerySetCell(q, "StockCategoryNumber", "#reReplace(StockCategoryNumber, '(0|00)(?=\d)', '')#", currentrow);
	</cfscript> 
	
	<cfif currentrow eq q.recordcount>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeStockCatNumPaddedZeros - updated #q.recordcount# records (#tickinterval# s)");
	ret= q;
	</cfscript> 
	</cfif>
	
<cfcatch type="any">
	
	<cfscript>
	formattedError=returnFormattedQueryError("removeStockCatNumPaddedZeros", "ARGUMENTS.q",  "UPDATE", cfcatch);
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

<cffunction name="removeClientSpecificProducts" output="false" returntype="any" hint="removes client specific products - category 0925">
<cfargument name="q" type="query" required="true" hint="">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
var deleteCount=0;
var deleteArray = Arraynew(1);

VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Started: removeClientSpecificProducts (#tickinterval# s)");
	
for (i=1; i lte q.recordcount; i=i+1) {
	if (q["StockCategoryNumber"][i] eq "925")  {
			q.removeRow(JavaCast( "int",i));
			i = i -1;
			VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Removed product:" &   q["stockcode"][i] & " StockCategoryNumber:" & q["StockCategoryNumber"][i]);			
			//deleteArray[deleteCount] = i;
				
	}
}

/* removeRows is quite difficult to use!
when deleting rows you specify the index you want to delete at, 
but for every row deleted you must reduce the index by one. 

i.e. if you have a 6 row query and you want to delete rows 2 and 3
you would write:
q.removeRows(2,1); // delete row 2 (proper code would would use javacast);
q.removeRows(2,1); // delete row 2, which used to be row 3 and is now row 2!

in the code below we use the iterator and subtract it from the row index stored in the array
because this will reduce a target index to delete at, but the number of rows already removed.
//for (i=1; i lte arraylen(deleteArray); i=i+1) {
	q.removeRows(JavaCast( "int", (deleteArray[i] - i)));
}
*/
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeClientSpecificProducts - deleted #arraylen(deleteArray)# records (#tickinterval# s)");

return q;
</cfscript> 
</cffunction>


<cffunction name="uploadToProductsPad" output="false" returntype="boolean" access="private">
<cfargument name="q" type="query" required="true" hint="a query object containing the product data" />

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
var i = 0;
</cfscript>

<!--- truncate data --->
<cftry>
	<cfquery name="qryInsertIntoPad" datasource="#APPLICATION.dsn#">
	DELETE FROM tblSageProductPad
	</cfquery>

	<!--- add to productpad --->
	<cfloop query="ARGUMENTS.q">
		<cfset i = i + 1 />
		<cfquery name="qryInsertIntoPad" datasource="#APPLICATION.dsn#">
		INSERT INTO tblSageProductPad
		(StockCode, SalePrice, Name, Description, StockCategoryNumber, UnitOfWeight, UnitOfSale, StockQuantity)
		values ('#StockCode#',#Saleprice#,'#Name#','#Description#', '#StockCategoryNumber#', #UnitOfWeight#, '#UnitOfSale#', #StockQuantity#)
		</cfquery>
	</cfloop>

	<cfset variables.totalImportProducts = i />

	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# Success: uploadToProductsPad - inserted  #i# records (#tickinterval# s)");
	ret=true;
	</cfscript>
	
<cfcatch type="any">
	<cfrethrow/>
	<cfscript>
	formattedError=returnFormattedQueryError("uploadToProductsPad", "tblSageProductPad",  "INSERT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>

    
    
</cfcatch>
</cftry>

<cfreturn ret />		
			

</cffunction>

<cffunction name="removeOldProducts" output="false" returntype="boolean" access="private">

<cfscript>
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var deleteCount =0;
var listItemsOld ="";
var qProductCount = "";
var qItemsToBeDeleted = "";

qProductCount = doSimpleQuery("SELECT count(StockID) as ""productCountOld"" FROM tblProducts", VARIABLES.logger);
qItemsToBeDeleted = doSimpleQuery("select stockcode from tblProducts where StockCode NOT IN (select StockCode from tblSageProductPad)", VARIABLES.logger);
VARIABLES.listOfItemsRemoved = ValueList(qItemsToBeDeleted.stockcode);
</cfscript>

<cftry>
	
	<!--- remove any that don't exist in sageUserPad --->
	<cfquery name="qryRemoveOldProducts" datasource="#APPLICATION.dsn#">
	DELETE FROM tblProducts
	where StockCode NOT IN (select StockCode from tblSageProductPad)
	</cfquery>
	
	<cfquery name="qryCountProductsNew" datasource="#APPLICATION.dsn#">
	SELECT count(StockID) as "productCountNew" FROM tblProducts 
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	deleteCount = val(qryCountProductsNew.productCountNew) - val(qProductCount.productCountOld); 
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# Deleted #deleteCount# records (#tickinterval# s)");
	ret=true;
	</cfscript>
	
<cfcatch type="any">
	
	<cfscript>
	formattedError=returnFormattedQueryError("removeOldProducts", "tblProducts",  "DELETE", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>

</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>

<cffunction name="getExistingProducts" output="false" returntype="any" hint="gets Stockcodes which exist on website and in Sage 200">
<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="q" datasource="#APPLICATION.dsn#" result="qRes">
	SELECT S.STOCKCODE AS STOCKCODE, S.SALEPRICE AS SALEPRICE, S.NAME AS NAME, S.DESCRIPTION AS DESCRIPTION, S.STOCKCATEGORYNUMBER AS STOCKCATEGORYNUMBER, S.UNITOFWEIGHT AS UNITOFWEIGHT, S.UNITOFSALE AS UNITOFSALE, S.STOCKQUANTITY
	FROM tblProducts P, tblSageProductPad S
	WHERE S.STOCKCODE = P.STOCKCODE
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: getExistingProducts - selected #q.recordcount# records (#tickinterval# s)");
	ret=q;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getExistingProducts", "tblProducts, tblSageProductPad",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


<cfreturn ret />

</cffunction>

<cffunction name="          getNewProducts" output="false" returntype="any" hint="gets Stockcodes which exist on website and in Sage 200">
<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="q" datasource="#APPLICATION.dsn#" result="qRes">
	SELECT S.STOCKCODE AS STOCKCODE, S.SALEPRICE AS SALEPRICE, S.NAME AS NAME, S.DESCRIPTION AS DESCRIPTION, S.STOCKCATEGORYNUMBER AS STOCKCATEGORYNUMBER, S.UNITOFWEIGHT AS UNITOFWEIGHT, S.UNITOFSALE AS UNITOFSALE, S.STOCKQUANTITY
	FROM tblSageProductPad S
	WHERE S.STOCKCODE NOT IN (SELECT STOCKCODE FROM tblProducts)
	</cfquery>
	
	<cfscript>
	VARIABLES.listNewProducts = ValueList(q.stockcode);	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: getNewProducts - selected #q.recordcount# records (#tickinterval# s)");
	ret=q;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getNewProducts", "tblProducts, tblSageProductPad",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


<cfreturn ret />

</cffunction>

<cffunction name="addNewProducts" output="true" returntype="any" hint="Updates info for existing products">
<cfargument name="q" type="query" required="true" hint="a query containing just the stockcode list for all products which exist on the website and in Sage 200">	

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- stop empty new product queries returning false --->
<cfif ARGUMENTS.q.recordcount eq 0>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: addNewProducts - No new Products to add (#tickinterval# s)");
	ret = true;
	</cfscript>
</cfif>


<cfloop query="ARGUMENTS.q">
 <cftry> 
	<cfquery name="verifyProduct" datasource="#APPLICATION.dsn#" result="qChk">
		select StockCode, StockCategoryNumber from tblProducts where StockCode = '#STOCKCODE#'		
	</cfquery>
	
	
	<cfif qChk.recordcount eq 0 >

<!--- 	<cfoutput><div>select StockCode, StockCategoryNumber from tblProducts where StockCode = '#STOCKCODE#' : #qChk.recordcount#</div></cfoutput>	 --->
			
	<cfquery name="i" datasource="#APPLICATION.dsn#" result="qRes"> 
	Insert into tblProducts
	(StockCode, StockCategoryNumber, Name, Description, UnitofSale, UnitofWeight, Saleprice, Organic, Vegan, GlutenFree, OutOfStock, StockQuantity, DateLastUpdated, TimeLastUpdated, LastModifiedBy)
	VALUES ('#STOCKCODE#','#STOCKCATEGORYNUMBER#','#REReplace(NAME,"\.*\s*\.C", "")#','#REReplace(DESCRIPTION,"\.*\s*\.C", "")#','#UNITOFSALE#',
			 #UNITOFWEIGHT#,#SALEPRICE#,0,0,0,0,<cfqueryparam cfsqltype="CF_SQL_FLOAT" value="#STOCKQUANTITY#">,
			 <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			 'CRONTASK');		 										
	</cfquery>
	

		<cfset VARIABLES.totalProductsAdded = VARIABLES.totalProductsAdded + 1>
	<cfelse>
		<cfset VARIABLES.totalProducstNotAdded = VARIABLES.totalProducstNotAdded + 1>
	</cfif>
	
	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: addNewProducts - ADDED #ARGUMENTS.q.recordcount# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>
	
<cfcatch type="any">
	<cfrethrow />
	
	<cfscript>
	formattedError=returnFormattedQueryError("addNewProducts", "tblProducts",  "INSERT", cfcatch);
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

<cffunction name="updateExistingProducts" output="false" returntype="any" hint="Updates info for existing products">
<cfargument name="q" type="query" required="true" hint="a query containing just the stockcode list for all products which exist on the website and in Sage 200">	

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- iterate over existing products list and update tblProducts--->
<cfloop query="ARGUMENTS.q">
<cftry>
	<cfquery name="i" datasource="#APPLICATION.dsn#" result="qRes">
	UPDATE 	tblProducts
	SET 	StockCategoryNumber = '#STOCKCATEGORYNUMBER#',
        	Name 		        = '#REReplace(NAME,"\.*\s*\.C", "")#', 
			Description 		= '#REReplace(DESCRIPTION,"\.*\s*\.C", "")#', 
			UnitofSale 			= '#UNITOFSALE#',
			UnitofWeight 		=  #UNITOFWEIGHT#,
			Saleprice 			=  #SALEPRICE#,
			Organic				=	0,
			Vegan				=	0,
			GlutenFree			=	0,
			OutOfStock			= 	0,
			DateLastUpdated 	= <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			TimeLastUpdated 	= <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			StockQuantity 		= <cfqueryparam cfsqltype="CF_SQL_FLOAT" value="#STOCKQUANTITY#">,
			LastModifiedBy 		= 'CRONTASK'										
	WHERE 	StockCode 			= '#STOCKCODE#';
	</cfquery>
	
	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: updateExistingProducts - UPDATED #ARGUMENTS.q.recordcount# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>
	
<cfcatch type="any">
	
	<cfscript>
	formattedError=returnFormattedQueryError("updateExistingProducts", "tblProductse",  "UPDATE", cfcatch);
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

<cffunction name="setOutOfStockFlag" output="false" returntype="any" hint="sets the OutOFStock Flag in tblProducts if the price of a product is 999.00">
<cfargument name="q" type="query" required="true" hint="a products query containing stockcode and salesprice properties">	

<cfscript> 
var i = 0;
var e = 0;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cfloop query="ARGUMENTS.q">
<cfif STOCKQUANTITY eq 0>	
	<cftry>
		<cfset i = i + 1/>
		
		<cfquery name="qUpd" datasource="#APPLICATION.dsn#" result="qRes">
		UPDATE tblProducts
		SET OUTOFSTOCK = 1
		WHERE STOCKCODE = '#STOCKCODE#'
		</cfquery>
		
		
		<cfif VARIABLES.listOutOfStock eq "">
			<cfset VARIABLES.listOutOfStock = "#Stockcode#">
		<cfelse>
			<cfset VARIABLES.listOutOfStock = VARIABLES.listOutOfStock & "," & "#Stockcode#">
		</cfif>
				
	<cfcatch type="any">
		<cfrethrow />
		<cfscript>
		formattedError=returnFormattedQueryError("setOutOfStockFlag", "tblProducts",  "UPDATE", cfcatch);
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
		</cfscript>	
		
		<cfbreak />
	</cfcatch>
	</cftry>
</cfif>

<cfif currentrow eq ARGUMENTS.q.recordcount>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: setOutOfStockFlag - UPDATED #i# records (#tickinterval# s)");
	ret = true;
	</cfscript> 
</cfif>

</cfloop>

<cfreturn ret />

</cffunction>

<cffunction name="removeOldProductsFromFavourites" returntype="any" output="true" acess="private">
<cfargument name="q" type="query" required="true" hint="a products query containing stockcode and salesprice properties">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cfloop query="ARGUMENTS.q">
<cfif left(StockCategoryNumber, 1) eq "9">
	<cftry>
	
		<cfquery name="qFavCheck" datasource="#APPLICATION.dsn#"> 
		SELECT 1 FROM tblFavourite
		WHERE  STOCKCODE = '#STOCKCODE#'
		</cfquery>
		
		<cfif qFavCheck.recordcount gt 0>
		<!--- remove the product from the favourites table --->
		<cfquery name="qRemoveFromFavourites" datasource="#APPLICATION.dsn#"> 
		DELETE FROM tblFavourite
		WHERE  STOCKCODE = '#STOCKCODE#'
		</cfquery>
		
		<cfif VARIABLES.favouriteProductsRemoved eq "">
			<cfset VARIABLES.favouriteProductsRemoved = "#StockCode#" />
		<cfelse>
			<cfset VARIABLES.favouriteProductsRemoved = VARIABLES.favouriteProductsRemoved & "," & "#StockCode#" />
		</cfif>
	
		<cfset i = i + 1/>
	
	</cfif>
	
	<cfcatch type="any">
		
		<cfscript>
		formattedError=returnFormattedQueryError("qRemoveFromFavourites", "TBLFAVOURITE",  "DELETE", cfcatch);
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
		</cfscript>	
		
		<cfbreak />
		
	</cfcatch>
	</cftry>
</cfif>

<cfif currentrow eq q.recordcount>
		
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeOldProductsFromFavourites - REMOVED #i# records (#tickinterval# s)");
		ret= true;
		</cfscript>
		 
</cfif>

</cfloop>


<cfif listlen(VARIABLES.listOfItemsRemoved) gt 0>
<cftry>
<cfquery name="qRemoveFromFavourites2" datasource="#APPLICATION.dsn#" result="res">  
	DELETE FROM tblFavourite
	WHERE  STOCKCODE IN (
	<cfloop from="1" to="#listlen(VARIABLES.listOfItemsRemoved)#" index="i">	
		<!--- check whether to add trailing comma --->
		<cfif i eq listlen(VARIABLES.listOfItemsRemoved)>
		'#listGetAt(VARIABLES.listOfItemsRemoved, i)#'
		<cfelse>
		'#listGetAt(VARIABLES.listOfItemsRemoved, i)#',
		</cfif>
	</cfloop>
	)
</cfquery> 

	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeOldProductsFromFavourites: deleted records matching VARIABLES.listOfItemsRemoved records  (#tickinterval# s)");
	ret= true;
	</cfscript>
	
	
<cfcatch type="any">
	<cfscript>
		formattedError=returnFormattedQueryError("qRemoveFromFavourites2", "TBLFAVOURITE",  "UPDATE", cfcatch);
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError & "sql: #res.sql#");
		ret=false;
	</cfscript>	
</cfcatch>
</cftry>
<Cfelse>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeOldProductsFromFavourites: no further records to delete - VARIABLES.listOfItemsRemoved empty (#tickinterval# s)");
	ret= true;
	</cfscript>

</cfif>

<cfreturn ret />

</cffunction>

<cffunction name="updateVeganGFOrg" returntyoe="any" output="true" access="private">

 
	<cfquery name="qryGetProducts" datasource="#APPLICATION.dsn#">
	select StockID, Name from tblProducts
	</cfquery>
	
	<cfset updatecount=0>
	<cfset errorCount=0>
	<cfset found_in_desc=false>

	<cfloop query="qryGetProducts">
		
<cfif FindNoCase("(Gluten Free)",Name) or Find("(GF)",Name)>
	<cfset query_col="GlutenFree">
	<cftry>

		<cfquery name="qryUpdateProductClassification" datasource="#APPLICATION.dsn#">
		update tblProducts
		set #query_col# = 1
		where StockID = #StockID#
		</cfquery>

		<cfset gfFlagSetCount=gfFlagSetCount+1>

		<cfcatch type="database">
			<cfset errorCount=errorCount+1>
				<cfscript>
				//write errors
				application.crontsklog.write("Update Failed: Database error while updating tblProducts column #query_col# for stockid: #stockid# to 1");
				</cfscript>
		</cfcatch>
	</cftry>
	</cfif>
			
 	<cfif FindNoCase("(ORG)", Name)>
		<cfset query_col="Organic">
		<cftry>
	
			<cfquery name="qryUpdateProductClassification" datasource="#APPLICATION.dsn#">
			update tblProducts
			set #query_col# = 1
			where StockID = #StockID#
			</cfquery>
	
			<cfset organicFlagSetCount=organicFlagSetCount+1>
	
		<cfcatch type="database">
			<cfset errorCount=errorCount+1>
				<cfscript>
				//write errors
				application.crontsklog.write("Update Failed: Database error while updating tblProducts column #query_col# for stockid: #stockid# to 1");
				</cfscript>
		</cfcatch>
		</cftry>
	</cfif> 
	
	<cfif FindNoCase("(Vegan)",Name)>
		<cfset query_col="Vegan">
		<cftry>
	
			<cfquery name="qryUpdateProductClassification" datasource="#APPLICATION.dsn#">
			update tblProducts
			set #query_col# = 1
			where StockID = #StockID#
			</cfquery>
	
			<cfset VARIABLES.veganFlagSetCount=VARIABLES.veganFlagSetCount+1>
	
			<cfcatch type="database">
				<cfset errorCount=errorCount+1>
					<cfscript>
					//write errors
					application.crontsklog.write("Update Failed: Database error while updating tblProducts column #query_col# for stockid: #stockid# to 1");
					</cfscript>
			</cfcatch>
		</cftry>
	
	</cfif>

	<!---check for DO NOT USE in description, sometimes this is set, but the stockcategory has not been updated--->
	<cfif FindNoCase("Do Not Use", Name) NEQ 0>
			<cftry>
	
			<cfquery name="qryDisableDoNotUseProducts" datasource="#APPLICATION.dsn#">
			update tblProducts
			set Department = 0
			where StockID = #StockID#
			</cfquery>
	
			<cfset updatecount=updatecount+1>
	
		<cfcatch type="database">
			<cfset errorCount=errorCount+1>
				<cfscript>
				//write errors
				application.crontsklog.write("Update Failed: Database error while updating tblProducts column Department for stockid: #stockid# to 0 - found Do Not Use in description");
				</cfscript>
		</cfcatch>
		</cftry>
	</cfif>


</cfloop>

</cffunction>



<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title>VE Crontask: Update Products</title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <link rel="icon" href="favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
  <style>
	h1,h2 {font-family: Courier; font-size: 1.2em;}
	p {font-family: Courier; font-size: 1em;}
</style>	
</head>		
<body>
	<h1>Crontask: Update Products - Started at: #timeformat(VARIABLES.time_started, "H:MM:SS TT")#, Completed at: #timeformat(now(), "H:MM:SS TT")#, Duration: #VARIABLES.task_tickinterval# Seconds</h1>
	<h2>Results</h2>
	<p>
	Product count from XML sent from Sage Web Server: #VARIABLES.totalImportProducts#</br>	
	Products removed from Website Inventory (Deleted in Sage): #VARIABLES.listOfItemsRemoved#<br />
	Product Count added to Website #VARIABLES.totalProductsAdded# <br/>
	Product Count Not Added to Website: #VARIABLES.totalProducstNotAdded# <br/>	
	Products Added to Website Inventory: #VARIABLES.listNewProducts# <br />
	Products set as Out of Stock (999.99): #VARIABLES.listOutOfStock#<br />
	Products removed from Favourites (Products with Stock Category 9xx): #VARIABLES.favouriteProductsRemoved#<br />
	Products set with organic flag: #VARIABLES.organicFlagSetCount#<br/>
	Products set with vegan flag:#VARIABLES.veganFlagSetCount# <br/>
	Products set with gluten free flag: #VARIABLES.gfFlagSetCount# <br/>
	</p>
</body>
</html>
</cfoutput>