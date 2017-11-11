<!--- 
	Filename: 	 /cfc/cntrl/viewFactory.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     creates XML to be consumed by Spry
	Date: 
	Revisions:
--->

<cfcomponent output="false" name="viewFactory" displayname="viewFactory" hint="creates XML/XHTML views for Application">

<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    

return this;
</cfscript>
</cffunction>

<!--- *** generateTabs: XML *** --->
<cffunction name="generateTabs" output="false" returntype="string" access="private">
<cfargument name="moduleid" required="true" type="string" />

<cfsavecontent variable="tabsxml">
<cfoutput>
<cfswitch expression="#lcase(ARGUMENTS.moduleid)#">
<cfcase value="sage">
<tabs>
	<tab>
		<name>Summary</name>
	</tab>
	<tab>
		<name>Settings</name>
	</tab>
	<tab>
		<name>Tests</name>
	</tab>
</tabs>
</cfcase>
<cfcase value="content">
<tabs>
	<tab>
		<name>Categories</name>
	</tab>
	<tab>
		<name>Recipes</name>
	</tab>
	<tab>
		<name>Offers</name>
	</tab>
	<tab>
		<name>Pages</name>
	</tab>
</tabs>
</cfcase>
<cfdefaultcase>
<tabs>
	<tab>
		<name>Welcome</name>
	</tab>
	<tab>
		<name>Help</name>
	</tab>
</tabs>
</cfdefaultcase>
</cfswitch>
</cfoutput>
</cfsavecontent>
<cfreturn tabsxml />
</cffunction>


<!--- *** Get the View *** --->
<cffunction name="get" output="false" returntype="struct" access="public">
<cfscript>
var myView=structnew();

switch (lcase(URL.reqType)) {
case "tab": 	// get the info bar
				myView.info =   getInfo();
				// get the content
				myView.content =  evaluate("#REQUEST.action.moduleid#_#REQUEST.action.tabid#()");
				; 
				break;
case "infobar": myView.info =   getInfo();
				; 
				break;
case "widget":	myView.content = evaluate("APPLICATION.widgets.#URL.widgettype#.get('#URL.widgetID#')");						
				;
				break;	
//default is page
default: 		// get the tabs
				myView.tabs = evaluate("tabs_#REQUEST.action.moduleid#()");
				// get the info bar
				myView.info =   getInfo();
				// get the content
				myView.content =  evaluate("#REQUEST.action.moduleid#_#REQUEST.action.tabid#()");
				; 
}
return myView;
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
<cfxml variable="myTabs">
<ul>
<cfloop from="1" to="#listlen(ARGUMENTS.tabList)#" index="lp">
<cfset listElement = listGetAt(ARGUMENTS.tabList, lp) />
<cfoutput>
	<li><a id="tab#lcase(listElement)#" href="javascript:void(0)" <cfif len(listElement) gt 10> style="width: 120px;"</cfif> class="<cfif lp eq 1>tabselected<cfelse>tabunselected</cfif>" onclick="TabAction.changeTab(this.id);"><span>#ucase(left(listElement, 1))##lcase(mid(listElement,2,len(listElement)-1))#</span></a></li> 
</cfoutput>
</cfloop>
</ul>
</cfxml>
<cfset myTabs=replace(ToString(myTabs), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myTabs) />
</cffunction>

<!--- ******************************************************************************
TAB DEFINITIONS FOR EACH APPLICATION
***********************************************************************************--->

<cffunction name="tabs_home" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "welcome" />
</cfif>	

<cfreturn tabFactory("welcome,help")>

</cffunction>

<cffunction name="tabs_customers" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "list" />
</cfif>	

<cfreturn tabFactory("list,password,favourites")>

</cffunction>


<cffunction name="tabs_products" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "list" />
</cfif>	

<cfreturn tabFactory("list,categories")>

</cffunction>


<cffunction name="tabs_orders" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "list" />
</cfif>	

<cfreturn tabFactory("list,view")>

</cffunction>

<cffunction name="tabs_content" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "list" />
</cfif>	

<cfreturn tabFactory("list,editor,preview")>

</cffunction>

<cffunction name="tabs_health" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "overview" />
</cfif>	

<cfreturn tabFactory("overview,logs,settings")>

</cffunction>

<cffunction name="tabs_sage" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "status" />
</cfif>	

<cfreturn tabFactory("status,disconnect,scheduledjobs")>

</cffunction>

