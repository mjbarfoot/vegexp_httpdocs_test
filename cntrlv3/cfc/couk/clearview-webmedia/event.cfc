<!--- 
	Filename: 	 /cfc/cntrl/event.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Methods for control panel events
	Date: 
	Revisions:
--->

<cfcomponent output="false" name="eventv2" displayname="event" hint="Methods for control panel events">


<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// load module controllers
//home = createObject("component", "cfc.cntrl.home").init();
return this;
</cfscript>
</cffunction> 


<!--- *** ACTION Method *** --->
<cffunction name="action" access="public" returnType="void" output="false">
<cfscript>    
/*******************************************************************************/
/* ------------------/ DESCRIPTION /--------------------------------------- */
/*******************************************************************************/
/* This method is called on every event i.e. each time Application.cfm
Remote calls should call this because they should hit index.cfm 

 - Actions correspond to events on any particular view in the control panel.
 - All actions are fired from links and can be associated with any one of the
request types: page, tab, infobar, widget
 - widget actions are appended to the URL and dealt with by the widget controller. 
 They are simply ignore here. 
 - The last action is recorded and logged. Displayed in the infobar in localhost or debug mode
*/

/*******************************************************************************/
/* ------------------/ INITIALISE ACTION STRUCT/------------------------------ */
/*******************************************************************************/


REQUEST.action = structnew();
REQUEST.action.reqtype = lcase(URL.reqtype);
REQUEST.action.remote = false;
REQUEST.action.moduleid = lcase(URL.moduleid);
REQUEST.action.tabid = lcase(URL.tabid);
REQUEST.action.action = lcase(URL.action);
REQUEST.action.return = "";
REQUEST.action.status= structnew();
REQUEST.action.status.result  = lcase(URL.result);
REQUEST.action.status.message = lcase(URL.message);
REQUEST.action.nodeID = lcase(URL.nodeID);
REQUEST.action.nodeAction = lcase(URL.nodeAction);

/*******************************************************************************/
/* ------------------/ FORWARD ACTION TO APPROPRIATE HANDLER/------------------ */
/*******************************************************************************/

// Parse out widget requests
switch (REQUEST.action.reqtype) {
case "custom": 												  ; // end of custom case				
			 											 break;
default: // call th	e function name which matches the action
		if (REQUEST.action.action neq "") {
			try {
			evaluate("#REQUEST.action.action#()");
			}
			catch (Any Ex) {
			// set the status
			REQUEST.action.status.result = "#REQUEST.action.action# failed";
			
			// *** POTENTIALLY PUT CUSTOM ERROR MESSAGE HANDLER HERE
			//REQUEST.action.status.message
				
				if (APPLICATION.debugmode) {
				rethrow(Ex);	
				}
			}
		}
		; // end of default case	
}

application.applog.write(timeformat(now(), 'h:mm:ss tt') & " ReqType: " & REQUEST.action.ReqType & " Module: " & REQUEST.action.ModuleID &  " Tab: " & REQUEST.action.Tabid & tabid & " Result: " & REQUEST.action.status.result & " Message: " & REQUEST.action.status.message);
</cfscript>
</cffunction> 

<cffunction name="getcustomerdata" access="private" returntype="void" output="false">
<cfscript>
//iterate over form struct removing userid from field names
var AccountID = FORM.fldAccountId;
var r = "";
var soap = "";
var MyXmlDoc="";
var customerData="";
var customerXML="";
REQUEST.action.moduleid = "customers";
REQUEST.action.tabid =    "setup_customer";
</cfscript>

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCustomerData xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <accountCode><cfoutput>#XMLFormat(trim(AccountID))#</cfoutput></accountCode>
    </GetCustomerData>
  </soap:Body>
</soap:Envelope>
</cfxml>


<cfscript>
// try retrievin the data from sage
try {
	customerXML = APPLICATION.ob.sageWSGW.postRequest(soap, "GetCustomerData");
	r = true;
} catch (any Ex) {
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Sorry, could not find any details for the Account Code: #FORM.fldAccountId#. <br /><br />Please check you have entered the Account Code correctly then try again.";
	r = false;
}

