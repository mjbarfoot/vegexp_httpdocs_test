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
  <script type="text/javascript" src="/js/register.js"></script>
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
							<div id="regFormContainer">			
							
							<cfif isdefined("VARIABLES.registrationBean")>
								<p style="padding: 1em 0em;color: red;"><cfoutput>#VARIABLES.registrationBean.getMessage()#</cfoutput></p>
							</cfif>
							
							<cfform id="frmRegister" name="frmRegister" action="register.cfm" method="post" format="html">
							<input type="hidden" name="regtype" id="regtype" value="existing" />
							<p style="margin-bottom:1em;">For security we need to verify your identify before you can shop online. Please enter your details below.</p>
							<span class="fieldsetTitle">Account Code and Email Address</span>
								<fieldset>
								<p>
								    <label for="accountcode" class="med">Account Code</label>
								    <cfinput type="text" class="med" name="AccountCode" id="AccountCode"  />
								</p>
								<p>    
								    <label for="emailaddress" class="med">Email Address:</label>
								    <cfinput type="text" class="med" name="emailaddress" id="emailaddress" />
								</p>
								</fieldset>
								<p style="text-align: center">
								<label for="frmSubmit">&nbsp;</label>
								<input type="hidden" name="submittype" id="submittype" value="activate" />
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