<cffunction name="tabs_payments" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "status" />
</cfif>	

<cfreturn tabFactory("status,list,gateway,settings")>

</cffunction>

<cffunction name="tabs_security" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "users" />
</cfif>	

<cfreturn tabFactory("users,settings")>

</cffunction>

<cffunction name="tabs_settings" output="false" returntype="string" access="private">

<cfif REQUEST.action.tabid eq "">
	<cfset REQUEST.action.tabid = "settings" />
</cfif>	

<cfreturn tabFactory("settings")>

</cffunction>


<!--- ******************************************************************************
CONTENT VIEWS
***********************************************************************************--->

<!---*** HOME ******************************************************************** --->
<cffunction name="home_welcome" output="false" returntype="string" access="public">

<cfoutput>
<cfxml variable="myContent">
<h1>Welcome to the Control Panel</h1>
</cfxml>
</cfoutput>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>

<cffunction name="home_help" output="false" returntype="string" access="public">

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


<!---*** SAGE ******************************************************************** --->
<cffunction name="sage_status" output="false" returntype="string" access="public">

<cfoutput>
<cfxml variable="myContent">
<h1>Sage Status [placeholder]</h1>
</cfxml>
</cfoutput>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>

<cffunction name="sage_disconnect" output="false" returntype="string" access="public">

<cfoutput>
<cfxml variable="myContent">
<h1>Sage Disconnect [placeholder]</h1>
</cfxml>
</cfoutput>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>

<cffunction name="sage_scheduledjobs" output="false" returntype="string" access="public">

<cfoutput>
<cfxml variable="myContent">
<h1>Sage Scheduledjobs [placeholder]</h1>
</cfxml>
</cfoutput>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn toString(myContent) />
</cffunction>

<cffunction name="products_list" output="false" returntype="string" access="public">
<cfscript>
if (isdefined("url.tbldestroy")) {
		if (isdefined("session.xwtable.products"))
		StructDelete(SESSION.xwtable, "products");
}

// create the table for Categories
//APPLICATION.widgets.xwtable.init("products");
//APPLICATION.widgets.xwtable = createObject("component", "cfc.xwtable.xwtable").init();
APPLICATION.widgets.xwtable.init("products");

//is the table already built and stored in the session scope?
if (APPLICATION.widgets.xwtable.getValue("products","status") neq "loaded") {
	//No, OK, better set one up ... use default design for my table!
	APPLICATION.widgets.xwtable.loadDesign("products","cntrl");
	
	//set the class to include xwidget 
	APPLICATION.widgets.xwtable.setValue("products","class", "cntrl xwidget");
	
	APPLICATION.widgets.xwtable.setValue("products","url", "#cgi.script_name#?reqtype=widget&amp;widgettype=xwtable&amp;widgetid=products&amp;nodeid=products");						
	APPLICATION.widgets.xwtable.setValue("products","width", "1000px");
	APPLICATION.widgets.xwtable.setValue("products","colwidths", "125px,345px,80px,80px,80px,100px,90px,90px"); 
	APPLICATION.widgets.xwtable.setValue("products","alignment", "left,left,left,left,left,left,center,center"); 
										
	//set the database tablename for which to select against
	APPLICATION.widgets.xwtable.setValue("products","query.table","tblProducts");
	//name of the query columns to be used in SQL query
	APPLICATION.widgets.xwtable.setValue("products","querycolumnprimarykey","stockid");	
	//set query columns and binding
	APPLICATION.widgets.xwtable.setValue("products","querycolumnlist","Stockcode, Description, UnitofSale, SalePrice, OutOfStock");
	APPLICATION.widgets.xwtable.setValue("products","querycolumnbindlist","Stockcode,Description,UnitofSale,SalePrice,OutOfStock");
	 				
	//override columns, no portion cost for ambient
	//column list, type and format
	APPLICATION.widgets.xwtable.setValue("products","columnnamelist","Stockcode, Description, Pack Size, Price, OutOfStock, More Information, Edit, Enable / Disable");
	APPLICATION.widgets.xwtable.setValue("products","columnShowHideTitleList", "1,1,1,1,1,1,1,1");
	APPLICATION.widgets.xwtable.setValue("products","columntypelist","query, query, query, query, query, custom, custom, custom");
	APPLICATION.widgets.xwtable.setValue("products","columnformatlist","text, text, text, text, text, text, text, text");				
	APPLICATION.widgets.xwtable.setValue("products","customcolumnvaluelist", "prodInfoLinks(StockID), <a title='edit' href='index.cfm?reqtype=widget&amp;widgetid=products&amp;action=product_edit&amp;stockid=:stockid'><img src='#session.shop.skin.path#button_edit.gif' alt='edit' /></a>, <a title='disable' href='index.cfm?reqtype=widget&amp;widgetid=products&amp;action=product_disable&amp;categoryid=:stockid'><img src='#session.shop.skin.path#button_disable.gif' alt='disable' /></a>");
	APPLICATION.widgets.xwtable.setValue("products","customcolumntypelist",  "function, URI, URI");
	
}

