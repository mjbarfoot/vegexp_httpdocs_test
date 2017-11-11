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
							<input type="hidden" name="regtype" id="regtype" value="new" />
							<input type="hidden" name="companytype" id="companytype" value="contract" />
							<p style="margin-bottom:1em;">Fields marked * are required</p>
							<span class="fieldsetTitle">Company and Contact Details</span>
								<fieldset>
								<p>
								    <label for="companytype" class="long">Do you work for a: * <span>Contract Caterer</span></label>
								    <cfinput type="radio" class="radiobtn" name="companytype" id="companytype" value="contract" onclick="rF.setCompType('contract')" />
								    <label for="companytype" class="fldinline">Independent Caterer:</label>
								    <cfinput type="radio" class="radiobtn" name="companytype" id="companytype" value="independent" onclick="rF.setCompType('independent')" />
								</p>
								<p>
								    <label for="clientcompany" id="lblCientCompany">Client company: *</label>
								    <cfinput type="text" name="clientcompany" id="clientcompany" required="yes" message="Please enter your company/client company name"  />
								</p>
								<p id="fldContractCompany">
								    <label for="contractcompany">Contract company: *</label>
								    <cfinput type="text" name="contractcompany" id="contractcompany"  />							    
								</p>
							    <p>
									<label for="firstName">First name: *</label>
								    <cfinput type="text" class="small" name="firstname" id="firstName"  required="true" message="Please enter your first name" />
								    <label for="lastName" class="fldinline">Last name: *</label>
								    <cfinput type="text" class="small" name="lastname" id="lastName"  required="true" message="Please enter your last name" />
								</p>
							     <p>
								    <label for="telnum">Telephone number:</label>
								    <cfinput type="text" class="med" name="telnum" id="telnum"  />
								</p>
								<p>
								    <label for="emailAddress">Email Address: *</label>
								    <cfinput type="text" class="med" name="emailaddress" id="emailAddress" required="true" validate="regex" pattern="^.+?@.+?\..+$" message="Please enter your email address. We need this to confirm registration, thanks." />
								</p>
							    <p>
									<label for="ContactPref" class="long">Contact Preference: <span>Telephone</span></label>
								    <cfinput type="radio" class="radiobtn" name="contactPref" id="contactPref" value="phone" />
								    <label for="ContactPref" class="fldinline">Email:</label>
								    <cfinput type="radio" class="radiobtn" name="contactPref" id="contactPref" value="email" />
								</p>
								</fieldset>
							    
							    <span class="fieldsetTitle">Choose a password</span>
							    <fieldset>
								 <p style="padding-top: 1em;padding-bottom: 1em;">
								    <label for="company">Password (6-12 characters): *</label>
								    <cfinput type="password" class="small" name="accPass" id="accPass" required="true" validate="regex" pattern="^[A-z\-0-9]{6,12}" message="Please enter a password (only use letter or numbers)\n We recommend using at least one capital letter too." />
								</p>
							  	</fieldset>
							    
							    <span class="fieldsetTitle">Company Address</span>
							    <fieldset>
								<p>
								    <label for="building">Office Name/No. : *</label>
								    <cfinput type="text" name="building" id="building"  required="true" message="Please enter your the name of your office building or number" />
								</p>
								<p>
									<label for="postcode">Postcode: *</label>
								    <cfinput type="text" class="small" name="postcode" id="postcode"  required="true" validate="regex" pattern="^[A-z\-0-9]{6,7}" message="Please enter your full postcode without any spaces, thanks" />
							    </p>
							   
								<p>
									<label for="building">&nbsp;</label>
									<cfinput type="button" class="btn" name="findAddress" value="Find Address"  onclick="pcaFastAddressBegin()" /> 
							    </p>			   
							    <p>
								    <label for="line2">Address Line 1:</label>
								    <cfinput type="text" class="med" name="line2" id="line2"  />
							    </p>
							    <p>
								    <label for="line3">Address Line 2:</label>
								    <cfinput type="text" class="med" name="line3" id="line3" />
							    </p>
								<p>
								    <label for="town">Town:</label>
						            <cfinput type="text" class="med" name="town" id="town"  />
						        </p>
						        <p>
							        <label for="county">County:</label>
								    <cfinput type="text" class="med" name="county" id="county"  />
							    </p>
							    </fieldset>
							    
							    <span class="fieldsetTitle">Apply for Credit Account</span>
								<fieldset>
								<p>
								<label for="creditAccount" class="long">Would you like to request a credit account: </label> 
								<cfinput type="checkbox" class="btn" name="creditAccount" id="creditAccount" value="1" />
								</p>
								<p>
								<span><strong>Note: </strong>There will be a small delay while our staff set up the account for you (less than 24 hours). 
								You can still order by credit/debit card while you are awaiting confirmation.</span> 
								</p>
								</fieldset>
								
								<span class="fieldsetTitle">Privacy Preferences</span>
								<fieldset>
								<p>
								<label for="PrivEmailPost" class="extralong">Tick the box if you do <strong>not</strong> wish to recieve promotional details by email: </label> 
								<cfinput type="checkbox" class="radiobtn" name="PrivEmailPost" id="accType" value="0" />
								</p>
<!--- 								<p>
								<label for="PrivPhone" class="extralong">Our sales team may call you to discuss your orders and offer guidance. <br />If you do <strong>not</strong> want to receive these calls tick this box (not advised): </label> 
								<cfinput type="checkbox" class="radiobtn" name="PrivPhone" id="accType" value="0" />
								</p> --->
								</fieldset>
								
								<p style="text-align: center">
								<label for="accType">&nbsp;</label>
									<input type="hidden" name="submittype" id="submittype" value="create" />
								<cfinput type="submit" name="frmSubmit" value="submit" /> 
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