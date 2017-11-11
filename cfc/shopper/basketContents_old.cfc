<!---
 Filename: /cfc/shopper/basketContents.cfc
 Created by: Matt Barfoot (Clearview Webmedia)
 Purpose: Generates XHTML for the contents of the shopping basket
 Date:  
 History: 
 --------------------------------------------------------------------------------------------
 05/06/2006: Modified handling of remote requests, by setting remote handling on by default.
 Setup some tests in the setupVars method to identify non-remote requests and switch off after
 receiving non-remote url requests to add or expand the shopping basket. 

 Previously remote add/expanding was only switched on after adding something to the basket. 
 If moving between pages and not adding an item then this feature would not work previously!
 -------------------------------------------------------------------------------------------


--->

<cfcomponent output="false" name="basketContents" displayname="basketContents" hint="Generates XHTML for the contents of the shopping basket">

<cffunction name="init" returntype="any" access="public" hint="initiates the component">
<cfscript>
setupVars();
return this;
</cfscript>
</cffunction>

<cffunction name="setupVars" access="private" returntype="void" hint="sets up the component">
<cfscript>
//set Page Defaults
if (NOT isdefined("session.shopper.basket.ExpandMode")) {
session.shopper.basket.ExpandMode=false;
}


//catch url events for adding items to the basket, only used if javascript is disabled or browser is blocking ajax requests
if (isdefined("url.ev") and url.ev eq "basket" and isdefined("url.action") and url.action is "add") {
	//switch ability to add/expand basket by remote request off
	session.shopper.basket.remote=false;
}


//catch url events for expanding/contracting basket, only used if javascript is disabled or browser is blocking ajax requests
if (isdefined("url.ev") and url.ev eq "basket" and isdefined("url.Action") AND url.Action eq "Expand") {
	//switch ability to add/expand basket by remote request off
	session.shopper.basket.remote=false;	
}



// ************** BASKET EXPAND AND CONTRACT HANDLER **********************
if (isdefined("url.Action") AND url.Action eq "Expand") {
session.shopper.basket.ExpandMode=true;
VARIABLES.ExpandMode=true;	
} else if (isdefined("url.Action") AND url.Action eq "Contract") {
session.shopper.basket.ExpandMode=false;	
}




// ************** SHARED/VARIABLE SCOPE  CFC DEFAULTS *******************
VARIABLES.ExpandMode=session.shopper.basket.ExpandMode;

VARIABLES.startrow = 1;
VARIABLES.showExpandLink=false;

//get the shopping basket contents query
VARIABLES.myBasket = session.shopper.basket.list();		 

// if there are more than 5 items only show the last 5 unless Expand is true
if (VARIABLES.myBasket.recordcount gt 5 AND VARIABLES.ExpandMode eq False) {
VARIABLES.startrow = VARIABLES.myBasket.recordcount-4;
VARIABLES.showExpandLink=true;
}

VARIABLES.xwcustomfunctions = createObject("component", "cfc.xwtable.xwcustomfunctions");
</cfscript>
</cffunction>


<cffunction name="getRemote" access="remote" returntype="void" output="true">
<cfargument name="Action" type="string" required="true" />

<cfscript>
URL.Action=ARGUMENTS.Action;
setupVars();
</cfscript>

<cfcontent type="text/xml" />
<cfoutput>
<taconite-root xml:space="preserve">
#show(true)#
<taconite-replace  contextNodeID="baskettotal" parseInBrowser="true">
<div id="baskettotal">
TOTAL: <span id="grandTotal"><cfif SESSION.Auth.isLoggedIn>&##163; #trim(DecimalFormat(session.shopper.basket.getGrandTotal()))#</cfif></span>
</div>  
</taconite-replace>
</taconite-root>
</cfoutput>
</cffunction>


<cffunction name="addRemote" access="remote" returntype="void" output="true">
<cfargument name="ProductID" type="numeric" required="true" />
<cfargument name="qty" type="numeric" required="false" default="1" />

<cfscript>
session.shopper.basket.add(ARGUMENTS.ProductID, ARGUMENTS.qty); 
setupVars();
</cfscript>

