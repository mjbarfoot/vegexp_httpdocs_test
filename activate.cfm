<cfif CGI.QUERY_STRING EQ "">
<cfabort />
<cfelse>
	<cfscript>
	//get the Currently viewing information bar
	shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();
	
	//add the css file
	request.css=request.css & "," & "/css/register.css";
	</cfscript>
	<!--- check if we can decrypt activation link correctly--->
	<cfif APPLICATION.secControl.Activate(CGI.QUERY_STRING)> 
		<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Please choose a password")>
		<cfsavecontent variable="VARIABLES.activationResult">
		<div id="regFormContainer">			
							<cfform id="frmRegister" name="frmRegister" action="register.cfm" method="post" format="html">
							<input type="hidden" name="regtype" id="regtype" value="changePass" />
							<input type="hidden" name="encryptedURL" id="encryptedURL" value="<cfoutput>#CGI.QUERY_STRING#</cfoutput>" />
							<input type="hidden" name="accountcode" id="accountcode" value="<cfoutput>#SESSION.AUTH.ACCOUNTID#</cfoutput>" />
							<span class="fieldsetTitle">Please choose a password below. You will need this each time you login:</span>
								<fieldset>
								<p>
								    <label for="accountcode" class="med">Account Code</label>
								    <cfinput type="text" disabled="true" class="med readonly" name="AccountCode" id="AccountCode" value="#SESSION.Auth.AccountID#" />
								</p>
								<p>    
								    <label for="password" class="med">Choose your password:</label>
								    <cfinput type="password" class="med" name="password" id="password" />
								    <script language="javascript">
								    document.getElementById('password').focus();
								    </script>
								</p>
								</fieldset>
								<p style="text-align: center">
								<label for="frmSubmit">&nbsp;</label><cfinput type="submit" name="frmSubmit" value="Submit" /> 
								</p>
							</cfform>
			</div>
		</cfsavecontent>
	<cfelse>
		<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Sorry your account could not be activated")>
		<cfsavecontent variable="VARIABLES.activationResult">
			<div id="regThanksContainer">	
						<p id="notifySucess">
							Sorry we were unable to activate your account at this time. If you hava clicked the link we emailed you and see this message please call us.
						</p>
						<p id="questions" style="height: 70px;">
							For any questions you may have please contact Vegetarian Express on 01923 249 714 or <a href="mailto:questions@vegexp.co.uk">email us</a> 
						</p>
				</div>
		</cfsavecontent>
	</cfif>
	
	<cfinclude template="/views/regactivate_action.cfm">
	
</cfif>