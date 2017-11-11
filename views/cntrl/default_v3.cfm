<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:spry="http://ns.adobe.com/spry" xml:lang="en" lang="en">
<head>
<title>Vegetarian Express Web Control Panel: <cfoutput>#CGI.SERVER_NAME#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#cntrl_v2.css</cfoutput>" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#xwtable-cntrl.css</cfoutput>" />
<cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
</cfloop>
	<!--- <script type="text/javascript" src="/js/lib/SpryMenuBar.js" ></script> --->
	<script type="text/javascript" src="/js/lib/taconite-client.js" ></script>
	<script type="text/javascript" src="/js/lib/taconite-parser.js" ></script>
	<script type="text/javascript" src="/js/cntrlv2.js"></script>
	<script type="text/javascript" src="/js/xwtable.js"></script>
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
			<li><a id="navitem-products"  title="PRODUCTS"	href="index.cfm?moduleid=products"><span>PRODUCTS</span></a></li>
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
		<cfoutput>#REQUEST.view.tabs#</cfoutput>
	</div>
	<div id="contentWrapper">
		<cfoutput>#REQUEST.view.info#</cfoutput>
		<div id="content"><cfoutput>#REQUEST.view.content#</cfoutput></div>  
	</div>
</div>		
<div id="footer"><p>&copy 2006 Clearview Webmedia Limited - All Rights Reserved</p></div>
</body>
</html>