<!--- 
	Filename: 	 /cfc/cntrlv3/renderView.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     
	Date: 
	Revisions:
--->

<cfcomponent output="false" name="viewFactory" displayname="viewFactory" hint="creates XML/XHTML views for Application">

<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    

return THIS;
</cfscript>
</cffunction>

<!--- *** Get the View *** --->
<cffunction name="get" output="false" returntype="struct" access="public">
<cfscript>
VARIABLES.myView=structnew();

switch (REQUEST.ACTION.reqType) {
case "void": 	// do nothing	
				break;
case "tab": 	// get the info bar
				VARIABLES.myView.info =   getInfo();
				// get the content
				VARIABLES.myView.content =  evaluate("#REQUEST.action.moduleid#_#REQUEST.action.tabid#()");
				; 
				break;
case "infobar": VARIABLES.myView.info =   getInfo();
				; 
				break;
case "widget":	VARIABLES.myView.content = evaluate("APPLICATION.ob.widgets.#URL.widgettype#.get('#URL.widgetID#')");						
				;
				break;
				
case "custom":	VARIABLES.myView.TaconitePacket = evaluate("APPLICATION.ob.widgets.#URL.widgetID#.#URL.methodid#('#URL.ElmID#','#URL.paramVal#')");						
				;
				break;

case "error": 	// get the info bar
				VARIABLES.myView.info =   getInfo();
				// get the content
				VARIABLES.myView.content =  evaluate("#REQUEST.action.moduleid#_#REQUEST.action.tabid#()");
				
				REQUEST.ACTION.reqType = "tab";
				; 
				break;

case "debug":	//do nothing
				;
				break;						
//default is page
default: 		//set the title
				VARIABLES.myView.title = "VE Control Panel - #REQUEST.action.moduleid#";
				// set css
				VARIABLES.myView.css = SESSION.view.css & "," & SESSION.view.skins.default.css;
				// set js
				VARIABLES.myView.js = SESSION.view.js & "," & SESSION.view.skins.default.js;
				//path
				VARIABLES.myView.skinpath = SESSION.view.skins.default.path;
				// get the tabs
				VARIABLES.myView.tabs = evaluate("tabs_#REQUEST.action.moduleid#()");
				// get the info bar
				VARIABLES.myView.info =   getInfo();
				// get the content
				VARIABLES.myView.content =  evaluate("#REQUEST.action.moduleid#_#REQUEST.action.tabid#()");
				; 
}
return VARIABLES.myView;
</cfscript>

</cffunction>

<!--- ******************************************************************************
INFOBAR VIEWS
***********************************************************************************--->
<cffunction name="getInfo" output="false" returntype="string" access="public">

<cfoutput>
<cfxml variable="myContent">
<div id="contentInfo">
<span id="breadcrumb"><a title="#REQUEST.action.moduleid#" href="index.cfm?moduleid=#REQUEST.action.moduleid#">#UCASE(REQUEST.action.moduleid)#</a> -> <a href="index.cfm?moduleid=#REQUEST.action.moduleid#&amp;tabid=#REQUEST.action.tabid#">#UCASE(REQUEST.action.tabid)#</a></span>
<div id="actionStatus">
<cfif REQUEST.action.status.result neq ""><span id="Status">Action: #REQUEST.action.status.result#</span></cfif>
<cfif REQUEST.action.status.message neq ""><span id="Message">#REQUEST.action.status.message#</span></cfif>
</div>
</div>
</cfxml>
</cfoutput>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>

<!--- ******************************************************************************
TAB FACTORY
***********************************************************************************--->
<cffunction name="tabFactory" output="false" returntype="string" access="private">
<cfargument name="tabList" type="string" required="true" />

<cfset var listElement=""/>
<cfsetting enablecfoutputonly="true">
<cfxml variable="myTabs">
<cfoutput><ul>
</cfoutput>
<cfloop from="1" to="#listlen(ARGUMENTS.tabList)#" index="lp">
<cfset listElement = listGetAt(ARGUMENTS.tabList, lp) />
<cfoutput>		<li><a id="tab#lcase(replace(listElement, " ", "_", "ALL"))#" href="index.cfm?reqtype=tab&amp;moduleid=#REQUEST.action.moduleid#&amp;tabid=#lcase(replace(listElement, " ", "_", "ALL"))#" <cfif len(listElement) gt 10> style="width: 120px; <cfif lp eq 1> margin-left:0px;</cfif>"</cfif> class="<cfif lp eq 1>tabselected<cfelse>tabunselected</cfif>"><span>#listElement#</span></a></li> 
</cfoutput>
</cfloop>
<cfoutput></ul>
</cfoutput>
</cfxml>

<cfsetting enablecfoutputonly="false">
<cfset myTabs=replace(ToString(myTabs), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myTabs) />