//return the markup for the table
return APPLICATION.widgets.xwtable.getTable("products");
</cfscript>
</cffunction>

<cffunction name="products_categories" output="false" returntype="string" access="public">
<cfscript>
if (isdefined("url.tbldestroy")) {
		if (isdefined("session.xwtable.categories"))
		StructDelete(SESSION.xwtable, "categories");
}
						
// create the table for Categories
APPLICATION.widgets.xwtable.init("categories");
						
//is the table already built and stored in the session scope?
if (APPLICATION.widgets.xwtable.getValue("categories","status") neq "loaded") {
							
	//No, OK, better set one up ... use default design for my table!
	APPLICATION.widgets.xwtable.loadDesign("categories","cntrl");
							
	APPLICATION.widgets.xwtable.setValue("categories","width", "1000px");
	APPLICATION.widgets.xwtable.setValue("categories","colwidths", "140px,320px,60px,60px,60px,60px"); 
	APPLICATION.widgets.xwtable.setValue("categories","alignment", "left,left,left,left,left,left"); 
							
	//override the default url
	APPLICATION.widgets.xwtable.setValue("categories","URL", "index.cfm");
							
	//disable the filter 
	APPLICATION.widgets.xwtable.setValue("categories", "enableFilter", "No");
							
	//set the database tablename for which to select against
	APPLICATION.widgets.xwtable.setValue("categories","query.table","tblCategory");
	//name of the query columns to be used in SQL query
	APPLICATION.widgets.xwtable.setValue("categories","querycolumnprimarykey","categoryid");						
	//set query columns and binding
	APPLICATION.widgets.xwtable.setValue("categories","querycolumnlist","Department, Category, Disabled");
	APPLICATION.widgets.xwtable.setValue("categories","querycolumnbindlist","Department");
			 				
	//override columns, no portion cost for ambient
	//column list, type and format
	APPLICATION.widgets.xwtable.setValue("categories","columnnamelist","Department, Category (qty), Status, Enable, Disable, Rename");
	APPLICATION.widgets.xwtable.setValue("categories","columnShowHideTitleList", "1,1,1,1,1,1");
	APPLICATION.widgets.xwtable.setValue("categories","columntypelist","query, custom, custom, custom, custom, custom");
	APPLICATION.widgets.xwtable.setValue("categories","columnformatlist","text, text, text, text, text, text");				
	APPLICATION.widgets.xwtable.setValue("categories","customcolumnvaluelist", "catDescAndStockCount(categoryid;category), categoryStatus(Disabled), <a title='enable' href='index.cfm?moduleid=#url.moduleid#&amp;tabid=#url.tabid#&amp;value=categorylist&amp;action=enable&amp;categoryid=:categoryid'><img src='#session.shop.skin.path#button_enable.gif' alt='enable' /></a>, <a title='disable' href='index.cfm?moduleid=#url.moduleid#&amp;tabid=#url.tabid#&amp;value=categorylist&amp;action=disable&amp;categoryid=:categoryid'><img src='#session.shop.skin.path#button_disable.gif' alt='disable' /></a>, <a href='#cgi.script_name#?ev=products&amp;value=categorylist&amp;action=rename'>Rename</a>");
	APPLICATION.widgets.xwtable.setValue("categories","customcolumntypelist",  "function, function, URI, URI, URI");
							
}
						
//set the whereStatement to the value returned by the whereClause handler 			
//APPLICATION.widgets.xwtable.setValue("categories","wherestatement", "");
	 					
//finally add the xwtable objects css file to the shops
if (request.css neq "")  {
	request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-cntrl.css"));
} else {
	request.css = 	session.shop.skin.path & "xwtable-cntrl.css";
}
	 						
//return the markup for the table
return APPLICATION.widgets.xwtable.getTable("categories");
</cfscript>

</cffunction>

</cfcomponent>