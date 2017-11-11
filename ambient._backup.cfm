<cfprocessingdirective suppresswhitespace="true">
<!--- <cfsilent> --->
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />
<cfparam name="variables.department" default="3">

<!---*** DEVELOPMENT ONLY ***: Destroy and dump action --->
<cfif url.action is "dump">
<cfscript>
session.xwtable.ambient.dump();
</cfscript>
<cfabort />
</cfif>

<cfif url.action is "dumpsession">
<cfdump var="#session#">
</cfif>

<cfif url.action eq "destroy">
<cfscript>
// if there is a products table in the session scope destory it!
	if (isdefined("session.xwtable.ambient"))
	StructDelete(SESSION.xwtable, "ambient");
</cfscript>
<cfabort />
</cfif>


<cfscript>
request.tabSelected="Ambient";

//are we are in browse mode or results mode?
switch (request.show) {
case "categories": 
	 			 // create the departements view object
	 			 request.departments.view=createObject("component", "cfc.departments.view");
	 			 
	 			 //get a list of categories for the AMBIENT Department
	 			 content = request.departments.view.getCategoryList("ambient");
	 			 
	 			 //finally add the xwtable objects css file to the shops
				if (request.css neq "")  {
					request.css = listAppend(request.css, (session.shop.skin.path & "department.css"));
				} else {
					request.css = 	session.shop.skin.path & "department.css";
				}
	 			 
	 			 ;
	 			 break;
case "products": 
	 			// create the table for Ambient Products
	 			request.xwtable=createObject("component", "cfc.xwtable.xwtable").init("ambient");
	 			
	 			//is the table already built and stored in the session scope?
	 			if (request.xwtable.getValue("ambient","status") neq "loaded") {
	 				
	 				//No, OK, better set one up ... use default design for my table!
	 				request.xwtable.loadDesign("ambient","default");
	 				
	 				//set query columns and binding
	 				request.xwtable.setValue("ambient","querycolumnlist","Description, UnitofSale, SalePrice, OutOfStock");
					request.xwtable.setValue("ambient","querycolumnbindlist","UnitofSale");
	 				
	 				//set sortable columns
	 				request.xwtable.setValue("ambient","columnSortable","Description,UnitofSale,SalePrice,false,false");
	 				
	 				//override columns, no portion cost for ambient
	 				//column list, type and format
					request.xwtable.setValue("ambient","columnnamelist","Description, Pack Size, Price, More Information, Add to Basket");
					request.xwtable.setValue("ambient","columnShowHideTitleList", "1,1,1,1,1");
					request.xwtable.setValue("ambient","columntypelist","custom, query, custom, custom, custom");
					request.xwtable.setValue("ambient","columnformatlist","text, text, text, text, text");				
					request.xwtable.setValue("ambient","customcolumnvaluelist", "convertCodesToIcons(Description;StockID), getDiscountedPrice(SalePrice), prodInfoLinks(StockID), Add2BasketLinks(StockID;OutOfStock)");
					request.xwtable.setValue("ambient","customcolumntypelist",  "function, function, function, function");

	 				//Now set our where clause. Ambient products only so set deparment to 1
	 				//request.xwtable.setValue("ambient","wherestatement", "department=#variables.department#");			
	 			}
	 			
	 			
	 			//set the whereStatement to the value returned by the whereClause handler 			
	 			request.xwtable.setValue("ambient","wherestatement",session.shop.whereClauseHandler.getClause(variables.department));
	 			
	 			//get my table and put in the local variable "content"
	 			content=request.xwtable.getTable("ambient");
	 			
	 			//finally add the xwtable objects css file to the shops
				if (request.css neq "")  {
					request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-products.css"));
				} else {
					request.css = 	session.shop.skin.path & "xwtable-products.css";
				}
	 			
	 			//products case terminator
	 			;
	 			break;	 
}


//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail();

</cfscript>


<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
 		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>#shopFilterDisplayBar#</cfoutput> 
		<cfoutput>#content#</cfoutput>	
	</div>
</div>	
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>
<!--- </cfsilent> --->
<cfinclude template="/views/default.cfm">
</cfprocessingdirective>