</cffunction>

<!--- ******************************************************************************
TAB DEFINITIONS FOR EACH APPLICATION
***********************************************************************************--->

<cffunction name="tabs_dashboard" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "Default" />
</cfif>	

<cfreturn tabFactory("Default")>

</cffunction>

<cffunction name="tabs_customers" output="true" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "list_customers" />
</cfif>	

<!--- <cfdump var="#REQUEST.action.tabid#">
<cfabort />	 --->

<cfreturn tabFactory("List Customers,Setup Customer,Edit Customer,Reset Password")>
</cffunction>

<cffunction name="tabs_error" output="true" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "error" />
</cfif>	

<cfreturn tabFactory("error")>
</cffunction>


<cffunction name="tabs_admin" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "users" />
</cfif>	

<cfreturn tabFactory("Users,Supplier Authorisation,IP Blacklist")>

</cffunction>


<!--- ******************************************************************************
CONTENT VIEWS
***********************************************************************************--->

<!---*** HOME ******************************************************************** --->
<cffunction name="dashboard_default" output="false" returntype="string" access="public">


<cfscript>

</cfscript>


<cfxml variable="myContent">
<div id="content_wrapper">
	<div id="content">
		<h1>Default Page</h1>
	</div>	
</div>			
</cfxml>


<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset myContent=REreplace(myContent, "[\t\n]", "", "ALL")>
<cfreturn toString(myContent) />
</cffunction>

<!---*** Customers ******************************************************************** --->
<cffunction name="customers_list_customers" output="false" returntype="string" access="public">


<cfscript>

</cfscript>


<cfxml variable="myContent">
<div id="content_wrapper">
	<div id="content">
			<h1 class="actionTitle">List of Web Enabled Customers</h1>
	</div>	
</div>			
</cfxml>


<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset myContent=REreplace(myContent, "[\t\n]", "", "ALL")>
<cfreturn toString(myContent) />
</cffunction>


<cffunction name="customers_setup_customer" output="false" returntype="string" access="public">


<cfscript>
var CustomerData = "";
</cfscript>

<cfif url.action eq "">
	<cfxml variable="myContent">
	<div id="content_wrapper">
		<div id="content">
			<h1 class="actionTitle">Step 1: Enter the Account code for the customer you wish to setup</h1>
			<form class="xwform" id="getCustomerDetails" name="getCustomerDetails" action="<cfoutput>#APPLICATION.root#</cfoutput>/index.cfm?reqtype=tab&amp;moduleid=customers&amp;tabid=setup_customer&amp;action=getCustomerData" method="post">
			<fieldset>
				<label for="fldAccountId">Please enter a Sage Account Code</label>
				<input type="text" id="fldAccountId" name="fldAccountId" />
				<input type="submit" id="frmSubmit" name="frmSubmit" value="Submit" />
			</fieldset>
			</form>
		</div>	
	</div>			
	</cfxml>
