<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Vegetarian Express Control Panel: <cfoutput>#CGI.SERVER_NAME#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#cntrl.css</cfoutput>" />
<cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
</cfloop>
<script type="text/javascript" src="/js/prototype.lite.js"></script>
<script type="text/javascript" src="/js/moo.fx.js"></script>
<script type="text/javascript" src="/js/moo.fx.pack.js"></script>
<script type="text/javascript" src="/js/cntrl.js"></script>
</head>
<body>
<div id="header">
<a id="vegexp_logo" href="/index.cfm">
	<img src="<cfoutput>#session.shop.skin.path#</cfoutput>vegexp_logo_small_greenbg.gif" alt="Vegetarian Express" />
</a>
		<h1>Web Control Panel</h1>
</div>
<div id="container">
<cfinclude template="/views/cntrl/part_nav.cfm" />
</div>		
<div id="main">
<div id="breadcrumb"><cfoutput>#request.breadcrumb#</cfoutput></div>
<div id="content"><cfoutput>#content#</cfoutput></div>
</div>
</body>
</html>
