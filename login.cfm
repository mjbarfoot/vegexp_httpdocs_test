<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />

<cfscript>
//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Login");

//add the css file
if (isdefined("request.css")) {
request.css=request.css & "," & "/css/login.css";
} else {
request.css= "/css/login.css";
}

request.tabSelected="";
</cfscript>


<cfinclude template="/views/loginForm.cfm">
</cfprocessingdirective>