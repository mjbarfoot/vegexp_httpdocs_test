<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#request.pageTitle#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <cfloop list="#session.shop.skin.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
  </cfloop> 
  <cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
  </cfloop>
  <link rel="icon" href="favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
  <script type="text/javascript" src="/js/prototype.lite.js"></script>
  <script type="text/javascript" src="/js/moo.fx.js"></script>
  <script type="text/javascript" src="/js/fat.js"></script>
  <script type="text/javascript" src="/js/taconite-parser.js"></script>
  <script type="text/javascript" src="/js/taconite-client.js"></script>
  <script type="text/javascript" src="/js/vegexp.js"></script>
<cfif SESSION.Auth.AccountID neq "" AND SESSION.Auth.IsCookieOK eq "">
  <script type="text/javascript" src="/js/ModalPopups.js"></script>
  <script type="text/javascript" src="/js/ve-modal.js"></script>
</cfif>
  <script type="text/javascript" src="<cfoutput>#session.shop.skin.path#</cfoutput>fx.js"></script> 
<cfif isdefined("request.js")><cfloop list="#request.js#" index="jsfile"><script type="text/javascript" src="<cfoutput>#jsfile#</cfoutput>"></script>
  </cfloop></cfif>	
</head>
 <body> 
<cfif SESSION.Auth.AccountID neq "" AND SESSION.Auth.IsCookieOK eq "">
<script>
ModalPopupsConfirm();
</script>
</cfif>	
	 <div id="wrapper">
		<div id="head">
				<cfinclude template="/views/partHeadTop.cfm" />
				<cfinclude template="/views/partHeadTabs.cfm" />
			</div> 
			<div id="body_topborder"></div>
			<div id="body" class="clearfix">		
					<cfinclude template="/views/partRHSnav.cfm" />
					<cfoutput>#content#</cfoutput>
			<cfinclude template="/views/partOrdHotline.cfm" />
			</div>
	<cfinclude template="/views/partFoot.cfm" />
	</div>
 </body>
</html>