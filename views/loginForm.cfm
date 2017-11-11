<!---  HANDLER: Form Action
Allows shoppers to login to any page which requires login
or login at any time of their choosing, but removes any query_string vars
to prevent any url events being repeated
 --->
<cfset formAction=CGI.SCRIPT_NAME>
<cfif formAction eq "/login.cfm">
	<cfset formAction="/index.cfm" />
</cfif>
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
  <script type="text/javascript" src="/js/cfide/cfform.js"></script>
  <script type="text/javascript" src="/js/cfide/masks.js"></script>  
  <script type="text/javascript" src="/js/cfide/cflogin.js"></script>
  <script type="text/javascript" src="<cfoutput>#session.shop.skin.path#</cfoutput>fx.js"></script> 
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
							<div id="loginFormContainer">
							<form name="frmLogin" id="frmLogin" action="<cfoutput>#formAction#</cfoutput>" method="post" onsubmit="return _CF_checkfrmLogin(this)">
							<cfif SESSION.Auth.Firstname neq "" AND Session.Auth.Lastname neq "">
							<span class="fieldsetTitle">
								<cfoutput>Welcome back #SESSION.Auth.Firstname# #Session.Auth.Lastname# from #Session.Auth.Company#. Please confirm you password before continuing:</cfoutput>
							</span>
							<cfelse>
							<span class="fieldsetTitle">Please login before continuing:</span>
							</cfif>
								<fieldset>
								<cfif isdefined("request.login.feedback")>
								<p>
								<cfoutput><span id="loginFeedBack">#request.login.feedback#</span></cfoutput>
								</p>
								</cfif>
								<p style="padding-bottom: 4px;">

								    <label for="userLogin">Account ID:</label>
								    <input type="text" class="small" name="userLogin" id="userLogin" value="<cfoutput>#SESSION.Auth.AccountID#</cfoutput>" />
								</p>
								<p style="padding-bottom: 4px;">
								    <label for="company">Password: </label>
								    <input type="password" class="small" name="userPass" id="userPass"  />
								</p>
								<cfif SESSION.Auth.Firstname neq "" AND Session.Auth.Lastname neq "">
								<p>	
								<cfoutput>If you are not #SESSION.Auth.Firstname# #Session.Auth.Lastname#, please click <a href="/login.cfm?flush=1">here</a></cfoutput>. 
								</p>
								</cfif>							  	
								<p style="text-align:left">
								<label for="accType">&nbsp;</label><input style="width:100px;" type="submit" name="frmSubmit" value="Login" /> 
								</p>
								</fieldset>
								<fieldset style="border-top: none;">
								<p style="padding-top:0;">
                                <strong>Forgotten your password?</strong>  Use <a href="/forgot_pass.cfm">this form</a> to reset your password</a><br/><br/>
                               <strong> Existing Customer, but not setup yet?</strong> Call us on 01923 249714 to add online ordering to your account.<br/><br>
								<strong>New Customer? </strong>If you do not have an account please <a href="/register.cfm">Register</a>. <br /><br />
								<strong>Anything else?</strong> Still having problems then call us on 01923 249714.
								</p>
								</fieldset>	
						    </form>
							</div>
						</div>
					</div>
					<cfinclude template="/views/partOrdHotline.cfm" />
			</div>
			<cfinclude template="/views/partFoot.cfm" />
	</div>
 </body>
</html>