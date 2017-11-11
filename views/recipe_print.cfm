<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#request.pageTitle#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#</cfoutput>layout_print.css" />  
<link rel="stylesheet" type="text/css" media="print" href="<cfoutput>#session.shop.skin.path#</cfoutput>layout_print.css" />  
<link rel="stylesheet" type="text/css" href="<cfoutput>#session.shop.skin.path#</cfoutput>recipes.css" /> 
  <link rel="icon" href="favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
  <script type="text/javascript" src="/js/prototype.lite.js"></script>
  <script type="text/javascript" src="/js/moo.fx.js"></script>
  <script type="text/javascript" src="/js/fat.js"></script>
  <script type="text/javascript" src="/js/taconite-parser.js"></script>
  <script type="text/javascript" src="/js/taconite-client.js"></script>
  <script type="text/javascript" src="/js/vegexp.js"></script>
  <script type="text/javascript" src="<cfoutput>#session.shop.skin.path#</cfoutput>fx.js"></script> 
<cfif isdefined("request.js")><cfloop list="#request.js#" index="jsfile"><script type="text/javascript" src="<cfoutput>#jsfile#</cfoutput>"></script>
  </cfloop></cfif>	
</head>
 <body> 	
	 <div id="wrapper" class="clearfix">
		<div id="head">
				<div id="head_top" class="clearfix">
					<span id="logo_wrapper" class="clearfix">
					<a id="vegexp_logo" href="/index.cfm"><img src="<cfoutput>#session.shop.skin.path#</cfoutput>vegexp_logo.gif" alt="Vegetarian Express" /></a>
					</span>
				</div>
			</div> 
			<div id="body">		
			<cfinclude template="/views/partOrdHotline.cfm" />
					<cfoutput>#content#</cfoutput> 
			<div id="pfoot"></div>	
			</div>
	</div>
 </body>
</html>