<cfelseif url.action eq "getCustomerData" AND REQUEST.action.status.result eq "success">
	<cfscript>
	// DATA CLEANSING
	CustomerData = REQUEST.action.return;
	
	// split contactname string into firstname and lastname
	try {	
		//set firstname and lastname by splitting string at position of space. 
		posSpace = Findnocase(" ", CustomerData.ContactName.xmlText); 
		if (posSpace) {
			firstName = mid(CustomerData.ContactName.xmlText,1,posSpace); 
			lastname  = mid(CustomerData.ContactName.xmlText, (posSpace+1), len(CustomerData.ContactName.xmlText));	
		} else {
			firstname = "";
			lastname  =	CustomerData.ContactName.xmlText;
		}
	} catch (any Ex) {
		REQUEST.action.status.result="failed";
		REQUEST.action.status.message="Sorry, we could not process the contact name data into a firstname and lastname";
		r = false;
	}
	
	</cfscript>
	<cfxml variable="myContent">
	<div id="content_wrapper">
		<div id="content">
			<h1 class="actionTitle">Step 2: Select a delivery schedule and check contact details</h1>
			<form class="xwform" id="getCustomerDetails" name="getCustomerDetails" action="<cfoutput>#APPLICATION.root#</cfoutput>/index.cfm?reqtype=tab&amp;moduleid=customers&amp;tabid=setup_customer&amp;action=saveCustomerData" method="post">
			<cfoutput>
			<fieldset>
				<div class="fieldset_title" style="margin: 0; font-size: 2em;">Account Code: #xmlformat(CustomerData.accountCode.xmlText)#</div>
			</fieldset>	
			<fieldset>
				<div class="fieldset_title">Contact Details</div>
				<p>
				<input type="hidden" readonly="true" id="fldAccount" name="fldAccountCode" value="#xmlformat(CustomerData.accountCode.xmlText)#" />
				<label for="fldAccountId">Account Name:</label>
				<input type="text" readonly="true" id="fldAccountName" name="fldAccountName" value="#xmlformat(CustomerData.AccountName.xmlText)#" />
				<label for="fldFirstname">Firstname:</label>
				<input type="text" readonly="true" id="fldFirstname" name="fldFirstname" value="#xmlformat(firstname)#" />
				<label for="fldLastname">Lastname:</label>
				<input type="text" readonly="true" id="fldLastname" name="fldLastname" value="#xmlformat(lastname)#" />					
				</p>
				<p>
				<label for="AccountAddressLine1">building:</label>
				<input type="text" readonly="true" id="AccountAddressLine1" name="AccountAddressLine1" value="#xmlformat(CustomerData.AccountAddressLine1.xmlText)#" />								
				<label for="AccountAddressPostCode">PostCode:</label>
				<input type="text" readonly="true" id="AccountAddressPostCode" name="AccountAddressPostCode" value="#xmlformat(CustomerData.AccountAddressPostCode.xmlText)#" />								
				</p>
				<p>
				<label for="AccountAddressLine2">Line 1:</label>				
				<input type="text" readonly="true" id="AccountAddressLine2" name="AccountAddressLine2" value="#xmlformat(CustomerData.AccountAddressLine2.xmlText)#" />			
				<label for="AccountAddressLine3">Town:</label>
				<input type="text" readonly="true" id="AccountAddressLine3" name="AccountAddressLine3" value="#xmlformat(CustomerData.AccountAddressLine3.xmlText)#" />		
				<label for="AccountAddressLine4">County:</label>
				<input type="text" readonly="true" id="AccountAddressLine4" name="AccountAddressLine4" value="#xmlformat(CustomerData.AccountAddressLine4.xmlText)#" />		
				</p>
			</fieldset>
			<fieldset>
				<div class="fieldset_title">Delivery Profile</div>
				<p>
				<label for="fldDeliveryProfile">Delivery Profile</label>
				<select name="fldDeliveryProfile" id="fldDeliveryProfile">
					<option value="void" selected="true">---- Please Choose ----</option>
				</select>
				</p>
			</fieldset>
			<fieldset>				
				<div class="fieldset_title">Delivery Address</div>
				<p>
				<label for="fldTradeContact">Trade Contact:</label>
				<input type="text" readonly="true" id="fldTradeContact" name="fldTradeContact" value="#xmlformat(CustomerData.TradeContact.xmlText)#" />
				<label for="fldDelPostcode">Postcode:</label>
				<input type="text" readonly="true" id="fldDeliveryAddressPostCode" name="fldDeliveryAddressPostCode" value="#xmlformat(CustomerData.DeliveryAddressPostCode.xmlText)#" />
				<label for="fldDelAddress">Delivery Address:</label>
				<textarea readonly="true" id="fldDelAddress" name="fldDelAddress" wrap="hard">
				#CustomerData.DeliveryAddressLine1.xmlText#
				#CustomerData.DeliveryAddressLine2.xmlText#
				#CustomerData.DeliveryAddressLine3.xmlText#
				#CustomerData.DeliveryAddressLine4.xmlText#
				</textarea>
				<input type="hidden" readonly="true" id="fldDeliveryAddressLine1" name="fldDeliveryAddressLine1" value="#xmlformat(CustomerData.DeliveryAddressLine1.xmlText)#" />
				<input type="hidden" readonly="true" id="fldDeliveryAddressLine2" name="fldDeliveryAddressLine2" value="#xmlformat(CustomerData.DeliveryAddressLine2.xmlText)#" />
				<input type="hidden" readonly="true" id="fldDeliveryAddressLine3" name="fldDeliveryAddressLine3" value="#xmlformat(CustomerData.DeliveryAddressLine3.xmlText)#" />
				<input type="hidden" readonly="true" id="fldDeliveryAddressLine4" name="fldDeliveryAddressLine4" value="#xmlformat(CustomerData.DeliveryAddressLine4.xmlText)#" />
				</p>
				<p>
				<label for="fldDelContactName">Contact Name:</label>
				<input type="text" readonly="true" id="fldDeliveryContactName" name="fldDeliveryContactName" value="#xmlformat(CustomerData.DeliveryContactName.xmlText)#" />
				<label for="fldDelPhoneNumber">Phone Number:</label>
				<input type="text" readonly="true" id="fldDeliveryTelephoneNumber" name="fldDeliveryTelephoneNumber" value="#xmlformat(CustomerData.DeliveryTelephoneNumber.xmlText)#" />
				<label for="fldDelFaxNumber">Fax Number:</label>
				<input type="text" readonly="true" id="fldDeliveryFaxNumber" name="fldDeliveryFaxNumber" value="#xmlformat(CustomerData.DeliveryFaxNumber.xmlText)#" />
				<label for="fldDelName">Name:</label>
				<input type="text" readonly="true" id="fldDeliveryName" name="fldDeliveryName" value="#xmlformat(CustomerData.DeliveryName.xmlText)#" />
				</p>
			</fieldset>
			<fieldset>
			<div class="fieldset_title">Click Save to Web Enable Customer</div>
			<input type="submit" id="frmSubmit" name="frmSubmit" value="Save" />
			<input type="submit" id="frmReload" name="frmReload" value="Reload from Sage" />
			</fieldset>
			</cfoutput>
			</form>
		</div>	
	</div>			
	</cfxml>
