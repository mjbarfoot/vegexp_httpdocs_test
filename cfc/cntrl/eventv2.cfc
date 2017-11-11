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
home = createObject("component", "cfc.cntrl.home").init();
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
REQUEST.action.remote = false;
REQUEST.action.moduleid = lcase(URL.moduleid);
REQUEST.action.tabid = lcase(URL.tabid);
REQUEST.action.action = lcase(URL.action);
REQUEST.action.status= structnew();
REQUEST.action.status.result  = "";
REQUEST.action.status.message = "";
REQUEST.action.nodeID = lcase(URL.nodeID);
REQUEST.action.nodeAction = lcase(URL.nodeAction);

/*******************************************************************************/
/* ------------------/ FORWARD ACTION TO APPROPRIATE HANDLER/------------------ */
/*******************************************************************************/

// Parse out widget requests
if (lcase(URL.reqtype) neq "widget" AND REQUEST.action.action neq "") {
	
	// call the function name which matches the action
	try {
		evaluate("#REQUEST.action.action#()");
	}
	catch (Any Ex) {
		// set the status
		REQUEST.action.status.result = "#REQUEST.action.action# failed";
		
		/// *** POTENTIALLY PUT CUSTOM ERROR MESSAGE HANDLER HERE
		//REQUEST.action.status.message
		
		if (APPLICATION.debugmode) {
		rethrow();	
		}
	}
}


</cfscript>
</cffunction> 


<!--- *** ChangeTab: Sets appropriate keys in the View Struct 
so viewFactory knows which page objects to build --->
<cffunction name="mytestaction" access="private" returntype="void" output="false">
<cfscript>
var myResult = structnew();
REQUEST.action.moduleid = "home";
REQUEST.action.tabid =    "welcome";
REQUEST.action.status.result="successful";
REQUEST.action.status.message="Performed mytestaction() at #LStimeformat(now(), 'H:MM:SS TT')#";
</cfscript>
</cffunction>

<!--- *** ChangeTab: Sets appropriate keys in the View Struct 
so viewFactory knows which page objects to build --->
<cffunction name="changetab" access="private" returntype="void" output="false">
<cfscript>

</cfscript>
</cffunction>

<cffunction name="rethrow" access="private" returntype="void" output="false">
   <cftry>
      <cfcatch>
      <cfrethrow>
      </cfcatch>
   </cftry>
   <cfthrow type="Context validation error" message="Context validation error for CFRETHROW.">
</cffunction>

</cfcomponent>