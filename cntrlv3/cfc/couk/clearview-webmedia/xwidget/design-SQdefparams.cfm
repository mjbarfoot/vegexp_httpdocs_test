<cfscript>
/*************************************************************
FUNCTIONAL SETUP
**************************************************************/	
request.xwtable.setValue(arguments.tblname,"allowedParams", "");
request.xwtable.setValue(arguments.tblname,"cfcurl", "/couk/clearview-webmedia/xwidget/xwtable.cfc");
//disable filter
request.xwtable.setValue(arguments.tblname,"enableFilter","No");

/*************************************************************
VISUAL SETUP
**************************************************************/	
request.xwtable.setValue(arguments.tblname,"class", "qsdefault");
request.xwtable.setValue(arguments.tblname,"width", "100%");
request.xwtable.setValue(arguments.tblname,"colwidths", "26px,31px,75px,69px, ,65px,120px,61px,42px,92px"); 
request.xwtable.setValue(arguments.tblname,"alignment", "left,center,left,left,left,left,left,right,center,left"); 
request.xwtable.setValue(arguments.tblname,"caption","");
request.xwtable.setValue(arguments.tblname,"showcaption","No");
request.xwtable.setValue(arguments.tblname,"showFooter","No");
request.xwtable.setValue(arguments.tblname,"summary","Audit Queue");

// show table navigation at bottom rather than top
request.xwtable.setValue(arguments.tblname,"showNextofNtext","1");
request.xwtable.setValue(arguments.tblname,"showNavAtTop","0");
request.xwtable.setValue(arguments.tblname,"showNavAtBottom","1");

// show bottom border on last row?
request.xwtable.setValue(arguments.tblname,"showLastRowBottomBorder","1");


/*************************************************************
QUERY SETUP
**************************************************************/
//run the query and tell xwtable it's an external query
request.xwtable.setQuery(arguments.tblname, "sqlquery", SESSION.qry.selectqueue);
request.xwtable.setValue(arguments.tblname, "sqlquery_setexternal", "true");	
// set the table as the query name from query of query functionality
request.xwtable.setValue(arguments.tblname, "query.table", "SESSION.qry.selectqueue");

//request.xwtable.setValue(arguments.tblname,"type","query");
//request.xwtable.setValue(arguments.tblname,"query.dsn","#APPLICATION.dsn#");
//request.xwtable.setValue(arguments.tblname,"query.table","tblProducts");


/*************************************************************
DATA FORMATTING
**************************************************************/
//column list, type and format
request.xwtable.setValue(arguments.tblname,"columnnamelist","Show More,REMOVE,WONUM,SUPPLIER,DESCRIPTION,DATE REQUESTED,DATE FIN COMPLETED,AMCLM`D TOTAL,WORK TYPE,AUDIT STATUS");
request.xwtable.setValue(arguments.tblname,"columnSortable", "false,false,false,false,false,false,false,false,false,false");
request.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "0,1,1,1,1,1,1,1,1,1");
request.xwtable.setValue(arguments.tblname,"columntypelist","custom,custom,query,query,query,custom,custom,query,query,custom");
request.xwtable.setValue(arguments.tblname,"columnformatlist","text,text,text,text,text,text,text,text,text,text");

//name of the query columns to be used in SQL query
request.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","wonum");
request.xwtable.setValue(arguments.tblname,"querycolumnlist","WONUM,WORKTYPE,DESCRIPTION,SUPPLIER,DATE_FINCOMP,DATE_REQUESTED,DATE_PHYCOMP,AMCLMTOTAL,QSA_STATUS,SITEID,ORGID");
request.xwtable.setValue(arguments.tblname,"querycolumnbindlist","WONUM,SUPPLIER,DESCRIPTION,AMCLMTOTAL,WORKTYPE");

/*  custom column value list can include bind variable (primary key only) from the query using :{query column}
<a href="javascript:void(0)" onclick="editUser(':myquerycolumn')">edit</a> 
*/

request.xwtable.setValue(arguments.tblname,"customcolumnvaluelist", "getArrow(WONUM), getRemoveIcon(WONUM), qsdateformat(DATE_REQUESTED), qsdateformat(DATE_FINCOMP), qsstatus(QSA_STATUS)");
request.xwtable.setValue(arguments.tblname,"customcolumntypelist",  "function, function, function, function, function");

/*************************************************************
FINALLY SET TABLE LOADED
**************************************************************/
request.xwtable.setValue(arguments.tblname,"status",  "loaded");
</cfscript>