<cfprocessingdirective suppresswhitespace="true">
<!--- <cfsilent> --->
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />
<cfparam name="variables.department" default="2">

<!---*** DEVELOPMENT ONLY ***: Destroy and dump action --->
<cfif url.action is "dump">
<cfscript>
session.xwtable.chilled.dump();
</cfscript>
<cfabort />
</cfif>

<cfif url.action is "dumpsession">
<cfdump var="#session#">
</cfif>

<cfif url.action eq "destroy">
<cfscript>
// if there is a products table in the session scope destory it!
	if (isdefined("session.xwtable.chilled"))
	StructDelete(SESSION.xwtable, "chilled");
</cfscript>
<cfabort />
</cfif>


<cfscript>
request.tabSelected="Chilled";

//check bypass
if (isdefined("url.bypass")) {
SESSION.Auth.viewFCBypass=true;	
}


// does the user have access to frozen/chilled products or has chosen to bypass
if (SESSION.Auth.viewFC OR SESSION.Auth.viewFCBypass) {
	
	//are we are in browse mode or results mode?
	switch (request.show) {
	case "categories": 
			 			 //get a list of categories for the AMBIENT Department
		 			 content = APPLICATION.departments.view.getCategoryList("chilled");
		 			 
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
		 			// create the table for Ambient Products
		 					// create the table for Ambient Products
	 				if (NOT StructKeyExists(SESSION, "xwtable.chilled")) {
	 					APPLICATION.xwtable.create("chilled");
	 				}
		 			
		 			//is the table already built and stored in the session scope?
		 			if (APPLICATION.xwtable.getValue("chilled","status") neq "loaded") {
		 				
		 				//No, OK, better set one up ... use default design for my table!
		 				APPLICATION.xwtable.loadDesign("chilled","default");

						//run the query and tell xwtable it's an external query
				 		APPLICATION.xwtable.setQuery("chilled", "sqlquery", APPLICATION.productsDO.get(AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceBand=SESSION.Auth.PriceBand,DepartmentID=2,CategoryID=SESSION.StockCategoryNumber,ingredientClassColumn=SESSION.shopper.prod_filter));
				 		APPLICATION.xwtable.setValue("chilled", "sqlquery_setexternal", "true");		
		 			}
		 			
					//*** HANDLER: CategoryID *** //
	 				// has changed?
	 				if (URL.CategoryID NEQ SESSION.StockCategoryNumber OR SESSION.shopper.prod_filter_updated) {
	 				 	SESSION.StockCategoryNumber = URL.CategoryID;	 				 	
	 				 	APPLICATION.xwtable.setQuery("chilled", "sqlquery", APPLICATION.productsDO.get(AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceBand=SESSION.Auth.PriceBand,DepartmentID=2,CategoryID=SESSION.StockCategoryNumber,ingredientClassColumn=SESSION.shopper.prod_filter));
	 				 	APPLICATION.xwtable.setValue("chilled", "currentpage", "1");			
	 				}
	 			
		 			//get my table and put in the local variable "content"
		 			content=APPLICATION.xwtable.getTable("chilled");
		 			
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

}	
/* shopper not registered yet, has not chosen to bypass postcode, 
or is registered and not eligible to view products */
else {
	
	
	//shopper registered, but not eligible for delivery of frozen/chilled products because of postcode
	if (SESSION.Auth.AccountID NEQ "") {
		content = APPLICATION.departments.view.notAbleToDeliver("chilled");
	
		//get the breadcrumb trail
		shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("These products are not available for delivery to your area");
	
	}
	// shopper not registered yet
	else {
		content = APPLICATION.departments.view.postcodeChkandBypass("chilled");	
	
		//get the breadcrumb trail
		shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("First please check whether we can deliver chilled goods to your area");
	
	}

 	//finally add the departments css file to the shops
	if (request.css neq "")  {
		request.css = listAppend(request.css, "/css/register.css");
	} else {
		request.css = 	"/css/register.css";
	}

	//get the Currently viewing information bar
	shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();
	
}
</cfscript>

<!--- build the content on to an xml variable --->
<cfsavecontent variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfif SESSION.Auth.viewFC OR SESSION.Auth.viewFCBypass>
		<cfoutput>#shopFilterDisplayBar#</cfoutput>
		</cfif>
		<cfoutput>#content#</cfoutput>
        <span class="shopperTip"><strong>Using Favourites:</strong> Add items using the  <img src='/resources/fav_14.gif' alt='add to Favourites' /> icon. <span style="padding-left: 0.6em;"> Items with this icon <img src='/resources/fav_14_selected.gif' alt='add to Favourites' /> are already added.</span></span>
	</div>
</div>	
</cfsavecontent>
<cfset content=reReplace(myContent, ">[[:space:]]+#chr( 13 )#<", "all")>

<cfinclude template="/views/default.cfm">
</cfprocessingdirective>