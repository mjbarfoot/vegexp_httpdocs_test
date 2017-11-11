<cfscript>
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"cfcurl", "/cfc/xwtable/xwtable.cfc");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"class", "cntrl");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"caption","#arguments.tblname#");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"showcaption","No");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"footerNavStyle","default");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"showFooter","No");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"summary","#arguments.tblname#");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"type","query");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"query.dsn","#APPLICATION.dsn#");

// rows per page
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"rowsPerPage","20");

// show table navigation at bottom rather than top
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"showNavAtTop","1");
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"showNavAtBottom","1");

// show bottom border on last row?
APPLICATION.widgets.xwtable.setValue(arguments.tblname,"showLastRowBottomBorder","1");


// ----------------------/ DISABLED PARAMETERS /---------------------------------- //

//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"width", "697px");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"colwidths", "427px,60px,60px,50px,50px,50px"); 
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"alignment", "left,left,left,left,left,left"); 

//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"query.table","tblProducts");

//disable filter
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"enableFilter","No");

//column list, type and format
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"columnnamelist","Description, Pack Size, Portion Cost, Price £, More Information, Add to Basket");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "1,1,1,1,1,1");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"columntypelist","custom, query, custom, query, custom, custom");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"columnformatlist","text, text, decimal, decimal, text, text");

//name of the query columns to be used in SQL query
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","stockid");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"querycolumnlist","Description, UnitofSale, SalePrice");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"querycolumnbindlist","UnitofSale, SalePrice");

//  custom column value list can include bind variable (primary key only) from the query using :{query column}
//<a href="javascript:void(0)" onclick="editUser(':myquerycolumn')">edit</a> 
//

// <div style='position:relative'><a id='prodinfo:stockid' class='prodinfo' href='/showProductInfo.cfm?ProductID=:stockid'>More info</a></div> 
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"customcolumnvaluelist", "convertCodesToIcons(Description;StockID), getPortionSize(UnitofSale;SalePrice), prodInfoLinks(StockID),<a class='addtobasket' href='#cgi.script_name#?#xmlformat(cgi.QUERY_STRING)#&amp;ev=basket&amp;action=Add&amp;ProductID=:stockid'>Add</a>");
//APPLICATION.widgets.xwtable.setValue(arguments.tblname,"customcolumntypelist",  "function, function, function, URI");


APPLICATION.widgets.xwtable.setValue(arguments.tblname,"status",  "loaded");
</cfscript>