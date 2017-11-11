<cfscript>
APPLICATION.xwtable.setValue(arguments.tblname,"allowedParams", "showProducts,CategoryID");
APPLICATION.xwtable.setValue(arguments.tblname,"cfcurl", "/cfc/xwtable/xwtable.cfc");
APPLICATION.xwtable.setValue(arguments.tblname,"class", "products");
APPLICATION.xwtable.setValue(arguments.tblname,"width", "697px");
APPLICATION.xwtable.setValue(arguments.tblname,"colwidths", "427px,60px,60px,50px,50px,50px"); 
APPLICATION.xwtable.setValue(arguments.tblname,"alignment", "left,left,left,left,left,left"); 
APPLICATION.xwtable.setValue(arguments.tblname,"caption","List of #arguments.tblname# available");
APPLICATION.xwtable.setValue(arguments.tblname,"showcaption","No");
APPLICATION.xwtable.setValue(arguments.tblname,"showFooter","No");
APPLICATION.xwtable.setValue(arguments.tblname,"summary","List of #arguments.tblname# available");
APPLICATION.xwtable.setValue(arguments.tblname,"type","query");
APPLICATION.xwtable.setValue(arguments.tblname,"query.dsn","#APPLICATION.dsn#");
APPLICATION.xwtable.setValue(arguments.tblname,"query.table","tblProducts");

//disable filter
APPLICATION.xwtable.setValue(arguments.tblname,"enableFilter","No");

// show table navigation at bottom rather than top
APPLICATION.xwtable.setValue(arguments.tblname,"showNavAtTop","0");
APPLICATION.xwtable.setValue(arguments.tblname,"showNavAtBottom","1");

// show bottom border on last row?
APPLICATION.xwtable.setValue(arguments.tblname,"showLastRowBottomBorder","1");

//column list, type and format
/*
APPLICATION.xwtable.setValue(arguments.tblname,"columnnamelist","Description, Pack Size, Portion Cost, Price, More Information, Add to Basket");
APPLICATION.xwtable.setValue(arguments.tblname,"columnSortable", "Description,UnitOfSale,false,SalePrice,false,false");
APPLICATION.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "1,1,1,1,1,1");
APPLICATION.xwtable.setValue(arguments.tblname,"columntypelist","custom, query, custom, custom, custom, custom");
APPLICATION.xwtable.setValue(arguments.tblname,"columnformatlist","text, text, decimal, decimal, text, text");
*/
//name of the query columns to be used in SQL query
//APPLICATION.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","stockid");
/*
APPLICATION.xwtable.setValue(arguments.tblname,"querycolumnlist","Stockid, Description, UnitofSale, SalePrice, StockQuantity");
APPLICATION.xwtable.setValue(arguments.tblname,"querycolumnbindlist","UnitofSale");

APPLICATION.xwtable.setValue(arguments.tblname,"customcolumnvaluelist", "convertCodesToIcons(Description;StockID;StockQuantity), getDiscountedPrice(SalePrice), prodInfoLinks(StockID), Add2BasketLinks(StockID;StockQuantity)");
APPLICATION.xwtable.setValue(arguments.tblname,"customcolumntypelist",  "function, function, function, function");
*/

APPLICATION.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","stockid");
APPLICATION.xwtable.setValue(arguments.tblname,"querycolumnlist","StockID, Description, UnitofSale, SalePrice, OutOfStock, StockQuantity,IsFavourite");
APPLICATION.xwtable.setValue(arguments.tblname,"querycolumnbindlist","UnitofSale");
APPLICATION.xwtable.setValue(arguments.tblname,"columnSortable","Description,UnitofSale,SalePrice,false,false,false,false");
	
	//override columns, no portion cost for ambient
	//column list, type and format
APPLICATION.xwtable.setValue(arguments.tblname,"columnnamelist","Description, Pack Size, Portion Cost, Price, More Information, Add to Basket");
APPLICATION.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "1,1,1,1,1,1");
APPLICATION.xwtable.setValue(arguments.tblname,"columntypelist","custom, query, custom, custom, custom, custom");
APPLICATION.xwtable.setValue(arguments.tblname,"columnformatlist","text, text, text, text, text, text");				
APPLICATION.xwtable.setValue(arguments.tblname,"customcolumnvaluelist", "convertCodesToIcons(Description;StockID;StockQuantity;IsFavourite),getPortionSize(UnitOfSale;SalePrice),getDiscountedPrice(SalePrice), prodInfoLinks(StockID), Add2BasketLinks(StockID;StockQuantity)");
APPLICATION.xwtable.setValue(arguments.tblname,"customcolumntypelist",  "function, function, function, function, function");









/*  custom column value list can include bind variable (primary key only) from the query using :{query column}
<a href="javascript:void(0)" onclick="editUser(':myquerycolumn')">edit</a> 
*/

// <div style='position:relative'><a id='prodinfo:stockid' class='prodinfo' href='/showProductInfo.cfm?ProductID=:stockid'>More info</a></div> 


APPLICATION.xwtable.setValue(arguments.tblname,"status",  "loaded");
</cfscript>