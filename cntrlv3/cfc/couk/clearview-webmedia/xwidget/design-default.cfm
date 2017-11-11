<cfscript>
request.xwtable.setValue(arguments.tblname,"allowedParams", "showProducts,CategoryID");
request.xwtable.setValue(arguments.tblname,"cfcurl", "/cfc/xwtable/xwtable.cfc");
request.xwtable.setValue(arguments.tblname,"class", "products");
request.xwtable.setValue(arguments.tblname,"width", "697px");
request.xwtable.setValue(arguments.tblname,"colwidths", "427px,60px,60px,50px,50px,50px"); 
request.xwtable.setValue(arguments.tblname,"alignment", "left,left,left,left,left,left"); 
request.xwtable.setValue(arguments.tblname,"caption","List of #arguments.tblname# available");
request.xwtable.setValue(arguments.tblname,"showcaption","No");
request.xwtable.setValue(arguments.tblname,"showFooter","No");
request.xwtable.setValue(arguments.tblname,"summary","List of #arguments.tblname# available");
request.xwtable.setValue(arguments.tblname,"type","query");
request.xwtable.setValue(arguments.tblname,"query.dsn","#APPLICATION.dsn#");
request.xwtable.setValue(arguments.tblname,"query.table","tblProducts");

//disable filter
request.xwtable.setValue(arguments.tblname,"enableFilter","No");

// show table navigation at bottom rather than top
request.xwtable.setValue(arguments.tblname,"showNavAtTop","0");
request.xwtable.setValue(arguments.tblname,"showNavAtBottom","1");

// show bottom border on last row?
request.xwtable.setValue(arguments.tblname,"showLastRowBottomBorder","1");

//column list, type and format
request.xwtable.setValue(arguments.tblname,"columnnamelist","Description, Pack Size, Portion Cost, Price, More Information, Add to Basket");
request.xwtable.setValue(arguments.tblname,"columnSortable", "Description,UnitOfSale,false,SalePrice,false,false");
request.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "1,1,1,1,1,1");
request.xwtable.setValue(arguments.tblname,"columntypelist","custom, query, custom, custom, custom, custom");
request.xwtable.setValue(arguments.tblname,"columnformatlist","text, text, decimal, decimal, text, text");

//name of the query columns to be used in SQL query
request.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","stockid");
request.xwtable.setValue(arguments.tblname,"querycolumnlist","Description, UnitofSale, SalePrice, OutOfStock");
request.xwtable.setValue(arguments.tblname,"querycolumnbindlist","UnitofSale");

/*  custom column value list can include bind variable (primary key only) from the query using :{query column}
<a href="javascript:void(0)" onclick="editUser(':myquerycolumn')">edit</a> 
*/

// <div style='position:relative'><a id='prodinfo:stockid' class='prodinfo' href='/showProductInfo.cfm?ProductID=:stockid'>More info</a></div> 
request.xwtable.setValue(arguments.tblname,"customcolumnvaluelist", "convertCodesToIcons(Description;StockID), getPortionSize(UnitofSale;SalePrice), getDiscountedPrice(SalePrice), prodInfoLinks(StockID), Add2BasketLinks(StockID;OutOfStock)");
request.xwtable.setValue(arguments.tblname,"customcolumntypelist",  "function, function, function, function, function");

request.xwtable.setValue(arguments.tblname,"status",  "loaded");
</cfscript>