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
request.xwtable.setValue(arguments.tblname,"colwidths", "26px,0,0,0,0,0,0"); 
request.xwtable.setValue(arguments.tblname,"alignment", "right,right,right,right,right,right,right"); 
request.xwtable.setValue(arguments.tblname,"caption","");
request.xwtable.setValue(arguments.tblname,"showcaption","No");
request.xwtable.setValue(arguments.tblname,"showFooter","No");
request.xwtable.setValue(arguments.tblname,"summary","Audit Queue");

// show table navigation at bottom rather than top
request.xwtable.setValue(arguments.tblname,"showNextofNtext","0");
request.xwtable.setValue(arguments.tblname,"showNavAtTop","0");
request.xwtable.setValue(arguments.tblname,"showNavAtBottom","0");

// show bottom border on last row?
request.xwtable.setValue(arguments.tblname,"showLastRowBottomBorder","1");


/*************************************************************
DATA FORMATTING
**************************************************************/
//column list, type and format
request.xwtable.setValue(arguments.tblname,"columnnamelist","TOTAL AMCLMED,TOTAL ADTDFF,TOTAL GROSSPYBLE,TOTAL NETPYBLE,TOTAL PRFT,TOTAL FNLACC,TOTAL TOTALDUE");
request.xwtable.setValue(arguments.tblname,"columnSortable", "false,false,false,false,false,false,false");
request.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "1,1,1,1,1,1,1,1,1,1");
request.xwtable.setValue(arguments.tblname,"columntypelist","query,query,query,query,query,query,query");
request.xwtable.setValue(arguments.tblname,"columnformatlist","decimal,decimal,decimal,decimal,decimal,decimal,decimal");

//name of the query columns to be used in SQL query
request.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","TOTAL_AMCLMED");
request.xwtable.setValue(arguments.tblname,"querycolumnlist","TOTAL_AMCLMED,TOTAL_ADTDFF,TOTAL_GROSSPYBLE,TOTAL_NETPYBLE,TOTAL_PRFT,TOTAL_FNLACC,TOTAL_TOTALDUE");
request.xwtable.setValue(arguments.tblname,"querycolumnbindlist","TOTAL_AMCLMED,TOTAL_ADTDFF,TOTAL_GROSSPYBLE,TOTAL_NETPYBLE,TOTAL_PRFT,TOTAL_FNLACC,TOTAL_TOTALDUE");

/*  custom column value list can include bind variable (primary key only) from the query using :{query column}
<a href="javascript:void(0)" onclick="editUser(':myquerycolumn')">edit</a> 
*/

request.xwtable.setValue(arguments.tblname,"customcolumnvaluelist", "");
request.xwtable.setValue(arguments.tblname,"customcolumntypelist",  "");

/*************************************************************
FINALLY SET TABLE LOADED
**************************************************************/
request.xwtable.setValue(arguments.tblname,"status",  "loaded");
</cfscript>