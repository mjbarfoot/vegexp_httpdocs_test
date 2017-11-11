<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />
<cfparam name="request.AccountUpdated" default=false />

<cfscript>
// get the security control centre object
request.seccontrol = createObject("component", "cfc.security.control");

//form handler
if (isdefined("form.frmMyAccSubmit")) {
	
	//try to register user
	if (request.secControl.myAccountUpdate(form)) {
	request.AccountUpdated=true;
	}			

} //end if



//make sure customer is logged in before they can access this page
request.seccontrol.forceLogin();

myAccountQry=request.seccontrol.getAccountDetails();


//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Edit my account details");

//add the css file
request.css=request.css & "," & "/css/register.css";
</cfscript>

<cfinclude template="/views/myAccountForm.cfm">
</cfprocessingdirective>