<cfelse>
	<cfxml variable="myContent">
	<div id="content_wrapper">
		<div id="content">
			<cfif isdefined("REQUEST.action.status.message")>
			<h1 class="actionTitle" style="color: red"><cfoutput>#REQUEST.action.status.message#</cfoutput></h1>		
			<cfelse>
			<h1 class="actionTitle">Step 1: Enter the Account code for the customer you wish to setup</h1>
			</cfif>	
			<form class="xwform" id="getCustomerDetails" name="getCustomerDetails" action="<cfoutput>#APPLICATION.root#</cfoutput>/index.cfm?reqtype=tab&amp;moduleid=customers&amp;tabid=setup_customer&amp;action=getCustomerData" method="post">
			<fieldset>
				<label for="fldAccountId">Please enter a Sage Account Code</label>
				<input type="text" id="fldAccountId" name="fldAccountId" />
				<input type="submit" id="frmSubmit" name="frmSubmit" value="Submit" />
			</fieldset>
			</form>
		</div>	
	</div>			
	</cfxml>
</cfif>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset myContent=REreplace(myContent, "[\t\n]", "", "ALL")>
<cfreturn toString(myContent) />
</cffunction>


<!--- ******************************************************************************
ERROR MESSAGES
***********************************************************************************--->
<cffunction name="error_general" output="false" returntype="string" access="public">
<cfset var myDebugInfo ="" />

<cfxml variable="myContent">
<div id="content_wrapper">
<div id="qsa_content">
<div id="error_content">
<h1>Oops! Something went wrong</h1>
<p>Sorry we tried to do what you wanted, but it didn't work out...</p> 
<p>We tried really hard to make this application perfect in every way, but occasionally something happens that we never thought would. </p>
<p>You don't need to do anything. We've already fired the developer and hired a new one. He has already been sent an email with all the information he needs to solve the problem.</p>
<p><strong>We apologise sincerely for this error on our part. Please rest assured we will fix it very quickly.</strong></p>
</div>
</div>
</div>
</cfxml>

<cfif APPLICATION.debugmode AND isdefined("REQUEST.action.ex")>
<cfsavecontent variable="myDebugInfo">
<cfdump var="#REQUEST.action.ex#">
</cfsavecontent>
</cfif>


<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>

<cfset myContent = toString(myContent) />

<cfif APPLICATION.debugmode>
<cfset myContent =  myContent & xmlformat(myDebugInfo) />
</cfif>
<cfreturn toString(myContent) />
</cffunction>


<cffunction name="error_database" output="false" returntype="string" access="public">
<cfxml variable="myContent">
<div id="content_wrapper">
<div id="qsa_content">
<div id="error_content">
<h1>Oops! Something went wrong</h1>
<p>It all went wrong trying to retrieve work orders from the database.</p> 
<p>We tried really hard to make this application perfect in every way, but occasionally something happens that we never thought would. </p>
<p>You don't need to do anything. We've already fired the developer and hired a new one. He has already been sent an email with all the information he needs to solve the problem.</p>
<p><strong>We apologise sincerely for this error on our part. Please rest assured we will fix it very quickly.</strong></p>
</div>
</div>
</div>
</cfxml>
<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>

<cffunction name="error_dump" output="false" returntype="string" access="public">
<cfset var myDebugInfo ="" />

<cfif APPLICATION.debugmode AND isdefined("REQUEST.action.ex")>
<cfsavecontent variable="myDebugInfo">
<cfdump var="#REQUEST.action.ex#">
</cfsavecontent>
</cfif>

<cfreturn myDebugInfo/>
</cffunction>


<!--- ******************************************************************************
HELP
***********************************************************************************--->
<cffunction name="help_home" output="false" returntype="string" access="public">

<cfoutput>
<cfxml variable="myContent">
<div>
<h1>Here is some help</h1>
<a href="#cgi.SCRIPT_NAME#?moduleid=#REQUEST.action.moduleid#&amp;tabid=#REQUEST.action.tabid#&amp;action=mytestaction">Here an action which sends be back to the welcome tab</a>
</div>
</cfxml>
</cfoutput>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>


</cfcomponent>