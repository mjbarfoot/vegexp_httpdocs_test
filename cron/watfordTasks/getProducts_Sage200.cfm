<!--- Gets a list of products from Sage 200. The Aspidistra
web service does not retrieve required fields
and UnitOfWeight is not included in Sage200. This is required
for PackSize on website.

Created for: Vegetarian Express
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Extract query
2) Covert to WDDX
3) Write to filesystem
4) FTP to Server
--->

<!--- include common utility functions --->
<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
    VARIABLES.crontaskName="upload Products";
    VARIABLES.crontaskDesc="Exports Product List from Sage 200 database and FTPs XML to website on a daily basis";
    VARIABLES.LOGGERS = structnew();
    VARIABLES.LOGGERS["getProductsLog"] = structnew();
    VARIABLES.LOGGERS["getProductsLog"].name = "getProductsLog";
    VARIABLES.LOGGERS["products.xml"] = structnew();
    VARIABLES.LOGGERS["products.xml"].name ="products.xml";

//time the task
    VARIABLES.task_tickBegin=getTickCount();
    VARIABLES.task_tickEnd=0;
    VARIABLES.task_tickinterval=0;
// *** END OF VARS *** //


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/

// *** setup the files to write output to.
// products.xml and getproducts.log for wddx xml and log file for cron task progress respectively
    setUpFileWriters();

// *** 1) Extract product data from database
    q = getProductsFromSage();

// did we get a query object?
    if (isQuery(q))  {

// 2) Convert to WDDX and 3) Write to FileSystem
        isComplete = writeProductsXML(q);
        if (NOT isComplete) abortTask(getLogger("getProductsLog"));
    } else {
        abortTask(getLogger("getProductsLog"), VARIABLES.LOGGERS["getProductsLog"].name);
    }

// 4) Ftp to Server
// *** ftp the favourites.xml file to the VE Web Server
    isComplete = ftpToWebServer("products.xml", getLogger("getProductsLog"));

    if (isComplete) {
        setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
    } else {
        abortTask(getLogger("getProductsLog"), VARIABLES.LOGGERS["getProductsLog"].name);
    }


/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getProductsFromSage" output="false" returntype="any" hint="extracts product data from Sage 200">

    <cfscript>
        var i = 1;
        var tickBegin=getTickCount();
        var tickEnd=0;
        var tickinterval=0;
        var ret=false;
    </cfscript>

    <cftry>

        <cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
SELECT     dbo.StockItem.ItemID,
		   dbo.StockItem.Code AS stockcode,
		   dbo.StockItem.FreeStockQuantity AS StockQuantity,
		   dbo.StockItem.Name,
		   dbo.StockItem.Description AS Description,
		   dbo.ProductGroup.Code as StockCategoryNumber,
           dbo.StockItem.Weight UnitOfWeight,
           dbo.StockItemPrice.Price SalePrice,
           dbo.StockItemPrice.PriceBandID ,
           dbo.StockItem.SpareText1 UnitOfSale,
           dbo.StockItem.StockItemStatusID
FROM         dbo.StockItem INNER JOIN dbo.StockItemPrice ON dbo.StockItem.ItemID = dbo.StockItemPrice.ItemID
			 INNER JOIN dbo.ProductGroup on dbo.StockItem.ProductGroupID = dbo.ProductGroup.ProductGroupID
WHERE     (dbo.StockItemPrice.PriceBandID = 1001) AND (dbo.StockItem.StockItemStatusID = 0)
ORDER BY dbo.ProductGroup.Code asc
	<!---SELECT S.ITEMID, S.CODE as STOCKCODE,
	CASE
	WHEN
		((W.ConfirmedQtyInStock + W.UnconfirmedQtyInStock) - ( W.QuantityAllocatedBOM +  w.QuantityAllocatedSOP
	 	+ w.QuantityAllocatedStock + w.QuantityOnPOPOrder + w.QuantityReserved)) > 0
	 THEN 	((W.ConfirmedQtyInStock + W.UnconfirmedQtyInStock) - ( W.QuantityAllocatedBOM +  w.QuantityAllocatedSOP
	 		+ w.QuantityAllocatedStock + w.QuantityOnPOPOrder + w.QuantityReserved))
	ELSE 0
	END AS STOCKQUANTITY,
	S.NAME AS NAME, S.DESCRIPTION AS DESCRIPTION, P.CODE AS STOCKCATEGORYNUMBER, S.WEIGHT AS UNITOFWEIGHT, PR.PRICE AS SALEPRICE, S.SPARETEXT1 AS UNITOFSALE
	FROM STOCKITEM S, PRODUCTGROUP P, STOCKITEMPRICE PR, WAREHOUSEITEM W
	WHERE S.PRODUCTGROUPID = P.PRODUCTGROUPID
	AND S.ITEMID = PR.ITEMID
	AND S.ITEMID = W.ITEMID
	AND PR.PRICEBANDID = '1001'
	AND S.STOCKITEMSTATUSID = 0
	ORDER BY P.CODE ASC	--->
        </cfquery>

        <cfscript>

            tickEnd=getTickCount();
            tickinterval=decimalformat((tickend-tickbegin)/1000);
                getLogger("getProductsLog").write("#timeformat(now(), 'H:MM:SS')# Success: getProductsFromSage - fetched #q.recordcount# records in #tickinterval# ms");
            ret = q;
        </cfscript>

        <cfcatch type="any">
            <cfscript>
                formattedError=returnFormattedQueryError("getProductsFromSage", "STOCKITEM,PRODUCTGROUP",  "SELECT", cfcatch);
                tickEnd=getTickCount();
                tickinterval=decimalformat((tickend-tickbegin)/1000);
                    getLogger("getProductsLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
            </cfscript>
        </cfcatch>
    </cftry>

    <cfreturn ret />


</cffunction>

<cffunction name="writeProductsXML" output="false" returntype="boolean" hint="writes out products as WDDX packet">
    <cfargument name="q" type="query" required="true" hint="a query containing product data" />

    <cfscript>
        var tickBegin=getTickCount();
        var tickEnd=0;
        var tickinterval=0;
        var ret=false;
    </cfscript>


    <cfwddx action="cfml2wddx" input="#ARGUMENTS.q#" output="productsXML" />


    <cfscript>
        tickEnd=getTickCount();
        tickinterval=decimalformat((tickend-tickbegin)/1000);
            getLogger("products.xml").write(trim(productsXML));
            getLogger("getProductsLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeProductsXML - Wrote Products XML to filesystem (#tickinterval# s)");
    </cfscript>

    <cfreturn true/>
</cffunction>