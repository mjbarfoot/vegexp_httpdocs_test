<cfprocessingdirective suppresswhitespace="true">
<cfsilent>
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />
<cfparam name="FORM.qDescription" default="" />
<cfparam name="FORM.qCategory" default="ALL" />
<cfparam name="FORM.qFilter" default="ALL" />
<cfparam name="SESSION.advsearch.querytext" default="" />
<cfparam name="SESSION.advsearch.qCategory" default="" />
<cfparam name="SESSION.advsearch.qFilter" default="" />

<cfif url.action is "destroy">
<cfscript>
if (isdefined("session.xwtable.results"))
StructDelete(SESSION.xwtable, "results");
</cfscript>
</cfif>

<cfscript>
//switch back to default skin
session.shopper.prod_filter="All";

//form handler
if (isdefined("form.frmSubmit") OR isdefined("url.tblchangepg") or isdefined("tblSort") or form.qDescription neq "") {
	
	if (NOT isdefined("SESSION.StockCategoryNumber")) {
		SESSION.StockCategoryNumber = 0;
	}
	
	/* 24/05/07 MB: Added parameter session.advsearch.querytext to store the search term used 
	so when moving back and forward in the table result the breadcrumb trail and use this value
	(i.e on line 118) */
	if (form.qDescription neq "" OR (form.qCategory neq session.advsearch.qCategory) OR (form.qFilter neq session.advsearch.qFilter)) {
		session.advsearch.querytext=session.shop.whereClauseHandler.safeUrlParam(form.qDescription);
		session.advsearch.qCategory=form.qCategory;
		session.advsearch.qFilter=form.qFilter;
	} else {
		// 21/07/08 Added so adv search results still show highlighting when paging
		// xwcustom_function need refactoring so it isn't looking for form parameters
		if (session.advsearch.querytext neq "") {
			form.qDescription = session.advsearch.querytext;
		}
	}
	
	// create the table for Ambient results
	if (NOT StructKeyExists(SESSION, "xwtable.results")) {
	 		APPLICATION.xwtable.create("results");
	 }
	 			
	//is the table already built and stored in the session scope?
	if (APPLICATION.xwtable.getValue("results","status") neq "loaded") {	
		//No, OK, better set one up ... use default design for my table!
		APPLICATION.xwtable.loadDesign("results","default");
		
							//run the query and tell xwtable it's an external query
		APPLICATION.xwtable.setQuery("results", "sqlquery", application.productsDO.get(AllowedList=SESSION.Auth.AllowedList, AllowedListType=SESSION.AUTH.AllowedListType,priceband=SESSION.Auth.PriceBand,departmentid=0,categoryid=SESSION.StockCategoryNumber));
		APPLICATION.xwtable.setValue("results", "sqlquery_setexternal", "true");		
	}

	//***********************START: FORM SUBMISSION HANDLER ***********************//
	// if the form has been submitted change the where clause and set the page back to 1
	if (isdefined("form.frmSubmit") or form.qDescription neq "") {
	
		// set the page number of the results table to 1
		APPLICATION.xwtable.setValue("results", "currentPage", "1");
		
		//***********************START: ADVANCED SEARCH: WHERE CLAUSE HANDLER ***********************//
		
		// ************************* Category: (Stock Category Number)  ******************************//
	 	if (form.qCategory neq "All") {
	 		SESSION.StockCategoryNumber = form.qCategory;
	 		APPLICATION.xwtable.setQuery("results", "sqlquery", application.productsDO.get(AllowedList=SESSION.Auth.AllowedList, AllowedListType=SESSION.AUTH.AllowedListType,priceband=SESSION.Auth.PriceBand,departmentid=0,categoryid=SESSION.StockCategoryNumber));
	 		APPLICATION.xwtable.setValue("results", "currentpage", "1");			
	 	}
	 	
	 	 		
		// ************************* Description: (using LIKE) ******************************//
		if (isdefined("form.qDescription") and form.qDescription neq "") {
	 		APPLICATION.xwtable.setQuery("results", "sqlquery", application.productsDO.get(AllowedList=SESSION.Auth.AllowedList, AllowedListType=SESSION.AUTH.AllowedListType,priceband=SESSION.Auth.PriceBand,departmentid=0,categoryid=SESSION.StockCategoryNumber,Description=session.shop.whereClauseHandler.safeUrlParam(form.qDescription)));
	 		APPLICATION.xwtable.setValue("results", "currentpage", "1");			
	 	}
		
		// ************************* qFilter: VEG,ORG OR VEGAN ******************************//
		if (form.qFilter neq "All") {
			APPLICATION.xwtable.setQuery("results", "sqlquery", application.productsDO.get(AllowedList=SESSION.Auth.AllowedList, AllowedListType=SESSION.AUTH.AllowedListType,priceband=SESSION.Auth.PriceBand,departmentid=0,categoryid=SESSION.StockCategoryNumber,Description=session.shop.whereClauseHandler.safeUrlParam(form.qDescription),ingredientClassColumn=FORM.qFilter));
	 		APPLICATION.xwtable.setValue("results", "currentpage", "1");	
		}
		
		/*if (isdefined("form.qDescription") and form.qDescription neq "") {
			if (len(whereClause)) {
				whereClause = whereClause & " AND ";
			}	
			whereClause = whereClause & "description LIKE '%#session.shop.whereClauseHandler.safeUrlParam(form.qDescription)#%'";	
		}*/
		
					
		
		// ************************* Filter: Vegan, Organic, or Gluten Free ******************************//
		if (isdefined("form.qFilter")) {
			switch (form.qFilter) {
					case "Organic": session.shopper.prod_filter="Organic";
								    session.shop.skin.path = session.skins.organic.path;
								    session.shop.skin.css = session.skins.common.css & "," & session.skins.organic.css;	
								    ;
								    break;	
					case "Vegan": 	session.shopper.prod_filter="Vegan";
								    ;
								    break;	
					case "GlutenFree": 	
								    session.shopper.prod_filter="GlutenFree"; 
								    ;
								    break;	
					default:    	session.shopper.prod_filter="All";
						   			session.shop.skin.path = session.skins.default.path;
						   			session.shop.skin.css = session.skins.common.css & "," & session.skins.default.css;		
						   			;
			}	
			
			//reset the basket.css
			request.css=session.shop.skin.path & "basket.css";
			
			
		}
		
		
		
		
		
		//***********************END: ADVANCED SEARCH: WHERE CLAUSE HANDLER ***********************//
	
	}// **********************END: FORM SUBMISSION HANDLER *****************************************//	
	
	
	
	//get the APPLICATION results
	content=APPLICATION.xwtable.getTable("results");

	//finally add the xwtable objects css file to the shops
	if (request.css neq "")  {
		request.css = listAppend(request.css, (session.shop.skin.path & "xwtable-products.css"));
	} else {
	request.css = 	session.shop.skin.path & "xwtable-products.css";
	}
	
	

	
	//get the breadcrumb trail
	//*********************************************************************
	// are we changing page
		if (isdefined("url.tblchangepg") AND url.tblchangepg neq APPLICATION.xwtable.getValue("results", "currentpage")) {
			shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail('Page #SESSION.xwtable.results.getVar("currentPage")# from #session.xwtable.results.getVar("sqlquery.recordcount")# Results for <span style="color: Blue">"#session.advsearch.querytext#"</span>, category: <span style="color: Blue">"#session.advsearch.qCategory#"</span>, filter: <span style="color: Blue">"#session.advsearch.qFilter#"</span>' & " <a class='linkNewSearch' href='advanced_search.cfm'>Start a new Search</a>");				
	} // no this is first page of results
	   else {
		shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail('Found #session.xwtable.results.getVar("sqlquery.recordcount")# Results for #IIF(form.qDescription neq "",DE('<span style="color: Blue">"#form.qDescription#"</span>,'),DE(''))# category: <span style="color: Blue">"#form.qCategory#"</span>, filter: <span style="color: Blue">"#form.qFilter#"</span>' & " <a class='linkNewSearch' href='advanced_search.cfm'>Start a new Search</a>");		 			
	}
	

} 
	// form not submittied, display the advanced search form
	else {
		//get the breadcrumb trail
		shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Advanced Search");	
		
			
		//get the search results
		content=APPLICATION.departments.view.getAdvancedSearchForm();

		//finally add the xwtable objects css file to the shops
		if (request.css neq "")  {
			request.css = listAppend(request.css, (session.shop.skin.path & "advsearch.css"));
		} else {
			request.css = 	session.shop.skin.path & "advsearch.css";
		}
		
} 


</cfscript>

<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>#content#</cfoutput>	
	</div>
</div>	
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>
</cfsilent>

<cfinclude template="/views/default.cfm">
</cfprocessingdirective>