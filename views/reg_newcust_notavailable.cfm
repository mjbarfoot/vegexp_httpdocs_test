<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#request.PageTitle#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <cfloop list="#session.shop.skin.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
  </cfloop> 
  <cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" /></cfloop>
  <link rel="icon" href="favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
  <script type="text/javascript" src="/js/prototype.lite.js"></script>
  <script type="text/javascript" src="/js/moo.fx.js"></script>
  <script type="text/javascript" src="/js/fat.js"></script>
  <script type="text/javascript" src="/js/taconite-parser.js"></script>
  <script type="text/javascript" src="/js/taconite-client.js"></script>
  <script type="text/javascript" src="/js/vegexp.js"></script>
</head>
 <body> 	
	 <div id="wrapper">
			 <div id="head">
				<cfinclude template="/views/partHeadTop.cfm" />
				<cfinclude template="/views/partHeadTabs.cfm" />	
			</div> 
			<div id="body_topborder"></div>
			<div id="body" class="clearfix">		
					<cfinclude template="/views/partRHSnav.cfm" />
					<div id="productListWrapper">
						<div id="productList">
							<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
							<div id="regThanksContainer">
							<p id="notifySuccess">
								At this time we handle all new account registrations by phone. Please call us on 01923 249 714 to setup your account. 
							</p>
							<p id="notifySuccess">
								We apologise if you would prefer to do this online. Some manual checks are required before we can authorise credit. 
							</p>
							</div>
						</div>
					</div>
					<cfinclude template="/views/partOrdHotline.cfm" />
			</div>
		   <cfinclude template="/views/partFoot.cfm" />
	</div>
 </body>
</html>