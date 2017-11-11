<cfif NOT isdefined("msg")>
<cfabort />
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
#wrapper {margin-left: 100px; margin-right: auto; width: 700px; padding: 1em; border: 1px solid #177730;}
#logo {background: url(http://localhost:8050/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
#header {height: 20px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: #177730; color: White; padding-left: 14px;}
p {magin-bottom: 1.6em;}
p a {color: #177730;}
#questions {background-image: url(http://localhost:8050/pix/icon-info.gif); background-position: top left; background-repeat: no-repeat; padding-left: 70px; margin-bottom: 1em;}

/* Datatable */
table.datatable {padding: 0;margin-top: 1em; width: 97%; border: 1px solid black; border-collapse:collapse;}	
table.datatable tr {border: 0; background-color: White; font-size: 0.75em; border-right: 1px solid black;  border-left: 1px solid black;}
table.datatable tr th {font-weight: normal; background-color: #177730; color: White; text-align: left; padding: 0.2em 0.5em;}
table.datatable tr th a, table.datatable tr.altrow th a {color: White; text-decoration: underline;}
table.datatable tr.altrow th {background-color: #269944;}
	
/* Table Rows: colmn borders for left and right outermost cells */ 
table.datatable tr th.lhscol, table.datatable tr td.lhscol, table.datatable tr.altrow th.lhscol, table.datatable tr.altrow td.lhscol {border-left: 1px solid black;} 
table.datatable tr th.rhscol, table.datatable tr td.rhscol, table.datatable tr.altrow th.rhscol, table.datatable tr.altrow td.rhscol {border-right: 1px solid black;}

/* Table Rows: if no records are found */ 
table.datatable tr td.norecfound {padding: 2em 1em; color: Red;}

/* Table Rows: altrow background color */ 
table.datatable tr.altrow {border: 0;  background-color: #F4F4F4;}

/* Table Rows: row borders */ 
table.datatable tr td, table.datatable tr.altrow td {padding: 0.2em 0.5em; border-left:1px solid #cccccc; border-right: 1px solid #cccccc; border-bottom: 1px solid #cccccc;}

/* Table Rows: No bottom border on last row */ 
table.datatable tr.nobtmbdr td {border-bottom: none;}

table.datatable tr.lastrow td {bottom-border: 1px solid black;}

</style>
</head>
<body>
<div id="wrapper">
	<cfoutput>
	<div id="logo"></div>
	<div id="header">
		<h1>#Msg.title#</h1>
	</div>
	<table class="datatable">
	<thead>
	<tr>
		<th colspan="3">WebOrderID</th>
		<th>AccountID</th>
		<th>OrderDate</th>
		<th>OrderTime</th>
		<th>Amount</th>
	</tr>
	</thead>
	<tbody>
	<cfloop query="Msg.Body">
	<tr<cfif currentrow mod 2 eq 0> class="altrow"</cfif>>
		<td class="lhscol" colspan="3">#WebOrderID#</td>
		<td>#AccountID#</td>
		<td>#LSDateFormat(OrderDate, "DD/MM/YYY")#</td>
		<td>#LSTimeFormat(OrderTime, "H:MM TT")#</td>
		<td class="rhscol">#DecimalFormat(Amount)#</td>
	</tr>
	<tr<cfif currentrow mod 2 eq 0> class="altrow <cfif currentrow eq Msg.Body.recordCount>nobtmbdr</cfif>"</cfif>>
		<td class="lhscol rhscol" colspan="7">Status: #OrderStatus# - #OrderStatusDesc# </td>
	</tr>
	</cfloop>
	</tbody>
	</table>
	<p>
	You can view details for these orders by following this link: <br/><br />
	<a href="http://#CGI.SERVER_NAME#/cntrl/index.cfm?ObjectID=88722-82872788-09729872">http://vegexp.clearview-webmedia.co.uk/cntrl/index.cfm?ObjectID=88722-82872788-09729872</a>
	</p>
	</cfoutput>
</div>
</body>
</html>