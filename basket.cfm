<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />

<cfscript>
//form handler
if (isdefined("form.frmSubmit")) {

	//iterate through the form elements. Update the quantity of each item in the basket
	for (keyName in FORM) {
		//writeOutput("keyname: " & keyName & "<br />");
		if (FindNoCase("fldQty_", keyName)){
			ProductID = ReplaceNoCase(keyName, "fldQty_", "");
			session.shopper.basket.update(ProductID, FORM[KeyName]);	
		}	
	}

	//now see what action to do
	switch (form.frmSubmit) {
		case "Update Basket": 
							// grab the list of all items in the basket, but refresh the list query because we updated it
							content = session.basketContents.showEdit(true);
							;
							break;
		case "Continue Shopping": 		
							APPLICATION.shop.util.location(session.lastRequest);
							;
							break;
		case "Checkout": 
							APPLICATION.shop.util.location("/checkout.cfm");
							;
							break;
		default: 					
						// grab the list of all items in the basket, but refresh the list query because we updated it
						content = session.basketContents.showEdit(true);
						;
	} //end of switch					

} else {
// grab a list of all items in the basket
content = session.basketContents.showEdit();	
}



//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail();


</cfscript>




<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<cfoutput>
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopFilterDisplayBar#</cfoutput>
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>#content#</cfoutput>
	</div>
</div>	
</cfoutput>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>
<!--- </cfsilent> --->
<cfinclude template="/views/default.cfm">
</cfprocessingdirective>