// parse the returned xml and strip off unwanted elements
try {
		
	MyXmlDoc=xmlParse(customerXML); //parse the data
	CustomerData=MyXmlDoc.xmlRoot.xmlChildren[2].GetCustomerDataResponse.GetCustomerDataResult; //strip off unwanted elements
	REQUEST.action.return = CustomerData;
} catch (any Ex) {
	REQUEST.action.reqtype = "";
	REQUEST.action.moduleid = "error";
	REQUEST.action.tabid =    "dump";
	REQUEST.action.ex = customerXML;
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Sorry, we found the customer details in Sage, but could not read the data. There was an error trying to read the XML.";
	r = false;
}

if (r) {
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="Fetched customer data for #FORM.fldAccountId#";
}

</cfscript>
</cffunction>



<cffunction name="user_save" access="private" returntype="void" output="false">
<cfscript>
//iterate over form struct removing userid from field names
var UserID = URL.UserID;
var r = "";

var FormVars ="";

for (key in FORM) {
	if (FindNoCase(UserID, key)) {
	structInsert(FORM, replaceNoCase(key, "_#UserID#", ""), FORM[key]);
	structDelete(FORM, key);
	}	
}

//save details
r = APPLICATION.ob.security.userSave(FORM);

if (r) {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="User: #URL.UserID# details were saved";
	
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "USER SAVED", 0, "#URL.UserID#");

} else {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Sorry, could not update details for user: #URL.UserID#";
}


</cfscript>
</cffunction>

<cffunction name="user_delete" access="private" returntype="void" output="false">
<cfscript>
//iterate over form struct removing userid from field names
var UserID = URL.UserID;
var r = "";

//save details
r = APPLICATION.ob.security.userDelete(UserID);

if (r) {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="User: #URL.UserID# details were deleted";
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "USER DELETED", 0, "#URL.UserID#");

} else {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Sorry, could not delete for user: #URL.UserID#";
}


</cfscript>
</cffunction>

<cffunction name="user_whitelistip" access="private" returntype="void" output="false">
<cfscript>
//iterate over form struct removing userid from field names
var UserID = URL.UserID;
var r = "";

//save details
r = APPLICATION.ob.security.userWhitelistip(UserID);

if (r) {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="User: #URL.UserID# IP address removed from Blacklist";
	
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "IP WHITELISTED", 0, "#URL.UserID#");

} else {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Sorry, could not IP address from Blacklist for user: #URL.UserID#";
}


</cfscript>
</cffunction>

<cffunction name="user_add" access="private" returntype="void" output="false">
<cfscript>
//iterate over form struct removing userid from field names
var r = "";


//save details
r = APPLICATION.ob.security.userAdd(FORM);

if (r) {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="User: #FORM.UserID# was added successfully";
	
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "USER ADDED", 0, "#FORM.UserID#");

} else {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="User: #FORM.UserID# was not added. Please enter form fields carefully.";
}


</cfscript>
</cffunction>

<cffunction name="user_supplier_save" access="private" returntype="void" output="false">
<cfscript>
//iterate over form struct removing userid from field names
var r = "";


//save details
r = APPLICATION.ob.security.userSupplierSave(FORM);

if (r) {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "supplier_authorisation";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="user_supplier_save() was completed successfully";
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "USER SUPPLIER", 0, "#FORM.sFldUserID# authorised for: #FORM.suppliers#");

} else {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "supplier_authorisation";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="user_supplier_save() failed, please enter form fields carefully.";
}


</cfscript>
</cffunction>

<cffunction name="user_log_filter" access="private" returntype="void" output="false">
<cfscript>
var isSuccessful=true;