<cfcontent type="text/xml" />
<cfoutput>
<taconite-root xml:space="preserve">
#show(true)#
<taconite-replace  contextNodeID="baskettotal" parseInBrowser="true">
<div id="baskettotal">
TOTAL: <span id="grandTotal"><cfif SESSION.Auth.isLoggedIn>&##163; #trim(DecimalFormat(session.shopper.basket.getGrandTotal()))#</cfif></span>
</div>  
</taconite-replace>
</taconite-root>
</cfoutput>
</cffunction>


<cffunction name="show" access="public" returntype="string" output="false">
<cfargument name="isRemoteRequest" type="boolean" default="false" required="false" />

	<!--- build the content on to an xml variable --->
	<cfxml variable="myBasket">
	<cfoutput>
	<cfif ARGUMENTS.isRemoteRequest>
    <taconite-replace  contextNodeID="myBasketWrap" parseInBrowser="true">
	</cfif>	
	<div id="myBasketWrap">
	<!--- if there are items in the basket create the table, otherwise return empty div --->
	<cfif VARIABLES.myBasket.recordcount gt 0>
		<table id="myBasket">
		<tbody>
		<tr class="firstrow"><td colSpan="3"><cfif VARIABLES.ExpandMode>Showing All items<cfelse>Showing Last 5 added</cfif></td></tr><cfloop query="VARIABLES.myBasket" startrow="#startrow#" endrow="#VARIABLES.myBasket.recordcount#">
		<tr <cfif currentrow eq VARIABLES.myBasket.recordcount>class="lastAdded"</cfif>>
