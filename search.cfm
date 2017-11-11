<cfprocessingdirective suppresswhitespace="true">
<cfsilent>
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />
<cfparam name="URL.pQ" default="" />
<cfparam name="SESSION.searchparams.pq" default="">
<cfparam name="SESSION.searchparams.updated" default=false>
<cfscript>

if (URL.pQ neq "" OR isdefined("url.fldProdFilter") OR isdefined("tblchangepg")) {
	
	
	// create the table for Ambient results
	if (NOT StructKeyExists(SESSION, "xwtable.results")) {
	 		APPLICATION.xwtable.create("results");
	 }
		 			
	//is the table already built and stored in the session scope?
	if (APPLICATION.xwtable.getValue("results","status") neq "loaded") {	
		//No, OK, better set one up ... use default design for my table!
		APPLICATION.xwtable.loadDesign("results","default");
		APPLICATION.xwtable.setValue("results", "allowedParams", "pQ");
	}
	
	
	
	// *** HANDLER FOR CHANGING OF SEARCH PARAMS
	
	// 1st search
	if (SESSION.searchparams.pq eq "") {
		SESSION.searchparams.updated=true;
		SESSION.searchparams.pq=url.pq;
	
	}
	
	// if search field text has changed
	if (url.pq neq SESSION.searchparams.pq) {
		SESSION.searchparams.updated=true;
		SESSION.searchparams.pq=url.pq;
	} 
	
	
	// execute query if search text updated
	if (SESSION.searchparams.updated OR SESSION.shopper.prod_filter_updated) {
		 	APPLICATION.xwtable.setQuery("results", "sqlquery", application.productsDO.get(AllowedListCode=SESSION.Auth.AllowedList,AllowedListType=SESSION.AUTH.AllowedListType,priceband=SESSION.Auth.PriceBand,freeTextSearch=session.searchparams.pQ,ingredientClassColumn=SESSION.shopper.prod_filter));
	 		APPLICATION.xwtable.setValue("results", "currentpage", "1");
	} 
	
	

	
	
	
	
	//get the search results
	content=APPLICATION.xwtable.getTable("results");
	
	//finally add the xwtable objects css file to the shops
	if (request.css neq "")  {
		request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-products.css"));
	} else {
	request.css = 	session.shop.skin.path & "xwtable-products.css";
	}
} 
// empty search string defined
else {

content = '<div style="border:1px solid black; height: 100px; background-color: white; padding: 1em;">Please enter some text in the search field at the top of the screen before clicking search</div>';	
	
}	 //end check for empty search string
//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail();
</cfscript>

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
</cfsilent>
<!---*** DEVELOPMENT ONLY ***: Destroy and dump action --->
<cfif url.action is "dump">
<cfscript>
session.xwtable.results.dump();
</cfscript>
</cfif>

<cfif url.action is "dumpsession">
<cfdump var="#session#">
</cfif>
<cfinclude template="/views/default.cfm">
</cfprocessingdirective>
