<!--- 
	Filename: 	 /cfc/cntrl/products.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Methods for product related control panel events
	Date: 		 15/09/2006
	Revisions:
--->

<cfcomponent output="false" name="event" displayname="event" hint="Methods for control panel events">

<!--- / Object declarations / --->
<cfscript>
VARIABLES.cntrl_do 	= createObject("component", "cfc.cntrl.do"); 
</cfscript>

<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript> 
return this;
</cfscript>
</cffunction> 

<!--- *** PRODUCT LIST *** --->
<cffunction name="productList" access="public" returnType="any" output="false">
<cfargument name="evValue" type="string" required="true" />





</cffunction>

<!--- *** DUPLICATE OF CATEGORY LIST, SHORTER NAME TO MATCH TAB *** --->
<cffunction name="categories" access="public" returnType="any" output="false">
<cfscript>
var Str="";

if (not StructKeyExists(URL, "action")) {
url.action = "";	
}

switch (url.action) {
case "list":    		request.breadcrumb="Default";		
						;
						break;
case "enable":			VARIABLES.cntrl_do.setCategoryDisabled(url.CategoryID, 0);
						URL.tblDestroy=1;
						return getViewCategoryList();
						;
						break;
case "disable":			VARIABLES.cntrl_do.setCategoryDisabled(url.CategoryID, 1);
						URL.tblDestroy=1;
						return getViewCategoryList();
						;
						break;								
default: 				return getViewCategoryList();
						;
}
</cfscript>
</cffunction>


<!--- *** CATEGORY LIST *** --->
<cffunction name="categoryList" access="public" returnType="any" output="false">


<cfscript>
var Str="";

if (not StructKeyExists(URL, "action")) {
url.action = "";	
}

switch (url.action) {
case "list":    		request.breadcrumb="Default";		
						;
						break;
case "enable":			VARIABLES.cntrl_do.setCategoryDisabled(url.CategoryID, 0);
						URL.tblDestroy=1;
						return getViewCategoryList();
						;
						break;
case "disable":			VARIABLES.cntrl_do.setCategoryDisabled(url.CategoryID, 1);
						URL.tblDestroy=1;
						return getViewCategoryList();
						;
						break;								
default: 				return getViewCategoryList();
						;
}
</cfscript>

</cffunction>

<cffunction name="getViewCategoryList" access="private" returntype="string">
<cfscript>
if (isdefined("url.tbldestroy")) {
							if (isdefined("session.xwtable.categories"))
							StructDelete(SESSION.xwtable, "categories");
						}
						
						// create the table for Categories
	 					request.xwtable=createObject("component", "cfc.xwtable.xwtable").init("categories");
						
						//is the table already built and stored in the session scope?
			 			if (request.xwtable.getValue("categories","status") neq "loaded") {
							
							//No, OK, better set one up ... use default design for my table!
			 				request.xwtable.loadDesign("categories","cntrl");
							
							request.xwtable.setValue("categories","width", "1000px");
							request.xwtable.setValue("categories","colwidths", "140px,320px,60px,60px,60px,60px"); 
							request.xwtable.setValue("categories","alignment", "left,left,left,left,left,left"); 
							
							//override the default url
							request.xwtable.setValue("categories","URL", "index.cfm");
							
							//disable the filter 
							request.xwtable.setValue("categories", "enableFilter", "No");
							
							//set the database tablename for which to select against
							request.xwtable.setValue("categories","query.table","tblCategory");
							//name of the query columns to be used in SQL query
							request.xwtable.setValue("categories","querycolumnprimarykey","categoryid");						
			 				//set query columns and binding
			 				request.xwtable.setValue("categories","querycolumnlist","Department, Category, Disabled");
							request.xwtable.setValue("categories","querycolumnbindlist","Department");
			 				
			 				//override columns, no portion cost for ambient
			 				//column list, type and format
							request.xwtable.setValue("categories","columnnamelist","Department, Category (qty), Status, Enable, Disable, Rename");
							request.xwtable.setValue("categories","columnShowHideTitleList", "1,1,1,1,1,1");
							request.xwtable.setValue("categories","columntypelist","query, custom, custom, custom, custom, custom");
							request.xwtable.setValue("categories","columnformatlist","text, text, text, text, text, text");				
							request.xwtable.setValue("categories","customcolumnvaluelist", "catDescAndStockCount(categoryid;category), categoryStatus(Disabled), <a title='enable' href='index.cfm?moduleid=#url.moduleid#&amp;tabid=#url.tabid#&amp;value=categorylist&amp;action=enable&amp;categoryid=:categoryid'><img src='#session.shop.skin.path#button_enable.gif' alt='enable' /></a>, <a title='disable' href='index.cfm?moduleid=#url.moduleid#&amp;tabid=#url.tabid#&amp;value=categorylist&amp;action=disable&amp;categoryid=:categoryid'><img src='#session.shop.skin.path#button_disable.gif' alt='disable' /></a>, <a href='#cgi.script_name#?ev=products&amp;value=categorylist&amp;action=rename'>Rename</a>");
							request.xwtable.setValue("categories","customcolumntypelist",  "function, function, URI, URI, URI");
							
			 			}
						
			 			//set the whereStatement to the value returned by the whereClause handler 			
			 			//request.xwtable.setValue("categories","wherestatement", "");
	 					
	 					//finally add the xwtable objects css file to the shops
						if (request.css neq "")  {
							request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-cntrl.css"));
						} else {
							request.css = 	session.shop.skin.path & "xwtable-cntrl.css";
						}
	 						
	 					//return the markup for the table
	 					return request.xwtable.getTable("categories");
</cfscript>
</cffunction>


</cfcomponent>