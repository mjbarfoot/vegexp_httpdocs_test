<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->
<cfparam name="url.OfferID" default=0 />

<cfscript>
request.tabSelected="Special";	

//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Special Offers");

// create the departements view object
request.departments.view=createObject("component", "cfc.departments.view");

// if there is a recipeID in the URL get the details
if (url.OfferID) {
offerContent = request.departments.view.getOffer(url.OfferID);
} 
// if not get the recipe list	
	else {
offerContent = request.departments.view.getOfferList();	
}

//add the css file
if (isdefined("request.css")) {
request.css=request.css & "," &  session.shop.skin.path & "offers.css";
} else {
request.css= session.shop.skin.path & "offers.css";
}

request.js = "/js/offer.js"; 


</cfscript>


<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<cfoutput>
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<div id="offerWrap" class="clearfix">
			#offerContent#	
		</div>	
	</div>
</div>	
</cfoutput>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>


<cfinclude template="/views/default.cfm">
</cfprocessingdirective>