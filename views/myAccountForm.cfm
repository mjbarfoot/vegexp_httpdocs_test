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
							<cfif request.AccountUpdated>
							<span id="AccountUpdated">Your details have been updated</span>
							</cfif>
							
							<cfform id="frmRegister" name="frmRegister" action="myAccount.cfm" method="post" format="html">
							<cfoutput>
							<span class="fieldsetTitle" style="font-size: 1.4em;">Instructions</span>
							<fieldset>
							<p>1) Only use this form to change your details. <br />2) You can use this form to change contact details, your password and privacy preferences. <br />3) To change any other details i.e. your Address, please call us.
							</p>
							</fieldset>	
							<span class="fieldsetTitle" >Company and Contact Details</span>
								<fieldset style="border-bottom:none">
								 <p>
								    <label for="company">Company name: </label>
								    <span class="myAccountValue">#myAccountQry.company#</span>
								</p>
							    <p>
									<label for="firstName">First name:</label>
								    <cfinput type="text" class="small" name="firstname" id="firstName"  value="#myAccountQry.firstName#" required="true" message="Please enter your first name" />
								    <label for="lastName" class="fldinline">Last name:</label>
								    <cfinput type="text" class="small" name="lastname" id="lastName"    value="#myAccountQry.lastName#" required="true" message="Please enter your last name" />
								</p>
							     <p>
								    <label for="telnum">Telephone number:</label>
								    <cfinput type="text" class="med" name="telnum" id="telnum"  value="#myAccountQry.telnum#" />
								</p>
								<p>
								    <label for="emailAddress">Email Address:</label>
								    <cfinput type="text" class="med" name="emailaddress" id="emailAddress" value="#myAccountQry.emailAddress#"  required="true" validate="regex" pattern="^.+?@.+?\..+$" message="Please enter your email address. We need this to confirm registration, thanks." />
								</p>
								 <p>
							    <p>
									<label for="ContactPref" class="long">Contact Preference: <span>Telephone</span></label>
								    <cfif trim(myAccountQry.contactPref) eq "phone">
								    	<cfinput type="radio" class="radiobtn" name="contactPref" id="contactPref" value="phone" checked="true" />
								    <cfelse>
								    	<cfinput type="radio" class="radiobtn" name="contactPref" id="contactPref" value="phone" />
								    </cfif>
								    <label for="ContactPref" class="fldinline">Email:</label>
								    <cfif trim(myAccountQry.contactPref) eq "email">
								    	<cfinput type="radio" class="radiobtn" name="contactPref" id="contactPref" value="email" checked />
								    <cfelse>
								    	<cfinput type="radio" class="radiobtn" name="contactPref" id="contactPref" value="email" />
								    </cfif>
								</p>
								</fieldset>
							    
							    
								<span class="fieldsetTitle">Password</span>
								<fieldset style="border-bottom:none">
								<p style="padding-top: 1em;padding-bottom: 1em;">
								    <label for="accPassOld" class="long">Current Password (6-12 characters):</label>
								    <cfinput type="password" class="small" name="accPassOld" id="accPassOld" readonly="true" value="#myAccountQry.accPass#" />
								</p>
							    </fieldset>
							    
							    
							    <span class="fieldsetTitle">Change password - Leave blank unless you wish to change your existing password to a new password</span>
							 	<fieldset style="border-bottom:none">
								 <p style="padding-top: 1em;padding-bottom: 1em;">
								    <label for="accPassNew" class="long">New Password (6-12 characters):</label>
								    <cfinput type="password" class="small" name="accPassNew" id="accPassNew"  required="false" validate="regex" pattern="^[A-z\-0-9]{6,12}" message="Please enter a password (only use letter or numbers)\n We recommend using at least one capital letter too." />
								</p>
							  	</fieldset>
							    
							    <span class="fieldsetTitle">Company Address (If this has changed please contact a member of the sales team)</span>
							    <fieldset style="border-bottom:none">
								<p>
								    <label for="building">Office Name/No. : </label>
								    <span class="myAccountValue"><cfif myAccountQry.building neq "">#myAccountQry.building#<cfelse>&nbsp;</cfif></span>
								</p>
								<p>
									<label for="postcode">Postcode: </label>
								   <span class="myAccountValue"><cfif myAccountQry.postcode neq "">#myAccountQry.postcode#<cfelse>&nbsp;</cfif></span> 
							    </p>
							   
							    <p>
								    <label for="line1">Address Line 1:</label>
								   <span class="myAccountValue"><cfif myAccountQry.line1 neq "">#myAccountQry.line1#<cfelse>&nbsp;</cfif></span> 
							    </p>
							    <p>
								    <label for="line2">Address Line 2:</label>
								  <span class="myAccountValue"><cfif myAccountQry.line2 neq "">#myAccountQry.line2#<cfelse>&nbsp;</cfif></span>
							    </p>
							    <p>
								    <label for="line3">Address Line 3:</label>
								   <span class="myAccountValue"><cfif myAccountQry.line3 neq "">#myAccountQry.line3#<cfelse>&nbsp;</cfif></span>
							    </p>
								<p>
								    <label for="town">Town:</label>
						           <span class="myAccountValue"><cfif myAccountQry.Town neq "">#myAccountQry.Town#<cfelse>&nbsp;</cfif></span>
						        </p>
						        <p>
							        <label for="county">County:</label>
								    <span class="myAccountValue"><cfif myAccountQry.County neq "">#myAccountQry.County#<cfelse>&nbsp;</cfif></span>
							    </p>
							    </fieldset>
							    
								
								<span class="fieldsetTitle">Privacy Preferences</span>
								<fieldset>
								<p>
								<label for="PrivEmailPost" class="extralong">Tick the box if you do <strong>not</strong> wish to receive promotional details by email: </label>
								<cfif myAccountQry.AllowEmailPost>
								<cfinput type="checkbox" class="radiobtn" name="PrivEmailPost" id="PrivEmailPost" value="0" />
								<cfelse>
								<cfinput type="checkbox" class="radiobtn" name="PrivEmailPost" id="PrivEmailPost" value="1" checked="true" />
								</cfif>
								</p>
								
								<p>
								<label for="PrivIsCookieOK" class="extralong">Tick the box to accept Cookies: </label>
								<cfif myAccountQry.IsCookieOk eq 1>
								<cfinput type="checkbox" class="radiobtn" name="IsCookieOk" id="IsCookieOk" value="1" checked="true" />
								<cfelse>
								<cfinput type="checkbox" class="radiobtn" name="IsCookieOk" id="IsCookieOk" value="0" checked="false" />
								</cfif>
								</p>
								<label for="PrivIsCookieOK" class="extralong"><span style="color:blue;">Note: No 3rd parties are used. Cookies are only used to help the ordering process</span></label>
								</fieldset>
								
								<p style="text-align: center">
								<label for="accType">&nbsp;</label><cfinput type="submit" name="frmMyAccSubmit" value="Update my Account" /> 
								</p>
							</cfoutput>	
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