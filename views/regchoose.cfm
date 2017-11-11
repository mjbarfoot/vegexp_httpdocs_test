<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#request.pageTitle#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
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
  <script type="text/javascript" src="/js/pca.js"></script>
  <script type="text/javascript" src="/js/formUI.js"></script>
  <script type="text/javascript" src="<cfoutput>#session.shop.skin.path#</cfoutput>fx.js"></script> 
  <script type="text/javascript" src="/js/register.js" />
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
							<!--- <cfoutput>#shopFilterDisplayBar#</cfoutput> --->
							<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
							<div id="regFormContainer">
							<cfform id="frmRegister" name="frmRegister" action="register.cfm" method="post" format="html">
							<span class="fieldsetTitle">Please tell us whether you are a:</span>
								<fieldset>
								<p style="padding: 0.7em 0em">
								    <label for="regtype" class="extralong"><strong>New customer</strong> and wish to place orders online or by phone</label>
								    <cfinput type="radio" class="radiobtn" name="regtype" id="regtype" value="new" />
								</p>
								<p  style="padding: 0.7em 0em">
								    <label for="regtype" class="extralong"><strong>Existing customer</strong> who places orders by phone, but would like to place them via the website</label>
								    <cfinput type="radio" class="radiobtn" name="regtype" id="regtype" value="existing"  />
								</p>    
								</fieldset>									
								<p style="text-align: center">
								<label for="accType">&nbsp;</label>
								<input type="hidden" name="submittype" id="submittype" value="" />
								<cfinput type="submit" name="frmSubmit" value="Submit" /> 
								</p>
							</cfform>
							</div>
						</div>
					</div>
					<cfinclude template="/views/partOrdHotline.cfm" />
			</div>
		<cfinclude template="/views/partFoot.cfm" />
	</div>
 </body>
</html>