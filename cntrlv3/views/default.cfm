<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title><cfoutput>#request.view.title#</cfoutput></title>
<meta http-equiv="expires" content="0" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Content-Language" content="en" />
<meta name="description" content="Clearview Webmedia Web Application Control Panel" />
<meta name="copyright" content="Copyright Clearview Webmedia <cfoutput>#dateformat(now(), "yyyy")#</cfoutput>" />
<cfloop list="#request.view.css#" index="c"><link rel="stylesheet" type="text/css" href="<cfoutput>#c#</cfoutput>" />
</cfloop><cfloop list="#request.view.js#" index="j"><script type="text/javascript" src="<cfoutput>#j#</cfoutput>" ></script>
</cfloop>
</head>	
<body>
<cfif APPLICATION.debugMode><script language="javascript">debugMode=true;</script>
<div id="debugDIV">
<cfoutput>
	<table style="width: 300px;">
	<thead />
	<tbody>
	<tr><td width="100px">Moduleid: </td><td>#SESSION.debuginfo.moduleid#</td></tr>	
	<tr><td>Tabid: </td><td>#SESSION.debuginfo.tabid#</td></tr>
	<tr><td>Result: </td><td>#SESSION.debuginfo.status.result#</td></tr>
	<tr><td>Message: </td><td>#SESSION.debuginfo.status.message#</td></tr>
	<tr><td>Last GET: </td><td width="200px"><textarea id="DebugAjaxLastGetInfo" style="width: 200px;">#xmlformat(SESSION.debuginfo.lastRequest)#</textarea></td></tr>
	<tr><td>Ajax GET: </td><td><textarea id="DebugAjaxGetInfo" style="width: 200px;"></textarea></td></tr>
	<tr><td></td><td style="text-align: right"><a href="javascript:void(0)" onclick="document.getElementById('debugDIV').style.display='none';"> [ Hide me ] </a></td></tr>
	<tr><td></td><td style="text-align: right"><a href="?reloadApp=777" >Reload App </a></td></tr>
	</tbody>
	</table>
</cfoutput>
</div></cfif>	
<div id="header">
	<div id="header_top"></div>
	<div id="header_main">
		<a href="##" id="cntrl_logo" title="cntrl logo"><img id="cntrl_logo_img" src="<cfoutput>#REQUEST.view.skinpath#</cfoutput>cntrl_logo.png" alt="XObject Control Panel" /></a>
		<cfoutput>
		<div id="header_nav_top">
		 	<a href="#APPLICATION.root#/index.cfm" title="Go Home">Home</a> | 
			<a href="#APPLICATION.root#/index.cfm?moduleid=home&tabid=feedback&fbtype=report" title="Report Bug">Report Bug</a> | 
			<a href="#APPLICATION.root#/index.cfm?moduleid=home&tabid=feedback&fbtype=feature" title="Feature Request">Request New Feature</a> 
		</div>
		<div id="header_nav_main">
			<a href="#APPLICATION.root#/index.cfm?moduleid=dashboard" title="Dashboard">Dashboard</a> | 
			<a href="#APPLICATION.root#/index.cfm?moduleid=customers" title="Customers">Customers</a> | 
			<a href="#APPLICATION.root#/index.cfm?moduleid=emails" title="Emails">Emails</a> | 
			
			<a href="#APPLICATION.root#/index.cfm?moduleid=cats" title="Categories">Categories</a> |
			<a href="#APPLICATION.root#/index.cfm?moduleid=admin" title="Admin">Admin</a> |
			<a href="#APPLICATION.root#/index.cfm?action=logout" title="Logout">Logout</a> 
<!--- 			<CFIF SESSION.AUTH.SEC_LEVEL GTE 2></CFIF>
			<cfif SESSION.AUTH.SEC_LEVEL EQ 9></CFIF> --->
			
		</div>
		</cfoutput>	
		<a href="##" id="client_logo" title="client_logo"><img id="client_logo" src="<cfoutput>#REQUEST.view.skinpath#</cfoutput>client_logo.png" alt="Client Logo" /></a>
	</div> 
	<div id="header_bot"></div>
</div>
<div id="main">
	<div id="loggedInAs"><cfoutput>Logged in as: #SESSION.AUTH.FIRSTNAME# #SESSION.AUTH.LASTNAME#</cfoutput></div>
	<div id="tabs"><cfoutput>#REQUEST.view.tabs#</cfoutput></div>
	<cfoutput>#REQUEST.view.content#</cfoutput>
</div>
<div id="footer">
<span id="copyr">&copy <cfoutput>#year(now())#</cfoutput> Clearview Webmedia Limited- All Rights Reserved</span>
<span id="legalpriv">
	<a href="/legal.html" title="Terms and Conditions of Use">Legal</a> 
	|
 	<a href="/privacy.html" title="Privacy Policy">Privacy</a>
</span>
</div>

</body>
</html>