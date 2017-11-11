<cfscript>
if (StructKeyExists(URL, "moduleid") eq 0) {
URL.moduleid="home";
} 

// *** remove unwanted url parameters ***
parsedQS = cgi.query_string;
listOfBadParams="method=,tabid=";


// url.tblchangepg is present, remove url.action
if (findNocase("tblchangepg" ,parsedQS) neq 0) {
		listOfBadParams = listOfBadParams & ",action=,categoryid=";
}

//if url.action is present, remove tblchangepg
if (findNocase("action" ,parsedQS) neq 0) {
		listOfBadParams = listOfBadParams & ",tblchangepg=";
}


//iterate over query string
for (i=1; i LTE listlen(parsedQS, "&"); i=i+1) {
	
	
	// if we find one parameters we want to remove
	for (y=1; y LTE listlen(listOfBadParams, ","); y=y+1) {
		if (FindNoCase(ListGetAt(listOfBadParams, y), ListGetAt(parsedQS, i, "&")) neq 0) {
			parsedQS = replaceNoCase(parsedQS, ListGetAt(parsedQS, i, "&") & "&", "");	
			if (left(parsedQS, 1) eq "&") parsedQS = mid(parsedQS, 2, len(parsedQS)-1);
			}		
	
	}

}

</cfscript>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:spry="http://ns.adobe.com/spry" xml:lang="en" lang="en">
<head>
<title>Vegetarian Express Web Control Panel: <cfoutput>#CGI.SERVER_NAME#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#cntrl_v2.css</cfoutput>" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#xwtable-cntrl.css</cfoutput>" />
<cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
</cfloop>
	<script type="text/javascript" src="/js/lib/xpath.js"></script>
	<script type="text/javascript" src="/js/lib/SpryData.js"></script>
	<script type="text/javascript" src="/js/lib/SpryMenuBar.js" ></script>
	<script type="text/javascript" src="/js/cntrlv2.js"></script>
	<script type="text/javascript">
	<!--
	var Tabs  = new Spry.Data.XMLDataSet("/cfc/cntrl/renderView.cfc?method=getTabs&moduleid=<cfoutput>#URL.moduleid#</cfoutput>", "tabs/tab");
	var tabSelectedName = "";
	var InfoBar =  new Spry.Data.XMLDataSet("/cfc/cntrl/renderView.cfc?method=getInfoBar&moduleid=<cfoutput>#URL.moduleid#</cfoutput>&tabid=" + tabSelectedName + "&elementid=", "content");	 
	var Content = new Spry.Data.XMLDataSet("/cfc/cntrl/renderView.cfc?method=getContent&<cfoutput>#parsedQS#</cfoutput>&tabid=" + tabSelectedName, "content");
	-->
	</script>
</head>	
<body>
<div id="header">
	<a id="vegexp_logo" href="/index.cfm">
		<img src="<cfoutput>#session.shop.skin.path#</cfoutput>vegexp_logo_269x70.gif" alt="Vegetarian Express" />
	</a>
	<div id="toprightnav">
		<a href="index.cfm">Home</a> |
		<a href="##">Report Bug</a> |
		<a href="##">About</a>
	</div>
	<div id="modulenav">
		<ul>
			<li><a id="navitem-customers" title="CUSTOMERS"	href="index.cfm?moduleid=customers"><span>CUSTOMERS</span></a></li>
			<li><a id="navitem-orders" 	  title="ORDERS"	href="index.cfm?moduleid=orders"><span>ORDERS</span></a></li>
			<li><a id="navitem-content"   title="CONTENT"	href="index.cfm?moduleid=content"><span>CONTENT</span></a></li>
			<li><a id="navitem-health"    title="HEALTH"	href="index.cfm?moduleid=health"><span>HEALTH</span></a></li>
			<li><a id="navitem-sage" 	  title="SAGE"		href="index.cfm?moduleid=sage"><span>SAGE</span></a></li>
		</ul>
		<ul id="dropnav">
			  <li><span id="navitem-more" class="dropmenu"><!--- MORE ---></span>
				<ul style="margin-top:0px;padding-top:0px;">
					<li><a id="dropnav-payments" title="payments" href="index.cfm?moduleid=payments"><span>payments</span></a></li>
					<li><a id="dropnav-security" title="payments" href="index.cfm?moduleid=security"><span>security</span></a></li>
					<li><a id="dropnav-settings" title="payments" href="index.cfm?moduleid=settings"><span>settings</span></a></li>
				</ul>
			 </li>
		 </ul>
	</div>	
</div>
<div id="main">
	<div id="tabs">
		<ul spry:region="Tabs" spry:repeatchildren="Tabs">
			<li spry:if="{ds_RowNumber} == 0"><a href="javascript:void(0)" class="tabselected" onclick="TabAction.changeTab('{ds_RowID}');" spry:hover="tabshover" spry:select="tabselected"><span>{name}</span></a></li> 
			<li spry:if="{ds_RowNumber} != 0"><a href="javascript:void(0)" onclick="TabAction.changeTab('{ds_RowID}');" spry:hover="tabshover" spry:select="tabselected"><span>{name}</span></a></li>
		
		</ul>
	</div>

	<div id="contentWrapper">
		<div id="contentInfo" spry:region="InfoBar" spry:repeatchildren="InfoBar"  class="SpryHiddenRegion">{item}</div>
		
		<!--- <div id="content"><cfoutput>#REQUEST.content#</cfoutput></div>  --->
		<div spry:detailregion="Content" id="content">{item}</div>
		<!--- <div spry:if="{ds_RowNumber} != ''">{content}</div> --->
	</div>
</div>		
<div id="footer"><p>&copy 2006 Clearview Webmedia Limited - All Rights Reserved</p></div>
</body>
</html>