<td style="width:17px">(#quantity#)</td><td style="width:129px">#xmlformat(left(session.shopper.basket.getProductDescription(productID), 20))#</td><td style="width:31px"><cfif SESSION.Auth.isLoggedIn>#decimalformat(session.shopper.basket.getTotal(productID))#</cfif></td>
		</tr></cfloop>
		
		<tr id="tblBasketEdit">
			<td colSpan="3"><a id="tblBasketEditLink" href="basket.cfm">Edit Items or View All <img src="<cfoutput>#session.shop.skin.path#</cfoutput>nav_basket_edit.gif" alt="Edit my shopping basket" /></a></td>
		</tr>		
<tr id="tblBasketExpand">
<td colSpan="3"><cfif VARIABLES.ExpandMode><cfif SESSION.UserAgent.AjaxSupport><a id="tblBasketContractLink" href="javascript:void(0)" onclick="Basket.Contract();">
<cfelse><a id="tblBasketContractLink" href="?#trim(parsedQS(true))#&amp;ev=basket&amp;action=Contract">
</cfif>Show last 5<img src="<cfoutput>#session.shop.skin.path#</cfoutput>nav_basket_contract.gif" alt="Close up my shopping basket" /></a>
<cfelseif VARIABLES.showExpandLink><cfif SESSION.UserAgent.AjaxSupport><a id="tblBasketExpandLink" href="javascript:void(0)" onclick="Basket.Expand();">
<cfelse><a id="tblBasketExpandLink" href="?#trim(parsedQS(true))#&amp;ev=basket&amp;action=Expand"></cfif>Show All (<span id="noOfItems">#VARIABLES.myBasket.recordcount#</span>)<img src="<cfoutput>#session.shop.skin.path#</cfoutput>nav_basket_expand.gif" alt="Open up my shopping basket" /></a></cfif>
</td>
</tr>
		</tbody>
		</table>
	</cfif>
	</div>
	<cfif ARGUMENTS.isRemoteRequest>
	</taconite-replace>
	</cfif>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myBasket=replace(toString(myBasket), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myBasket=reReplace(myBasket, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myBasket>

</cffunction>

<cffunction name="showOld" access="public" returntype="string" output="false">

<cfset VARIABLES.myOldBasket = session.shopper.oldbasket.list()>

	<!--- build the content on to an xml variable --->
	<cfxml variable="myBasket">
	<cfoutput>
	<div id="basketContainer">
	<!--- if there are items in the basket create the table, otherwise return empty div --->
		<span id="basketTitle">These items are in your shopping basket:</span>
		<table id="myBasketItems">
		<thead>
		<tr>
			<th>Description</th>
			<th>Packsize</th>
			<th>Portion Cost</th>
			<th>Price</th>
			<th>Quantity</th>
			<th>Total</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="VARIABLES.myOldBasket" startrow="1" endrow="#VARIABLES.myOldBasket.recordcount#">
		<cfset itemDetails=session.shopper.oldbasket.getItemDetails(ProductID) />
		<cfset portionCost=VARIABLES.xwcustomfunctions.getPortionSize(itemDetails.UnitOfSale, itemDetails.SalePrice)>
		<tr>
			<td>#xmlformat(itemDetails.Description)#</td>
			<td>#xmlformat(itemDetails.UnitOfSale)#</td>
			<td style="width:40px"><cfif portionCost neq "">#decimalformat(portionCost)#</cfif></td>
			<td id="prc_#ProductID#">&##163;#itemDetails.SalePrice#</td>
			<td id="qty_#ProductID#">#quantity#</td>
			<td id="tot_#ProductID#">&##163;#decimalformat(session.shopper.oldbasket.getTotal(productID))#</td>
		</tr>
		</cfloop>
		<tr id="myBasketItemsGrandTotal">
			<td id="myBasketItemsGrandTotalTxt" colspan="5">Grand Total</td>
			<td id="myBasketItemsGrandTotalVal" colspan="2">&##163;#decimalformat(session.shopper.oldbasket.getGrandTotal())#</td>
		</tr>
		</tbody>
		</table>
		<p style="margin-bottom:2em;">
		   <span id="basketActions">
			<form id="myOldBasketItemsForm" method="post" action="#xmlformat(cgi.SCRIPT_NAME)#">
			<input type="submit" name="frmSubmit" value="Keep Old Basket" />
			<input style="width:200px;" type="submit" name="frmSubmit" value="Keep and Edit these items" />
			<input style="width:250px;" type="submit" name="frmSubmit" value="Start shopping with new Basket" />
			</form>
		  </span>
		</p>
	</div>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myBasket=replace(toString(myBasket), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myBasket=reReplace(myBasket, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myBasket>


</cffunction>


<cffunction name="showEdit" access="public" returntype="string" output="false">
<cfargument name="refresh" 			required="false" type="boolean" default="false" />

<!--- Does the basket list need to be refreshed?
Notes: This component is initialised by application.cfc in the request scope. if the 
basket is updated and then this function is called directly afterwards then 
the the basket list will be different. --->
<cfif ARGUMENTS.refresh>
<cfset VARIABLES.myBasket = session.shopper.basket.list()>
</cfif>


	<!--- build the content on to an xml variable --->
	<cfxml variable="myBasket">
	<cfoutput>
	<div id="basketContainer">
	<!--- if there are items in the basket create the table, otherwise return empty div --->
	<cfif VARIABLES.myBasket.recordcount gt 0>
		<span id="basketTitle">These items are in your shopping basket:</span>
		<form id="myBasketItemsForm" method="post" action="#xmlformat(cgi.SCRIPT_NAME)#">
		<table id="myBasketItems">
		<thead>
		<tr>
			<th>Description</th>
			<th>Packsize</th>
			<th>Portion Cost</th>
			<th>Price</th>
			<th>Quantity</th>
			<th>Total</th>
			<th>Remove</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="VARIABLES.myBasket" startrow="1" endrow="#VARIABLES.myBasket.recordcount#">
		<cfset itemDetails=session.shopper.basket.getItemDetails(ProductID) />
		<cfset portionCost=VARIABLES.xwcustomfunctions.getPortionSize(itemDetails.UnitOfSale, itemDetails.SalePrice)>
		<tr>
			<td>#xmlformat(itemDetails.Description)#</td>
			<td>#xmlformat(itemDetails.UnitOfSale)#</td>
			<td style="width:40px"><cfif SESSION.Auth.isLoggedIn><cfif portionCost neq "">#decimalformat(portionCost)#</cfif></cfif></td>
			<td id="prc_#ProductID#"><cfif SESSION.Auth.isLoggedIn>&##163;#itemDetails.SalePrice#</cfif></td>
			<td id="qty_#ProductID#"><input id="fldQty_#ProductID#" name="fldQty_#ProductID#" class="fldQty" type="text" value="#quantity#" onblur="FRM.setTotal(#ProductID#);" /></td>
			<td id="tot_#ProductID#"><cfif SESSION.Auth.isLoggedIn>&##163;#decimalformat(session.shopper.basket.getTotal(productID))#</cfif></td>
			<td><a class="basketItemDelete" href="#cgi.SCRIPT_NAME#?ev=basket&amp;action=remove&amp;ProductID=#ProductID#">Remove <img src="#session.shop.skin.path#icon-remove.gif" alt="remove this item" /></a></td>
		</tr>
		</cfloop>
		<tr id="myBasketItemsGrandTotal">
			<td id="myBasketItemsGrandTotalTxt" colspan="5">Grand Total</td>
			<td id="myBasketItemsGrandTotalVal" colspan="2"><cfif SESSION.Auth.isLoggedIn>&##163;#decimalformat(session.shopper.basket.getGrandTotal())#</cfif></td>
		</tr>
		<tr id="myBasketItemsFooter">
			<td colspan="5"></td>
			<td colspan="2"><input name="frmSubmit" type="submit" value="Update Basket" /></td>
		</tr>
		</tbody>
		</table>
		<p>
		<span id="basketActions">
		<input name="frmSubmit" type="submit" value="Continue Shopping" />
		<input name="frmSubmit" type="submit" value="Checkout" />
		</span>
		</p>
		</form>
	<cfelse>
	<!--- no items to display! --->
	<p>
	<span id="basketTitle">There are no items currently in your shopping basket</span>
	<span id="basketActions">
	<a href="#XMLFormat(session.lastRequest)#">Continue Shopping<img src="#session.shop.skin.path#arrow_right_small.gif" alt="Continue Shopping" /></a>
	</span>
	</p>
	</cfif>
	</div>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myBasket=replace(toString(myBasket), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myBasket=reReplace(myBasket, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myBasket>

</cffunction>

<cffunction name="getStaffFormattedList" access="public" returntype="string" output="false">
<cfargument name="refresh" 			required="false" type="boolean" default="false" />

<cfif ARGUMENTS.refresh>
<cfset VARIABLES.myBasket = session.shopper.basket.list()>
</cfif>
	<!--- build the content on to an xml variable --->
	<cfxml variable="myBasket">
	<cfoutput>
		<table id="myBasketItems">
		<thead>
		<tr>
			<th>Stockcode</th>
			<th>Description</th>
			<th style="text-align:center;">Quantity</th>
			<th style="text-align:center;">Pack Size</th>
			<th style="text-align:center;">Total</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="VARIABLES.myBasket" startrow="1" endrow="#VARIABLES.myBasket.recordcount#">
		<cfset itemDetails=session.shopper.basket.getItemDetails(ProductID) />
		<cfset portionCost=VARIABLES.xwcustomfunctions.getPortionSize(itemDetails.UnitOfSale, itemDetails.SalePrice)>
		<tr>
			<td>#xmlformat(itemDetails.StockCode)#</td>
			<td>#xmlformat(itemDetails.Description)#</td>
			<td id="qty_#ProductID#" style="text-align:center;">#quantity#</td>
			<td id="unt_#ProductID#" style="text-align:center;">#xmlformat(itemDetails.UnitOfSale)#</td>
			<td id="tot_#ProductID#" style="text-align:center;">&##163;#decimalformat(session.shopper.basket.getTotal(productID))#</td>
		</tr>
		</cfloop>
		<tr id="myBasketItemsGrandTotal">
			<td id="myBasketItemsGrandTotalTxt" colspan="3">Grand Total</td>
			<td id="myBasketItemsGrandTotalVal" style="text-align:center;">&##163;#decimalformat(session.shopper.basket.getGrandTotal())#</td>
		</tr>
		</tbody>
		</table>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myBasket=replace(toString(myBasket), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myBasket=reReplace(myBasket, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myBasket>


</cffunction>


<cffunction name="showCheckOut" access="public" returntype="string" output="false">
<cfargument name="refresh" 			required="false" type="boolean" default="false" />

<!--- Does the basket list need to be refreshed?
Notes: This component is initialised by application.cfc in the request scope. if the 
basket is updated and then this function is called directly afterwards then 
the the basket list will be different. --->
<cfif ARGUMENTS.refresh>
<cfset VARIABLES.myBasket = session.shopper.basket.list()>
<cfset var myProduct = ""/>

</cfif>


	<!--- build the content on to an xml variable --->
	<cfxml variable="myBasket">
	<cfoutput>
		<table id="myBasketItems">
		<thead>
		<tr>
			<th>Description</th>
			<th style="text-align:center;">Quantity</th>
			<th style="text-align:center;">Pack Size</th>
			<th style="text-align:center;">VAT</th>
			<th style="text-align:center;">Total</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="VARIABLES.myBasket" startrow="1" endrow="#VARIABLES.myBasket.recordcount#">
		<cfset product = session.shopper.basket.getProduct(ProductID)/>

		<tr>
			<td>#xmlformat(product.getDescription())#</td>
			<td id="qty_#ProductID#" style="text-align:center;">#quantity#</td>
			<td id="unt_#ProductID#" style="text-align:center;">#product.getPacksize()#</td>
			<td id="tot_#ProductID#" style="text-align:center;">&##163;#decimalformat(product.getTaxAmount())#</td>
			<td id="tot_#ProductID#" style="text-align:center;">&##163;#decimalformat(session.shopper.basket.getTotal(productID))#</td>
		</tr>
		</cfloop>
		<tr id="myBasketItemsGrandTotal">
			<td id="myBasketItemsGrandTotalTxt" colspan="4">Grand Total</td>
			<td id="myBasketItemsGrandTotalVal" style="text-align:center;">&##163;#decimalformat(session.shopper.basket.getGrandTotal())#</td>
		</tr>
		</tbody>
		</table>
	</cfoutput>
	</cfxml>
	
	<!---remove xml declaration and extraneous spaces and cariage returns--->
	<cfset myBasket=replace(toString(myBasket), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset myBasket=reReplace(myBasket, ">[[:space:]]+#chr( 13 )#<", "all")>
	
	<!--- return the XHTML  --->
	<cfreturn myBasket>

</cffunction>



<cffunction name="parsedQS" access="public" returntype="string" output="false">
<cfargument name="xmlFormat" type="boolean" required="false" default="false" />
<cfscript>
var qS = cgi.QUERY_STRING;
var qS_list="";
var qS_substring="";
	
	//remove any url parameters used in the table because they are generated again
	if (listlen(qS, "&") neq 0) {
		//iterate through the querystring
		for (i=1; i LTE listlen(qS, "&"); i=i+1) {
			//extract the url parameter at this position in the list
			qs_substring=ListGetAt(qS, i, "&"); 
			
			// if it contains one of a set of url parameters delete it from the query string
			if (FindNoCase("ev=basket", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}	
			
			if (FindNoCase("action=Expand", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("action=Contract", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}			
		
			if (FindNoCase("action=Add", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}
			
			if (FindNoCase("ProductID=", qs_substring) neq 0) {
			 	qS_list = qS_list & "&" & ListGetAt(qS, i, "&");
			}	
				
		}	
		
	}

		
	if (qS_list neq "") {
	qS=replace(qS, qS_list,"");
	} 
	
	//replace the question mark
	qS=replace(qS, "?", "");
	
	//is is just purely a question mark
	if (left(qS, 1) eq "&") {
		qS=replace(qS, "&", ""); //replace the first occurence only
	}

	//format for XML?
	if (ARGUMENTS.xmlFormat) {
	qS=replace(qS, "&", "&amp;", "ALL");	
	}
//return "#trim(qS)#";

return reReplace(qS, ">[[:space:]]+#chr( 13 )#<", "all");
</cfscript>
</cffunction>


</cfcomponent>