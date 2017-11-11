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
request.xwtable.setValue(arguments.tblname,"colwidths", "26px,0,0,0,0,0,0,0,0,0"); 
request.xwtable.setValue(arguments.tblname,"alignment", "left,right,right,right,right,right,right,right,right,right"); 
request.xwtable.setValue(arguments.tblname,"caption","");
request.xwtable.setValue(arguments.tblname,"showcaption","No");
request.xwtable.setValue(arguments.tblname,"showFooter","No");
request.xwtable.setValue(arguments.tblname,"summary","Audit Queue");

// show table navigation at bottom rather than top
request.xwtable.setValue(arguments.tblname,"showNextofNtext","1");
request.xwtable.setValue(arguments.tblname,"showNavAtTop","0");
request.xwtable.setValue(arguments.tblname,"showNavAtBottom","0");

// show bottom border on last row?
request.xwtable.setValue(arguments.tblname,"showLastRowBottomBorder","1");


/*************************************************************
DATA FORMATTING
**************************************************************/
//column list, type and format
request.xwtable.setValue(arguments.tblname,"columnnamelist","WONUM,AMCLAIMEDTOTAL,NETPAYABLE,PROFIT,GROSSPAYABLE,AUDITDIFF,AUDITPCTDEDUC,AGREEDFINALACCOUNT,KPIPROFITABATEMENT,TOTALDUE");
request.xwtable.setValue(arguments.tblname,"columnSortable", "true,true,true,true,true,true,true,true,true,true");
request.xwtable.setValue(arguments.tblname,"columnShowHideTitleList", "1,1,1,1,1,1,1,1,1,1");
request.xwtable.setValue(arguments.tblname,"columntypelist","query,query,query,query,query,query,query,query,query,query");
request.xwtable.setValue(arguments.tblname,"columnformatlist","text,decimal,decimal,decimal,decimal,decimal,decimal,decimal,decimal,decimal");

//name of the query columns to be used in SQL query
request.xwtable.setValue(arguments.tblname,"querycolumnprimarykey","wonum");
request.xwtable.setValue(arguments.tblname,"querycolumnlist","WONUM,AMCLAIMEDTOTAL,NETPAYABLE,PROFIT,GROSSPAYABLE,AUDITDIFF,AUDITPCTDEDUC,AGREEDFINALACCOUNT,KPIPROFITABATEMENT,TOTALDUE");
request.xwtable.setValue(arguments.tblname,"querycolumnbindlist","WONUM,AMCLAIMEDTOTAL,NETPAYABLE,PROFIT,GROSSPAYABLE,AUDITDIFF,AUDITPCTDEDUC,AGREEDFINALACCOUNT,KPIPROFITABATEMENT,TOTALDUE");

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