if (isSuccessful) {
REQUEST.action.moduleid = "stats";
REQUEST.action.tabid =    "user_log";
REQUEST.action.status.result="successful";
REQUEST.action.status.message="Performed user_log_filter() at #LStimeformat(now(), 'H:MM:SS TT')#";

} else {
	REQUEST.action.moduleid = "stats";
	REQUEST.action.tabid =    "user_log";
	REQUEST.action.status.result="Failed";
	REQUEST.action.status.message="Failed user_log_filter()";
	
}
</cfscript>
</cffunction>

<cffunction name="ipblacklist_delete" access="private" returntype="void" output="false">

<cfscript>
//iterate over form struct removing userid from field names
var ID = URL.id;
var r = "";

//save details
r = APPLICATION.ob.security.blacklistip_delete(ID);

if (r) {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "ip_blacklist";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="IP address removed from Blacklist";
	
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "IP BLACKLIST", 0, "Deleted #ID#");

} else {
	REQUEST.action.moduleid = "admin";
	REQUEST.action.tabid =    "users";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Sorry, could not IP address from Blacklist";
}


</cfscript>


</cffunction>


<!---/*****************************************************
XWTABLE ACTIONS : WIDGET ACTIONS SHOULD NOT BE HERE!
***********************************************************/--->
<cffunction name="xwtableColumnSort" access="private" returntype="void" output="false">
<cfscript>
var myResult = structnew();
var widgetid = lcase(URL.widgetid);
var sortClause = "";

var NewSortCol =lcase(URL.sortcol);
var NewSortOrder = "";
var CurrentSortCol		= lcase(APPLICATION.ob.widgets.xwtable.getValue(widgetid, "sortcol"));
var CurrentSortOrder	= lcase(APPLICATION.ob.widgets.xwtable.getValue(widgetid, "sortorder"));


// check for matching column names and adjust the sort order
if (NewSortCol eq CurrentSortCol) {
	NewSortOrder = IIF(CurrentSortOrder eq "asc", DE("desc"), DE("asc"));
} 

// if the columns don't
else if  (NewSortCol neq CurrentSortCol) {	
		if (NewSortOrder eq "") {
		NewSortOrder = "asc";
		} 
}


// update the XWTABLE vars
APPLICATION.ob.widgets.xwtable.setValue(widgetid, "sortcol", NewSortCol);
APPLICATION.ob.widgets.xwtable.setValue(widgetid, "sortorder", NewSortOrder);

sortClause = "Order by " & NewSortCol & " " & NewSortOrder;

//update the SESSION query object using the where Clause
if (not isdefined("SESSION.qry.#URL.WidgetID#_whereClause")) {
	"SESSION.qry.#widgetid#" = APPLICATION.ob.qs_dao.getWO("", sortClause);
} else {
	"SESSION.qry.#widgetid#" = APPLICATION.ob.qs_dao.getWO(evaluate("SESSION.qry.#URL.WidgetID#_whereClause"), sortClause);
}


if (isQuery(SESSION.qry[widgetid])) {
	"SESSION.qry.#widgetid#_expiry" = DateAdd("n", SESSION.qry.cache_time, now());
	//now set this as the query object in the xwtable object
	APPLICATION.ob.widgets.xwtable.setQuery(widgetid,"sqlquery",SESSION.qry[widgetid]);
	REQUEST.action.moduleid = "home";
	REQUEST.action.tabid =    "#widgetid#";
	REQUEST.action.status.result="successful";
	REQUEST.action.status.message="Performed xwtableColumnSort() at #LStimeformat(now(), 'H:MM:SS TT')#";
	
} else {
	
	REQUEST.action.moduleid = "error";
	REQUEST.action.tabid =    "error";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Function: xwtableColumnSort failed trying to execute query. See the query log";
	
}

</cfscript>
</cffunction>

<cffunction name="setRowsPerPage" access="private" returntype="void" output="false">
<cfscript>
var widgetid = lcase(URL.widgetid);
var newRowsPerPage = lcase(URL.rowsPerPage);

