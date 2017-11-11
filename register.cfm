<cfparam name="url.action" default="" />
<cfparam name="FORM.regType" default="" />
<cfparam name="VARIABLES.regComplete" default=false />


<cfsavecontent variable="VARIABLES.regSuccessful">
	<div id="productListWrapper">
		<div id="productList">
			<div id="regThanksContainer">
							<p id="notifySuccess">
								<strong>Your registration was successful.</strong>
							</p>
							<p id="shopperActions">
								You can now <a href="<cfoutput>#xmlformat(session.lastRequest)#</cfoutput>">Continue <img src="<cfoutput>#session.shop.skin.path#</cfoutput>arrow_right_small.gif" alt="Continue Shopping" /></a>					
							</p>
							<p>
								You will receive confirmation of registration by email. 
							</p>
							<p id="questions" style="height: 70px;">
								For any questions you may have please contact Vegetarian Express on 01923 249 714 or <a href="mailto:questions@vegexp.co.uk">email us</a> 
							</p>
			</div>
		</div>
	</div>	
</cfsavecontent>




<cfscript>
//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//add the css file
request.css=request.css & "," & "/css/register.css";
</cfscript>

<cfswitch expression="#FORM.regType#">
<cfcase value="new">
		
		<!---handle form submission--->
		<cfif isdefined("form.frmSubmit") and form.submittype eq "create">
			<cfset VARIABLES.registrationBean = APPLICATION.secControl.registerNewUser(form.accountcode, form.emailaddress)>
		</cfif>
	
		<cfif isdefined("VARIABLES.registrationBean") AND VARIABLES.registrationBean.isComplete()>
			<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Account Registration Complete")>
			<cfoutput>#VARIABLES.regSuccessful#</cfoutput>
		<cfelse>
			<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("New Account Registration")>
			<cfinclude template="/views/reg_newcust_notavailable.cfm" />
		</cfif>
</cfcase>
<cfcase value="existing">
		
		<!---handle form submission--->
		<cfif isdefined("form.frmSubmit") and (form.submittype eq "activate" or form.submittype eq "reset")>
			
			<cfif form.submittype eq "activate">
				<cfset VARIABLES.registrationBean = APPLICATION.secControl.registerExistingUser(form.accountcode, form.emailaddress)>
			<cfelseif form.submittype eq "reset">
				<cfset VARIABLES.registrationBean = APPLICATION.secControl.resetPassword(form.accountcode, form.emailaddress)>
			</cfif>
			
			<cfsavecontent variable="VARIABLES.activationResult">
			<div id="regThanksContainer">	
				<p id="notifySucess">
					We've sent an email to <cfoutput>#FORM.emailAddress#</cfoutput>. <br/><br />Once you have received your email please click the link inside. This will open the website and you can then choose a password which you will need each time you return to our website.
						<br /><br />
						You should normally receive this email in the next few minutes. Sometimes it can take longer, but not more than a few hours.
					</p>
				<p id="questions" style="height: 70px;">
					For any questions you may have please contact Vegetarian Express on 01923 249 714 or <a href="mailto:questions@vegexp.co.uk">email us</a> 
				</p>
			</div>
			</cfsavecontent>	
		</cfif>
		
		<!--- if activation email has been sent --->		
		<cfif isdefined("VARIABLES.registrationBean") AND VARIABLES.registrationBean.isComplete()>
				<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Please check your email inbox")>
				<cfinclude template="/views/regactivate_action.cfm" />
		<cfelse>
		<!--- display the activation form. If accountid and email did not match template automatically shows a message --->
			
			<!--- check first if this is a password reset --->
			<cfif isdefined("form.submittype") AND form.submittype eq "reset">
				<cfinclude template="forgot_pass.cfm">
			
			
			<!---or for existing users show the account existing registration form --->
			<cfelse>
				<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Activate your Account for online use") />
				<cfinclude template="/views/regactivate.cfm" />
			</cfif>
			
		</cfif>
</cfcase>
<cfcase value="changePass">
		
		<!---handle form submission--->
		<cfif isdefined("form.frmSubmit")>
			<cfset VARIABLES.registrationBean = APPLICATION.secControl.changePass(FORM.encryptedURL, FORM.accountcode, FORM.password)>
			<cfif VARIABLES.registrationBean.isComplete()>
				<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Your password has been changed") />
					<cfsavecontent variable="VARIABLES.activationResult">
							<div id="regThanksContainer">	
									<p id="notifySucess">
										Your password has been changed. Please use this password and your Account Code to login in future.
									</p>
									<p style="margin-bottom:4em;">
										Please select a tab or <a href="/index.cfm">click here</a> to go the home page.
									</p>
									<p id="questions" style="height: 70px;">
										For any questions you may have please contact Vegetarian Express on 01923 249 714 or <a href="mailto:questions@vegexp.co.uk">email us</a> 
									</p>
							</div>
					</cfsavecontent>
				
					<cfinclude template="/views/regactivate_action.cfm" />
				
			<cfelse>
				<cfthrow type="vegexp.custom.friendly" detail="Unable to change your password" message="Something went wrong whilst setting your password. You are currently logged in, but won't be able to login again. Please call us so we can fix this problem" />
			</cfif>	
		<cfelse>
			<cfthrow type="vegexp.custom.friendly" detail="Please follow the correct process for changing your password" message="" />
		</cfif>		
</cfcase>
<cfdefaultcase>
<!--- unknown choose type --->
	<cfset shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Are you a new or existing customer?") />
	<cfinclude template="/views/regchoose.cfm" />
</cfdefaultcase>
</cfswitch>