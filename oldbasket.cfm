<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->
<cfparam name="url.action" default="" />

<cfscript>
//form handler
if (isdefined("form.frmSubmit")) {

	//now see what action to do
	switch (form.frmSubmit) {
		case "View Old Basket Contents": 
							// grab the old basket contents
							content = session.basketContents.showOld();
							;
							break;
		case "Keep Old Basket": 
							session.shopper.basket = session.shopper.oldBasket;
    				        structDelete(SESSION.shopper, "oldBasket");
							APPLICATION.shop.util.location("/index.cfm");
							;
							break;
		case "Keep and Edit these items": 
							
							session.shopper.basket = session.shopper.oldBasket;
							structDelete(SESSION.shopper, "oldBasket");
                            APPLICATION.shop.util.location("/basket.cfm");
							;
							break;
		case "Start shopping with new Basket": 
							structDelete(SESSION.SHOPPER, "OldBasket");
							session.shopper.basket.empty();
							APPLICATION.shop.util.location("/index.cfm");
							;
							break;
		default: 					
						// grab the old basket contents
						content = session.basketContents.showOld();
						;
	} //end of switch					

} //end if


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
		<cfif isdefined("form.frmsubmit")>
			<cfoutput>#content#</cfoutput>
		<cfelse>
			<div id="basketContainer">
			<p style="margin-bottom:2em;">
			<span>
			Last time you visited us on #LSDateformat(session.shopper.OldBasket.getDateCreated(), "dd/mm/yyyy")# you left a shopping basket containing <strong>#session.shopper.OldBasket.getItemCount()#</strong> items.<br /><br />
			You can start shopping with a new basket or continue with your old one. 
			</span>
			</p>
			<p style="margin-bottom:2em;">
			<span id="basketActions">
			<form id="myOldBasketItemsForm" method="post" action="#xmlformat(cgi.SCRIPT_NAME)#">
			<input style="width:200px;" type="submit" name="frmSubmit" value="View Old Basket Contents" />
			<input type="submit" name="frmSubmit" value="Keep Old Basket" />
			<input style="width:250px;" type="submit" name="frmSubmit" value="Start shopping with new Basket" />
			</form>
			</span>
			</p>
			</div>
		</cfif>
	</div>
</div>	
</cfoutput>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>
<!--- </cfsilent> --->
<cfinclude template="/views/default.cfm">
</cfprocessingdirective>