try {
	APPLICATION.ob.widgets.xwtable.setValue(widgetid,"rowsPerPage",newRowsPerPage);
	REQUEST.action.moduleid = "home";
	REQUEST.action.tabid =    "auditqueue";
	REQUEST.action.status.result="successful";
	REQUEST.action.status.message="#LStimeformat(now(), 'H:MM:SS TT')#: setRowsPerPage() Successful";
}
catch (Any Ex) {
	REQUEST.action.reqtype	= "error";
	REQUEST.action.moduleid = "error";
	REQUEST.action.tabid =    "setrowsperpage";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="#LStimeformat(now(), 'H:MM:SS TT')#: setRowsPerPage() Failed trying to update xwtable: #widgetid#";	
}
</cfscript>
</cffunction>


<!--- *** ChangeTab: Sets appropriate keys in the View Struct 
so viewFactory knows which page objects to build --->
<cffunction name="changetab" access="private" returntype="void" output="false">
<cfscript>

</cfscript>
</cffunction>

<cffunction name="rethrow" access="private" returntype="void" output="true">
<cfargument name="Ex" type="any" required="true" />
<cfdump var="#ARGUMENTS.Ex#">
<cfabort />
</cffunction>


<cffunction name="logout" access="private" returntype="void" output="false">
<cfscript>
for (key in SESSION.Auth) {
	structDelete(SESSION.Auth, key);
}
SESSION.qry.selectqueue = APPLICATION.ob.selectQueue.new();
SESSION.Auth = structnew();
SESSION.Auth.isAuthorised=false;
SESSION.Auth.Error = "You have logged out";
SESSION.Auth.LoginCount=0;
SESSION.Auth.isBlocked=false;
APPLICATION.ob.util.location("#APPLICATION.root#/index.cfm?SessionFlush=1");
</cfscript>
</cffunction>

<cffunction name="sendFeedback" access="private" returntype="void" output="false">
<cfset var r = true />

<cfif isdefined("form.frmSubmit")>

<cftry>
<cfoutput>
<cfmail to="matt.barfoot@clearview-webmedia.co.uk" type="text" subject="Feedback" from="feedback@orders.vegetarianexpress.co.uk">
-----------------------------------------------------------------------------
QS AUDIT FEEDBACK FORM v1.0
-----------------------------------------------------------------------------
Feedback submitted from #FORM.Firstname# #FORM.Lastname#
Date: #DateFormat(now(), "dd/mm/yyyy")# Time: #Timeformat(now(),"h:mm tt")#
<cfif isdefined("FORM.fbtype")>Feeback type: #FORM.fbtype#</cfif>
<cfif isdefined("FORM.company")>Company: #FORM.Company# </cfif>
<cfif isdefined("FORM.contactPref")>Contact Preference: #FORM.contactPref# </cfif>
<cfif isdefined("FORM.telnum")>Telephone number: #FORM.telnum# </cfif>
<cfif isdefined("FORM.emailaddress")>Email: #FORM.emailaddress# </cfif>

<cfif isdefined("FORM.message")>Message: #FORM.message# </cfif>
-----------------------------------------------------------------------------
END	
</cfmail>
</cfoutput>
<cfcatch type="any">
	<cfif APPLICATION.debugMode>
	<cfrethrow />
	</cfif>
	<cfset r = false />
</cfcatch>
</cftry>

<cfscript>

if (r) {
	REQUEST.action.moduleid = "home";
	REQUEST.action.tabid =    "feedback";
	REQUEST.action.status.result="success";
	REQUEST.action.status.message="Feedback Form Sent";
	
	//Log Event
	APPLICATION.ob.qs_dao.setUserStat(SESSION.Auth.UserID,  "FEEDBACK SUBMITTED", 0, "Sent by #Form.Firstname# #Form.Lastname#");

} else {
	REQUEST.action.moduleid = "home";
	REQUEST.action.tabid =    "feedback";
	REQUEST.action.status.result="failed";
	REQUEST.action.status.message="Feedback form not emailed...";
}


</cfscript>


</cfif>
</cffunction>


</cfcomponent>