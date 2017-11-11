<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#shopperBreadcrumbTrail#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
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
					<div id="nav" class="clearfix">					
						<div id="navTelNumWrap"	class="navbox">
							<div id="navTelNum"   class="navbox">
								<span>01923 249714</span>
							</div>
						</div>
						<div id="navBasketWrap">
							<div id="navBasket">
							<cfif FindNoCase("basket.cfm", cgi.SCRIPT_NAME) eq 0>
								<a href="basket.cfm">Shopping Basket</a>
								<a id="basketEdit" href="basket.cfm"><img src="<cfoutput>#session.shop.skin.path#</cfoutput>nav_basket_edit.gif" alt="View and edit my shopping basket" /></a>
 								<div id="basketExpandWrapper">
									 <cfoutput>#session.basketContents.show()#</cfoutput>
									<div id="baskettotal">
										TOTAL: <span id="grandTotal"><cfoutput>#DecimalFormat(session.shopper.basket.getGrandTotal())#</cfoutput></span>
								 </div>
								</div>
							<cfelse>
							<span class="basketdisabled">Shopping Basket</span>
							</cfif>	
							</div>
						</div>
					</div>
					<cfoutput>#content#</cfoutput>
					<cfinclude template="/views/partOrdHotline.cfm" />
			</div>
		<cfinclude template="/views/partFoot.cfm" />
	</div>
 </body>
</html>