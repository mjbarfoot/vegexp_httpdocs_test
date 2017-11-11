<cfprocessingdirective suppresswhitespace="true">

<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />

<!--- Fav Help: display if no favourites exist --->
<cffunction name="getFavHelp" access="public" returntype="string" output="false">
	<!--- build the content on to an xml variable --->
	<cfxml variable="myFavHelp">
	<cfoutput>
	<div id="favWrapper">
	<p>
	<span id="favTitle">How to use the Favourites tab</span>
	</p>
	
	<ul class="favHints">
	<li><span>Favourites List:</span> If you have ordered items from us (by web or phone) in the last six months then these items will be automatically added to your favourites list</li>
	<li><span>When you check out:</span> Your items are automatically added to your favourites. They stay on your favourites list for 6 months from their last order date (or you remove them!)</li>
	<li><span>Adding Favourites to your basket:</span> Add all your favourites list to your shopping basket by using button "Add all to my basket"</li>
	<li><span>When browsing the product list:</span> Add items to your favourites list by clicking <img src="/resources/fav_14.gif" alt="add to Favourites" /></li>
	<li><span>Removing items from Favourites:</span> If you don't want an item on your favourites list click the <img src="/skin/default/icon-remove.gif" alt="remove Favourite" /> to remove it</li>
	</ul>
	<p>
	<span id="favActions">
	<a href="#XMLFormat(session.lastRequest)#">Continue Shopping<img src="#session.shop.skin.path#arrow_right_small.gif" alt="Continue Shopping" /></a>
	</span>
	</p>
	</div>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myFavHelp=replace(toString(myFavHelp), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myFavHelp=reReplace(myFavHelp, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myFavHelp>

</cffunction>


<cffunction name="getFavActions" access="public" returntype="string" output="false">
	<!--- build the content on to an xml variable --->
	<cfxml variable="myFavActions">
	<cfoutput>
	<p id="favButtons">
	<span id="favActions">
	<a style="width: 250px;" href="/favourites.cfm?ev=favourites&amp;action=addbasketall">Add All Favourites to my basket<img src="#session.shop.skin.path#arrow_right_small.gif" alt="Add all to my basket" /></a>
	</span>
	<span id="favActions">
	<a style="width: 150px;" href="#XMLFormat(session.lastRequest)#">Continue Shopping<img src="#session.shop.skin.path#arrow_right_small.gif" alt="Continue Shopping" /></a>
	</span>
	</p>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myFavActions=replace(toString(myFavActions), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myFavActions=reReplace(myFavActions, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myFavActions>

</cffunction>




<cfif url.action eq "reload">
<cfscript>
// if there is a products table in the session scope destory it!
	if (isdefined("session.xwtable.favourites"))
	StructDelete(SESSION.xwtable, "favourites");
</cfscript>
</cfif>

<cfscript>
request.tabSelected="Favourites";

// get the security control centre object
request.seccontrol = createObject("component", "cfc.security.control");

//make sure customer is logged in before they can access this page
request.seccontrol.forceLogin();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Favourites");

// get the Favourites Data Object
request.fav_do=createObject("component", "cfc.shopper.fav_do").init();

// get the Departments Data Object
request.dep_do=createObject("component", "cfc.departments.do");

// *********** URL HANDLER: add/removal of favourites *****************
if (isdefined("url.ev") AND url.ev eq "favourites") {
	
	switch (url.action) {
	//add to favourites using dep_do to retrieve stockcode in place of stockid
	case "add": 	request.fav_do.addFavourite(request.dep_do.getStockCode(url.StockID));
									;
							   		break;									
	// remove from favourites						   
	case "remove":	request.fav_do.removeFavourite(url.FavID);
										;
							 		break;
		// remove from favourites						   
	case "addbasketall": 		//pass all stockids to session.basket function
								session.shopper.basket.ListAdd(request.fav_do.getStockIDs()); 
								
							   /* refresh basketContents component because the component was initialsed 
							   as part of the onRequest method. This code runs after and whilst the total is updated 
							   the basket contents are not displayed unless it is refreshed.
							   
							   Ideally a better method should be used, but with infrequent useage of this feature 
							   using this workaround is fine.
							   */
							   session.basketContents = createObject("component", "cfc.shopper.basketContents").init();
										;
							 		break;
	
	//default case
	default: 				;	
	}

}

if (request.fav_do.doFavouritesExist()) {
		
		
		// create the table for favourites Products
	 	if (NOT StructKeyExists(SESSION, "xwtable.favourites")) {
	 				APPLICATION.xwtable.create("favourites");
	 	}
		
		//is the table already built and stored in the session scope?
	 	if (APPLICATION.xwtable.getValue("favourites","status") neq "loaded") {
	 				
	 		//No, OK, better set one up ... use default design for my table!
	 		APPLICATION.xwtable.loadDesign("favourites","default");
	 		
	 		//run the query and pass it into xwtable
	 		//request.xwtable.setQuery("favourites", "sqlquery", request.fav_do.getFavourites());
	 		
	 		//set the column widths
	 		APPLICATION.xwtable.setValue("favourites","alignment", "left,left,left,left,left,left,left,center"); 
	 		APPLICATION.xwtable.setValue("favourites","colwidths", "397px,60px,60px,70px,70px,50px,60px,50px"); 
	 		
	 		//set query columns and binding
	 		APPLICATION.xwtable.setValue("favourites","querycolumnlist","FavID, StockID, Description, UnitOfSale, SalePrice, OrderCount, StockQuantity, OutOfStock, LastOrderDate, LastOrderQuantity, FavLastModifiedDate");
			APPLICATION.xwtable.setValue("favourites","querycolumnbindlist","UnitOfSale,OrderCount");
	 		APPLICATION.xwtable.setValue("favourites","querycolumnprimarykey","FavID");		
		
			// use xwtable to get a table of favourites
			//column list, type and format
            APPLICATION.xwtable.setValue("favourites","columnnamelist","Description, Pack Size, Portion Cost, Price, More Information, Add to Basket");
            APPLICATION.xwtable.setValue("favourites","columnShowHideTitleList", "1,1,1,1,1,1");
            APPLICATION.xwtable.setValue("favourites","columntypelist","custom, query, custom, custom, custom, custom");
            APPLICATION.xwtable.setValue("favourites","columnformatlist","text, text, text, text, text, text");
            APPLICATION.xwtable.setValue("favourites","customcolumnvaluelist", "convertCodesToIcons(Description;StockID;StockQuantity), getPortionSize(UnitOfSale;SalePrice), getDiscountedPrice(SalePrice), prodInfoLinks(StockID), Add2BasketLinks(StockID;StockQuantity)");
            APPLICATION.xwtable.setValue("favourites","customcolumntypelist",  "function, function, function, function, function");

			//run the query and tell xwtable it's an external queryAPPLICATION.productsDO.get(AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType
		 	APPLICATION.xwtable.setQuery("favourites", "sqlquery", APPLICATION.productsDO.getFavourites(AccountID=SESSION.AUTH.AccountID,AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceBand=SESSION.Auth.PriceBand));
		 	APPLICATION.xwtable.setValue("favourites", "sqlquery_setexternal", "true");	
		 	// set the table as the query name from query of query functionality
		 	APPLICATION.xwtable.setValue("favourites", "query.table", "QryGetFavourites");
	 	} else {
			APPLICATION.xwtable.setQuery("favourites", "sqlquery", APPLICATION.productsDO.getFavourites(AccountID=SESSION.AUTH.AccountID,AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceBand=SESSION.Auth.PriceBand));
		}
	 	
	 	
	 	//if 
	 	
		// get the table
		content=APPLICATION.xwtable.getTable("favourites") & getFavActions();	 		
		
		//finally add the xwtable objects css file to the shops
		if (request.css neq "")  {
				request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-products.css"));
		} else {
				request.css = 	session.shop.skin.path & "xwtable-products.css";
		}
		

} 	else {
	// no favourites? get the favourites help info
	content = getFavHelp();
} 


//add the css files
if (isdefined("request.css")) {
	request.css=request.css & "," & session.shop.skin.path & "favourites.css";
} else {
	request.css=  session.shop.skin.path & "favourites.css";
}

</cfscript>




<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<cfoutput>
<div id="productListWrapper">
	<div id="productList" class="clearfix">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfif StructKeyExists(URL, "showProducts") OR FindNoCase("favourites.cfm", CGI.SCRIPT_NAME) neq 0  OR FindNoCase("search.cfm", CGI.SCRIPT_NAME) neq 0>
		<div id="shopFilterDisplayBar">
		<div id="shopFilterSortBy">
		<cfif isdefined("URL.tblSort")>Sorting by: <strong>#URL.tblSort#<cfif StructKeyExists(URL, "tblSortOrder")>, #URL.tblSortOrder# </cfif></strong> <a style="padding-left: 1em;" id="sortHelp" href="javascript:void(0);" title="Sorting help">Help: <cfelse><a id="sortHelp" href="javascript:void(0);" title="Sorting help">Sorting Help:  </cfif><img src="#session.shop.skin.path#icon_help.png" /></a> 	
		<div class="helpHintWrapper" id="sortHelpWrapper">
		<div class="helpHintcontent" id="sortHelpContent">
			Click a column heading to sort products either ascending or descending.<br />
			<span class="activeColumn">Bold Coloured Headings</span> can be used to sort<br />
			<span class="unactiveColumn">Bold Black Headings</span> mean this column is 'non sortable'<br />
			<br /><br />
			<a id="closeHelp" href="javascript:void(0)">close</a>
		</div>
		</div>
		</div>
		</div>
		</cfif>	
		<cfoutput>#content#</cfoutput>
	</div>
</div>	
</cfoutput>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>

<cfinclude template="/views/default.cfm">
</cfprocessingdirective>