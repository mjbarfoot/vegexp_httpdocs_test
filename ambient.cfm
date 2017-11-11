<cfprocessingdirective suppresswhitespace="true">
<!--- <cfsilent> --->
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />
<cfparam name="variables.department" default="3">
<cfparam name="url.categoryid" default=0>

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
	 			 	 			 
	 			 //get a list of categories for the AMBIENT Department
	 			 content = APPLICATION.departments.view.getCategoryList("ambient");
	 			 
	 			 //finally add the xwtable objects css file to the shops
				if (request.css neq "")  {
					request.css = listAppend(request.css, (session.shop.skin.path & "department.css"));
				} else {
					request.css = 	session.shop.skin.path & "department.css";
				}
	 			 
	 			 ;
	 			 break;
case "products": 
	 			
	 			// init Session CategoryID var
	 			if (NOT isdefined("SESSION.StockCategoryNumber")) {
	 				SESSION.StockCategoryNumber = URL.CategoryID;
	 			}
	 			
	 			//*** HANDLER: build table *** //
	 			
	 			// create the table for Ambient Products
	 			if (NOT StructKeyExists(SESSION, "xwtable.ambient")) {
	 				APPLICATION.xwtable.create("ambient");
	 			}
	 			
	 			//is the table already built and stored in the session scope?
	 			if (APPLICATION.xwtable.getValue("ambient","status") neq "loaded") {
	 				
	 				//No, OK, better set one up ... use default design for my table!
	 				APPLICATION.xwtable.loadDesign("ambient","default");
	 				 				
	 				//set query columns and binding
	 				APPLICATION.xwtable.setValue("ambient","querycolumnlist","StockID, Description, UnitofSale, SalePrice, OutOfStock, StockQuantity, IsFavourite");
					APPLICATION.xwtable.setValue("ambient","querycolumnbindlist","UnitofSale");
	 				
	 				//set sortable columns
	 				APPLICATION.xwtable.setValue("ambient","columnSortable","Description,UnitofSale,SalePrice,false,false,false");
	 				
	 				//override columns, no portion cost for ambient
	 				//column list, type and format
					APPLICATION.xwtable.setValue("ambient","columnnamelist","Description, Pack Size, Portion Cost, Price, More Information, Add to Basket");
					APPLICATION.xwtable.setValue("ambient","columnShowHideTitleList", "1,1,1,1,1,1");
					APPLICATION.xwtable.setValue("ambient","columntypelist","custom, query, custom, custom, custom, custom");
					APPLICATION.xwtable.setValue("ambient","columnformatlist","text, text, text, text, text, text");				
					APPLICATION.xwtable.setValue("ambient","customcolumnvaluelist", "convertCodesToIcons(Description;StockID;StockQuantity;isFavourite), getPortionSize(UnitOfSale;SalePrice), getDiscountedPrice(SalePrice), prodInfoLinks(StockID), Add2BasketLinks(StockID;StockQuantity)");
					APPLICATION.xwtable.setValue("ambient","customcolumntypelist",  "function, function, function, function, function");

	 				//Now set our where clause. Ambient products only so set deparment to 1
	 				//APPLICATION.xwtable.setValue("ambient","wherestatement", "department=#variables.department#");	
	 							
					//run the query and tell xwtable it's an external query
				 	APPLICATION.xwtable.setQuery("ambient", "sqlquery", application.productsDO.get(AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceBand=SESSION.Auth.PriceBand,DepartmentID=3,CategoryID=SESSION.StockCategoryNumber,ingredientClassColumn=SESSION.shopper.prod_filter));
				 	APPLICATION.xwtable.setValue("ambient", "sqlquery_setexternal", "true");	
				 	// set the table as the query name from query of query functionality
				 	//APPLICATION.xwtable.setValue("ambient", "query.table", "q");
	 						
	 			}
	 			
	 			
	 			//*** HANDLER: CategoryID *** //
	 			// has changed?
	 			if (URL.CategoryID NEQ SESSION.StockCategoryNumber OR SESSION.shopper.prod_filter_updated) {
	 				 	SESSION.StockCategoryNumber = URL.CategoryID;	 				 	
	 				 	APPLICATION.xwtable.setQuery("ambient", "sqlquery", APPLICATION.productsDO.get(AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceBand=SESSION.Auth.PriceBand,DepartmentID=3,CategoryID=SESSION.StockCategoryNumber,ingredientClassColumn=SESSION.shopper.prod_filter));
	 				 	APPLICATION.xwtable.setValue("ambient", "currentpage", "1");			
	 			}
	 			
	 			
				//*** HANDLER: Retrieve the built table *** //
				
	 			//get my table and put in the local variable "content"
	 			content=APPLICATION.xwtable.getTable("ambient");
	 			
	 			//finally add the xwtable objects css file to the shops
				if (request.css neq "")  {
					request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-products.css"));
				} else {
					request.css = 	session.shop.skin.path & "xwtable-products.css";
				}
	 			
	 			;
	 			break;	 
}


//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail();

</cfscript>


<!--- build the content on to an xml variable --->
<cfsavecontent variable="myContent">
<div id="productListWrapper">
	<div id="productList">
 		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>#shopFilterDisplayBar#</cfoutput> 
		<cfoutput>#content#</cfoutput>
        <span class="shopperTip"><strong>Using Favourites:</strong> Add items using the  <img src='/resources/fav_14.gif' alt='add to Favourites' /> icon. <span style="padding-left: 0.6em;"> Items with this icon <img src='/resources/fav_14_selected.gif' alt='add to Favourites' /> are already added.</span></span>
	</div>
</div>	
</cfsavecontent>
<!--- <cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')> --->
<cfset content=reReplace(myContent, ">[[:space:]]+#chr( 13 )#<", "all")>
<!--- </cfsilent> --->

<cfinclude template="/views/default.cfm">
</cfprocessingdirective>