<!--- 
	Filename: /cfc/departments/view.cfc 
	Created by:  Matt Barfoot on 15/04/2006 Clearview Webmedia Limited
	Purpose:  Generates views for departments in the VegExp online shop
--->
<cfcomponent name="view" displayname="view"  output="false" hint="Generates views for departments in the VegExp online shop">

<!--- / Object declarations / --->
<cfscript>
view_do		=createObject("component", "cfc.departments.do");
delivery	=createObject("component", "cfc.departments.delivery");
util		=createObject("component", "cfc.shop.util");
</cfscript>


<!---/*******************************************************************************/
	 / ------------------/ PRODUCST LISTS : CATEGORY INFO /-------------------------- /
     /*******************************************************************************/--->

<!--- *** PARTIAL VIEW: PRODUCT CATALOGUE *** --->
<cffunction name="getCategoryList" output="false" returntype="string" access="public">
<cfargument name="department" required="true" type="string" />

<cfset var qryCats=view_do.getQryCategories(ARGUMENTS.department)>
<cfset var col1startrow=1>
<cfset var col1endrow=round(qryCats.recordcount/3)>
<cfset var col2startrow=col1endrow+1>
<cfset var col2endrow=round(qryCats.recordcount/3)*2>
<cfset var col3startrow=col2endrow+1>
<cfset var col3endrow=qryCats.recordcount>



<cfxml variable="myList">
<cfoutput>
<div id="listContainer" class="clearfix">
	<!--- <a class="showAll" href="#cgi.script_name#?CategoryID=ALL&amp;ShowProducts=true">Show All Products</a> --->
<cfif qryCats.recordcount gte 1>
	<div id="list1">
		<ul>
		<cfloop query="qryCats" startrow="#col1startrow#" endrow="#col1endrow#"><li><a href="#cgi.script_name#?showProducts=true&amp;CategoryID=#xmlFormat(CategoryID)#">#IIF(len(Category) gte 25, DE(left(Category, 25) & "..."), DE(Category))# <span>(#pCount#)</span></a></li>
		</cfloop>
		</ul>
	</div>
	<div id="list2">
		<ul>
		<cfloop query="qryCats" startrow="#col2startrow#" endrow="#col2endrow#"><li><a href="#cgi.script_name#?showProducts=true&amp;CategoryID=#xmlFormat(CategoryID)#">#IIF(len(Category) gte 25, DE(left(Category, 25) & "..."), DE(Category))# <span>(#pCount#)</span></a></li>
		</cfloop>
		</ul>
	</div>
	<div id="list3">
		<ul>
		<cfloop query="qryCats" startrow="#col3startrow#" endrow="#col3endrow#"><li><a href="#cgi.script_name#?showProducts=true&amp;CategoryID=#xmlFormat(CategoryID)#">#IIF(len(Category) gte 25, DE(left(Category, 25) & "..."), DE(Category))# <span>(#pCount#)</span></a></li>
		</cfloop>
		</ul>
	</div>
<cfelse>	
Sorry, no products found. 
</cfif>
</div>
</cfoutput>
</cfxml>

<cfset myList=replace(ToString(myList), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myList, "[\r\n]+", "#Chr(10)#", "ALL")>

</cffunction>

<!---/*******************************************************************************/
	 / ------------------/ DELIVERY AND POSTCODE BASKET /-------------------------- /
     /*******************************************************************************/--->

<!--- *** WARNING: NOT ABLE TO DELIVER TO YOUR AREA! *** --->
<cffunction name="notAbleToDeliver" output="false" returntype="string" access="public">
<cfargument name="Department" required="true" type="string" />

<cfxml variable="myContent">
<cfoutput>
	<div id="regFormContainer" class="clearfix">
	<p>
	Sorry, unfortunately we are unable to deliver frozen and chilled goods to your postcode: #SESSION.Auth.Postcode#.
	</p><br />
	<p>
	Please call our Sales Office to see whether we may be able to deliver to your area in the future.
	</p>
	</div>
</cfoutput>
</cfxml>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>


</cffunction>

<!--- *** FORM: SUPPLY POSTCODE TO CHECK WHETHER IN DELIVERY AREA *** --->
<cffunction name="postcodeChkandBypass" output="false" returntype="string" access="public">
<cfargument name="Department" required="true" type="string" />

<cfxml variable="myContent">
<cfoutput>
	<div id="regFormContainer" class="clearfix">
		<cfform id="frmPostCodeCheck" name="frmPostCodeCheck" action="#cgi.script_name#" method="post" format="html">
			<span class="fieldsetTitle" style="margin-top:1em;display:block">Before ordering, please enter your postcode to check we can deliver frozen goods to you area:</span>
			<fieldset>
			<p>
  					<label for="postcode">Enter your Postcode:</label>
			    	<cfif isdefined("form.postcode")>
			    	<input type="text" class="small" name="postcode" id="postcode" value="#form.postcode#"/>
			    	<cfelse>
			    	<input type="text" class="small" name="postcode" id="postcode" />
					</cfif>
			 	</p>
			 	<p>
				 <input type="submit" style="margin-left:145px;" class="btn" name="frmSubmit" value="Check Postcode" />
			 	</p>
			 	<cfif isdefined("form.postcode")>
			 	<p style="padding-top:1em !important;">
				 	<cfset possibleDeliveryDays = delivery.viewFC(form.postcode) />
				 	<cfif possibleDeliveryDays neq "">
					<span style="color: ##177730;">We can deliver #ARGUMENTS.Department# goods to your area on the following days: #possibleDeliveryDays#</span>  	
					<cfelse>
					<span style="color:red">
					Your postcode could not be matched against the areas we deliver #ARGUMENTS.Department# goods.<br /><br />
					Please check with our sales team for more information. 
					</span>
					</cfif>	
			 	</p>
			 	</cfif>
				</fieldset>	 
			<p style="margin-top:1em;margin-bottom:1em;">
			 <strong>Or you can:</strong>
			 </p>
			 <span id="shopperActions">
				<a style="margin-left:0px" href="register.cfm">Register Now</a>
				<a href="#cgi.SCRIPT_NAME#?bypass=true">Browse frozen products</a>
			</span> 
		</cfform>
	</div>
</cfoutput>
</cfxml>

<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>


</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ Minimum Order Value /---------------------------------------- /
     /*******************************************************************************/--->

<!--- *** WARNING: NO ITEMS IN SHOPPING BASKET *** --->
    <cffunction name="mov" output="false" returntype="string" access="public">

        <cfscript>
        //get the breadcrumb trail
            shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Check out");

            //get the readonly shopping list
            shoppingList = session.basketContents.showCheckOut(true);
        </cfscript>

<!--- build the content on to an xml variable --->
        <cfxml variable="myContent">
            <div id="productListWrapper">
            <div id="productList">
            <cfoutput>#shopperBreadcrumbTrail#</cfoutput>
            <cfoutput>
                    <div id="checkoutContainer">
                    <form name="checkoutEditForm" id="checkoutForm" method="post" action="/basket.cfm">
                        <p><strong>Sorry, the total value of your order is less than the minimum order value</strong></p>
                        <p style="margin: 1em 0em;">Please add additional items to your basket before checking out</p>

                        <div class="chkoutSec">
                            <span class="chkoutSecTitle">Your items</span>
                        #shoppingList#
                        </div>

                        <span id="checkoutActions">
                            <span id="checkoutTitle" style="display: inline-block; width: 450px">You can edit your shopping basket or add more items from the Ambient, Frozen or Chilled sections.</span>
                            <input name="frmSubmitCheckOut" id="frmSubmitCheckOut2" type="submit" value="Edit Order"  />
                        </span>
                    </form>
                    </div>
            </cfoutput>
            </div>
            </div>
        </cfxml>


        <cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
        <cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

        <cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>



    </cffunction>

<!---/*******************************************************************************/
	 / ------------------/ SHOPPING BASKET /---------------------------------------- /
     /*******************************************************************************/--->

<!--- *** WARNING: NO ITEMS IN SHOPPING BASKET *** --->
<cffunction name="emptyBasket" output="false" returntype="string" access="public">

<cfscript>
//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Check out");
</cfscript>

<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>
		<div id="checkoutContainer">
			<p><strong>Sorry, your basket appears to be empty!</strong></p>
			<p style="margin: 1em 0em;">Please put some items in your basket before checking out</p>
		</div>
		</cfoutput>
	</div>	
</div>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>



</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ CHECKOUT AND ORDER PROCESSING /-------------------------- /
     /*******************************************************************************/--->

<!--- *** WARNING: ORDER CURRENTLY PROCESSING *** --->
<cffunction name="orderProcessing" output="false" returntype="string" access="public">
<cfscript>
//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Please wait while we process your order");
</cfscript>

<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>
		<div id="checkoutContainer">
			<p class="shopperFeedBack">
				<img id="ordproc" src="/resources/processing.gif" alt="pc communicating with database" />
			</p>
			<p style="margin:2em 0em;">
			<strong>Please do not press Reload, F5 or leave this page until processing is complete</strong>
			</p>		
			<p class="shopperFeedBack"><strong>We are processing your order, which can take up a few seconds or a few minutes.<br /><br /> Thanks for your patience.</strong></p>
	
		</div>
		</cfoutput>
	</div>	
</div>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>
		
</cffunction>

<!--- *** WARNING: SAGE GW PROBLEM *** --->
<cffunction name="orderError" output="false" returntype="string" access="public">
<cfscript>
//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("There will be a short delay while we process your order");
</cfscript>

<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>
		<div id="checkoutContainer">
			<p><img src="/resources/warning.gif"  alt="Warning: a problem occurred" style="float:left;padding: 6px 6px 6px 6px;" />
			</p>
			
			<p class="shopperFeedBack"><strong>Why will there be a delay?</strong></p>
			<p class="shopperFeedBack">There was a problem transferring your order to our order fulfilment system automatically. This sometimes happens, but we have all your order details.<br /><br /></p>
			<div class="chkoutSec" style="margin-left: 70px;">	
			<p><strong>What happens now?</strong></p>
				<ul id="ordNotes">
				 <li>A copy has been sent to the sales team. They will add your order into the system.</li>
				 <li>You will receive an Order Confirmation email shortly (maximum delay 4 hours) or a phone call if any further information is required.</li>
				</ul>	
			</div>
			<div class="chkoutSec" style="margin-left: 70px;">
				<p>
				<strong>If you not heard from us within 4 hours:</strong><br />
				Call us and quote your Web Order Reference: <strong>#session.shopper.WebOrderRef#</strong>
				</p>
			</div>	
		</div>
		</cfoutput>
	</div>	
</div>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>

<!--- *** WARNING: PAYMENT GATEWAY NOT ENABLED *** --->
<cffunction name="orderPartComplete" output="false" returntype="string" access="public">
<cfscript>
//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Sorry, there will be a small delay while we process your order");
</cfscript>

<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>
		<div id="checkoutContainer">
			<p><img src="/resources/warning.gif"  alt="Warning: a problem occurred" style="float:left;padding: 6px 6px 6px 6px;" />
			</p>
			
			<p class="shopperFeedBack"><strong>Why will there be a delay?</strong></p>
			<p class="shopperFeedBack">Your order has been transferred to our Order system, but some details need to be checked by our Sales team before your order is confirmed.<br /><br /></p>
			<div class="chkoutSec" style="margin-left: 70px;">	
			<p><strong>What happens now?</strong></p>
				<ul id="ordNotes">
				 <li>A member of the sales has been notified and will take steps to process your order as quickly as possible.</li>
				 <li>You should receive an Order Confirmation email shortly (maximum delay 4 hours) or a phone call if any further information is required.</li>
				</ul>	
			</div>
			<div class="chkoutSec" style="margin-left: 70px;">
				<p>
				<strong>If you not heard from us within 4 hours:</strong><br />
				Call us and quote your Web Order Reference: <strong>#session.shopper.WebOrderRef#</strong>
				</p>
			</div>	
		</div>
		</cfoutput>
	</div>	
</div>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>


<!--- *** CONFIRMATION: ORDER COMPLETED *** --->
<cffunction name="orderComplete" output="false" returntype="string" access="public">
<cfscript>
//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Thanks for your order");
</cfscript>

<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>
		<div id="checkoutContainer">
			<div class="chkoutSec">
			<p><img src="/resources/ok.gif"  alt="Order successful" style="float:left;padding: 6px 6px 6px 6px;" />
			</p>
			</div>
			<div class="chkoutSec" style="margin-left: 80px;">
			<p><strong>Your order numbers is: #session.shopper.orderID#</strong>.</p>
			<p style="margin-bottom: 4em;">An Order Confirmation has been emailed to you which includes details of your 
			order and other useful information.</p>	
			</div>
			
			<div class="chkoutSec">
			<p><img src="/resources/info.gif"  alt="Hint/Info" style="float:left;padding: 6px 6px 6px 6px;" />
			</p>
			</div>
			
			<div class="chkoutSec" style="margin-left: 80px;">
			<p style="margin-bottom: 4em;"><strong>Hint: Using the Favourites Tab</strong><br /><br />
			The items you just ordered are stored as "Favourites". You can select these at any time from now on by using the Favourites Tab.
			
			</p>
			</div>
			
			<div class="chkoutSec">
			<p><img src="/resources/questions.gif"  alt="Questions" style="float:left;padding: 6px 6px 6px 6px;" />
			</p>
			</div>
			
			<div class="chkoutSec" style="margin-left: 80px;">
			<p>
			<strong>Any questions about your order?</strong><br /><br />
			If you have any questions call us or <a href="mailto:sales@vegexp.co.uk">email</a> our sales team and we will be happy to help. 
			</p>
			</div>		
		</div>
		</cfoutput>
	</div>	
</div>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>

<!--- *** FORM: CHECK OUT*** --->
<cffunction name="checkOutForm" output="false" returntype="string" access="public">
<cfargument name="isCreditAuthorised" required="true"  type="boolean" />
<cfargument name="paymentDeclined"    required="false" type="boolean" default="false" />
<cfargument name="porequired"    	required="false" type="boolean" default="true" />

<cfscript>
//create the delivery profile object
request.delivery = createObject("component", "cfc.departments.delivery").init();

//get the delivery address
deliveryAddress = request.delivery.getAddress();

//get the delivery contact name
deliveryContact = request.delivery.getDeliveryContact();

//get the delivery notes
deliveryNotes = request.delivery.getDeliveryNotes();

if (not isdefined("form.customerPO")) {
form.customerPO = "";
}

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Check Out");

//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the readonly shopping list 
shoppingList = session.basketContents.showCheckOut(true);	



</cfscript>

<!--- build the content on to an xml variable --->

<cfsavecontent variable="myContent">
    <style type="text/css">

        #modal_wrapper.overlay:before {
            content: " ";
            width: 100%;
            height: 100%;
            position: fixed;
            z-index: 100;
            top: 0;
            left: 0;
            background: #000;
            background: rgba(0,0,0,0.7);
        }

        #modal_window {
            display: none;
            z-index: 200;
            position: fixed;
            left: 50%;
            top: 50%;
            width: 500px;
            padding: 10px 20px;
            background: #fff;
            border: 5px solid #999;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.5);
        }

        #modal_wrapper.overlay #modal_window {
            display: block;
        }

    </style>

    <div id="modal_wrapper">
        <div id="modal_window">
            <div id="checkoutContainer">
                <p class="shopperFeedBack">
                    <img id="ordproc" src="/resources/processing.gif" alt="pc communicating with database" />
                </p>
                <p style="margin:2em 0em;">
                    <strong>Please do not press Reload, F5 or leave this page until processing is complete</strong>
                </p>
                <p class="shopperFeedBack"><strong>We are processing your order, which can take up a few seconds or a few minutes.<br /><br /> Thanks for your patience.</strong></p>

            </div>
        </div>
    </div>

    <div id="productListWrapper">
    <div id="productList">
    <cfoutput>#shopperBreadcrumbTrail#</cfoutput>
    <cfoutput>
            <div id="checkoutContainer">
                    <form name="checkoutForm" id="checkoutForm" method="post" action="#xmlformat(cgi.SCRIPT_NAME)#">
                <input type="hidden" name="delnotes" id="delnotes" 	value="#XMLFormat(deliveryNotes)#" />
                <input type="hidden" name="delbuilding" id="delbuilding" 	value="#XMLFormat(deliveryAddress.building)#" />
                <input type="hidden" name="delline1" 	id="delline1" 		value="#XMLFormat(deliveryAddress.line1)#" />
                <input type="hidden" name="delline2" 	id="delline2" 		value="#XMLFormat(deliveryAddress.line2)#" />
                <input type="hidden" name="delline3" 	id="delline3" 		value="#XMLFormat(deliveryAddress.line2)#" />
                <input type="hidden" name="deltown" 	id="deltown" 		value="#XMLFormat(deliveryAddress.town)#" />
                <input type="hidden" name="delcounty" 	id="delcounty" 		value="#XMLFormat(deliveryAddress.county)#" />
                <input type="hidden" name="delpostcode" id="delpostcode"	value="#XMLFormat(deliveryAddress.postcode)#" />

            <span id="checkoutActions">
        <span id="checkoutTitle">
                Please check your order details below carefully before clicking "Confirm Order".
                <br /> A copy of these details will also be available in your confirmation email</span>
                <input name="frmSubmitCheckOut" id="frmSubmitCheckOut1" type="submit" value="Confirm Order" />
            </span>

        <div class="chkoutSec">
            <span class="chkoutSecTitle">Your items</span>
            #shoppingList#
            </div>

            <div class="chkoutSec">
                <span class="chkoutSecTitle">Delivery Details</span>
            <p>Your items will be delivered on <span id="addDelDay">#SESSION.Auth.DelDay#</span> to:</p>
        <table id="delAddress" summary="Delivery address details">
        <tr>
            <td class="delColDesc">Building No/Name:</td>
        <td><span class="delField">#XMLFormat(deliveryAddress.building)#</span></td>
        </tr>
        <tr>
            <td  class="delColDesc">Address:</td>
        <td><cfif deliveryAddress.line1 neq ""><span class="delField">#XMLFormat(deliveryAddress.line1)#</span><br /></cfif>
            <cfif deliveryAddress.line2 neq ""><span class="delField">#XMLFormat(deliveryAddress.line2)#</span><br /></cfif>
            <cfif deliveryAddress.line3 neq ""><span class="delField">#XMLFormat(deliveryAddress.line3)#</span><br /></cfif>
            <cfif deliveryAddress.town neq ""><span class="delField">#XMLFormat(deliveryAddress.town)#</span><br /></cfif>
            <cfif deliveryAddress.county neq ""><span class="delField">#XMLFormat(deliveryAddress.county)#</span><br /></cfif>
            </td>
            </tr>
            <tr>
                <td class="delColDesc">Postcode:</td>
            <td><span class="delField">#deliveryAddress.Postcode#</span></td>
        </tr>
            <tr style="height:10px;">
                <td class="delColDesc"></td>
                <td></td>
            </tr>
        </table>
        </div>

        <div class="chkoutSec">
            <span class="chkoutSecTitle">Your Purchase Order reference:</span>
        <span class="delField"><input style="margin-top: 0em; width: 200px; font-weight: normal; margin-bottom: 0.4em; font-size: 0.9em;" name="customerPO" id="customerPO" value="#form.customerPO#" /></span>
        </div>

        <div class="chkoutSec">
        <span class="chkoutSecTitle">Payment Details <cfif NOT isCreditAuthorised><img style="padding-left: 82px;" src="/resources/cardicons.gif" alt="icons of accepted credit cards" /></cfif></span>
        </div>
            <cfif NOT isCreditAuthorised>
                <cfinclude template="/views/ccform.cfm" />
                <cfelse>
                    <div id="isCreditAuthorised">
                    #chr(163)##decimalformat(session.shopper.basket.getGrandTotal())# will be charged to your account.
                </div>
            </cfif>
                <div class="chkoutSec">
                    <span class="chkoutSecTitle">Notes</span>
                    <ul id="ordNotes">
                        <li>Once you click "confirm" you will be given an order reference</li>
                        <li>You will receive a copy of all these details via email</li>
                        <li>If you need to cancel or change any order details please contact our sales team by 3:30pm for next day deliveries or within 24 hours of your delivery date for all other deliveries.</li>
                    </ul>
                </div>
                <span id="checkoutActions">
			<span id="checkoutTitle">Please check your order details above carefully before clicking "Confirm Order".<br /></span>
			<input name="frmSubmitCheckOut" id="frmSubmitCheckOut2" type="submit" value="Confirm Order"  />
		</span>
            </form>
            </div>
    </cfoutput>
    </div>
    </div>

    <script type="text/javascript">

        // Original JavaScript code by Chirp Internet: www.chirp.com.au
        // Please acknowledge use of this code by including this header.

        var modal_init = function() {

            var modalWrapper = document.getElementById("modal_wrapper");
            var modalWindow  = document.getElementById("modal_window");

            var openModal = function(e)
            {
                modalWrapper.className = "overlay";
                modalWindow.style.marginTop = (-modalWindow.offsetHeight)/2 + "px";
                modalWindow.style.marginLeft = (-modalWindow.offsetWidth)/2 + "px";
                e.preventDefault ? e.preventDefault() : e.returnValue = false;
            };

            var closeModal = function(e)
            {
                modalWrapper.className = "";
                e.preventDefault ? e.preventDefault() : e.returnValue = false;
            };

            var clickHandler = function(e) {
                if(!e.target) e.target = e.srcElement;
                if(e.target.tagName == "DIV") {
                    if(e.target.id != "modal_window") closeModal(e);
                }
            };

            var keyHandler = function(e) {
                if(e.keyCode == 27) closeModal(e);
            };

            if(document.addEventListener) {
                // document.getElementById("modal_open").addEventListener("click", openModal, false);
                //document.getElementById("modal_close").addEventListener("click", closeModal, false);
                document.addEventListener("click", clickHandler, false);
                document.addEventListener("keydown", keyHandler, false);
            } else {
                //document.getElementById("modal_open").attachEvent("onclick", openModal);
                //document.getElementById("modal_close").attachEvent("onclick", closeModal);
                document.attachEvent("onclick", clickHandler);
                document.attachEvent("onkeydown", keyHandler);
            }

            var form = document.getElementById('checkoutForm');
            form.addEventListener("submit", function(e) {
                var url = "/cfc/shop/order.cfc?method=saveRemote";
                e.preventDefault();
                openModal(e);
                var ajaxRequest = new AjaxRequest(url);
                ajaxRequest.addFormElements('checkoutForm');
                ajaxRequest.sendRequest();

            });

        };

        modal_init();
    </script>

</cfsavecontent>

<cfset content=ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>

<!---/*******************************************************************************/
	 / ------------------/ PRODUCT INFO /------------------------------------------ /
     /*******************************************************************************/--->

<!--- *** REMOTE AJAX/TACONITE: DISPLAY PRODUCT INFORMATION *** --->
<cffunction name="prodInfoRemote" output="true" returntype="void" access="remote">
<cfargument name="ProductID" type="string" required="true" />
<cfargument name="TargetID" type="string" required="true" />

<cfset var qryProdInfo = view_do.getProdInfo(ARGUMENTS.ProductID)>

<cfcontent type="text/xml" />
<cfoutput>
<taconite-root xml:space="preserve">
<taconite-replace  contextNodeID="#ARGUMENTS.TargetID#" parseInBrowser="true">
<div id="pInfoDivContent">	 
<img id="pInfoDiv-pointer" src="/skin/default/productInfo-pointer-v2.png" />
<div id="pInfoDiv-hd"></div>
<div id="pInfoDiv-body">
<div id="pInfoInnerWrap">
<cfif isQuery(qryProdInfo)>
<p id="pInfoProdTitle"><span>#XMLFormat(qryProdInfo.ShortDesc)#</span></p>
<p id="pInfoProdDesc"><img src="#XMLFormat(qryProdInfo.ImageSrc)#" alt="#XMLFormat(qryProdInfo.ImageAlt)#" />These beans are especially good beans, perhaps the best beans in the world. You must buy them today. They are in short supply and we have limited stock. They are flying off the shelf and on to our delivery vans. Your customers will love you for buying this bean. Quick... get them while stocks last! <!--- #XMLFormat(ReReplace(qryProdInfo.Description, ">[[:space:]]+#chr( 13 )#<", "#Chr(10)#", "ALL"))# ---></p>
<cfelse> 
<p id="pInfoProdTitle"><span>Sorry no information found for this item</span></p>
<p id="pInfoProdDesc">
Sorry no information found for this item
</p>
</cfif>
</div>
</div>
<div id="pInfoDiv-foot"></div>
</div>		
 </taconite-replace>
</taconite-root>
</cfoutput>

</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ RECIPE /------------------------------------------------- /
     /*******************************************************************************/--->

<!--- *** PARTIAL VIEW:  RECIPE *** --->
<cffunction name="getRecipe" output="false" returntype="string" access="public">
<cfargument name="RecipeID" type="numeric" required="true" />
<cfargument name="ProductID" type="numeric" required="false" default="0" />

<cfscript>
//  get the recipe info query, which may consist of 1 or more records 
 var qryRecipeInfo 	= view_do.getSingleRecipeInfo(ARGUMENTS.RecipeID, Arguments.ProductID);
 var qryPopRecipes	= view_do.getRecipeTitles(0);
</cfscript>

<cfxml variable="myContent">
<cfoutput>
<div id="recipeContent">
		<cfif isQuery(qryRecipeInfo)>
		<div id="recipeTitle">
			<h1>#XMLFormat(qryRecipeInfo.Title)#</h1>
		<cfif qryRecipeInfo.Yield neq ""><span style="padding-left: 3px;">Yield:	       <span class="titleDetail">#qryRecipeInfo.Yield#</span></span></cfif>
		<cfif qryRecipeInfo.PrepTime neq ""><span style="padding-left: 1em;">Prep time:    <span class="titleDetail">#qryRecipeInfo.PrepTime#</span></span></cfif>
		<cfif qryRecipeInfo.CookTime neq ""><span style="padding-left: 1em;">Cooking time: <span class="titleDetail">#qryRecipeInfo.CookTime#</span></span></cfif> 
		<cfif StructKeyExists(URL, "pfriendly")>
		<span id="printRecipe" style="position: absolute; top: 3em; right: 2em;"><a class="recipeAction" href="##" onclick="self.print()">Print</a></span>
		<cfelse>
		<span id="printRecipe"><a class="recipeAction" href="/recipes.cfm?RecipeID=#ARGUMENTS.RecipeID#&amp;pfriendly=true">Print Friendly</a></span>
		</cfif>
		</div>
		<div id="recipeDesc" class="clearfix">
			<!---RHS Image and Popular Recipes box--->
			<div id="recipeImg">
				<img src="#XMLFormat(qryRecipeInfo.ImageSrc)#" alt="#XMLFormat(qryRecipeInfo.ImageAlt)#"  />
			</div>	
			<div id="recipeRHS">
			<div id="recipePopular" style="margin-top:1em">
				<span style="font-weight: bold; padding-bottom: 6px; display: block;">5 Most Popular</span>
				<ul>
				<cfloop query="qryPopRecipes" startrow="1" endrow="5">
				<li><a href="/recipes.cfm?RecipeID=#qryPopRecipes.RecipeID#">#Title#</a></li>
				</cfloop>
				</ul>
			</div>
			</div>
			<p>#qryRecipeInfo.Description#</p>
			<p id="ingredientsList">#qryRecipeInfo.Footer#</p>
			<p style="margin-top:2em;"><a class="recipeAction" href="/recipes.cfm">Back to Recipes</a></p>
		</div>	
		<cfelse> 
		<div id="recipeTitle" style="width: 634px"><span>Sorry no recipes found!</span></div>
		<div id="recipeDesc">
			
		</div>
 		</cfif>
</div>
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>


<cffunction name="getRecipeListByProductID" output="false" returntype="string" access="public">
<cfargument name="ProductID" type="numeric" required="false" default="0" />

<cfscript>
//  get the recipe info query, which may consist of 1 or more records 
var qryRecipesByProduct = view_do.getRecipesByProductID(ARGUMENTS.ProductID);
var qryPopRecipes	= view_do.getRecipeTitles(0);
var qryShorts		= "";
</cfscript>

<cfxml variable="myContent">
<cfoutput>
<div id="recipeContent">
		<div id="recipeDesc" class="clearfix">
			<div id="recipeRHS">
			 <div id="recipePopular">
				<span style="font-weight: bold; padding-bottom: 6px; display: block;">5 Most Popular</span>
				<ul>
				<cfloop query="qryPopRecipes" startrow="1" endrow="5">
				<li><a href="/recipes.cfm?RecipeID=#qryPopRecipes.RecipeID#">#Title#</a></li>
				</cfloop>
				</ul>
			</div>	
			</div>
			<div id="rCat0" class="recipeCat">
			<h2 style="margin-bottom: 1em;">#qryRecipesByProduct.recordcount# recipes for #convertCodesFull(qryRecipesByProduct.Description)#</h2>
			<cfloop query="qryRecipesByProduct">
			<cfset qryShorts=view_do.getSingleRecipeShort(RecipeID)>
			<p class="recipeItem"><a href="/recipes.cfm?RecipeID=#RecipeID#">#qryShorts.Title#</a><br />
			<span>#qryShorts.Yield#, Prep time: #qryShorts.PrepTime#, Cooking time: #qryShorts.CookTime#</span>
			<img src="#XMLFormat(qryShorts.ThumbSrc)#" alt="#XMLFormat(qryShorts.ImageAlt)#"  />
			</p>
			#recipeListLimit(qryShorts.Description, 7)#	
			<p style="margin-bottom:2em;"><a class="recipeAction" href="/recipes.cfm?RecipeID=#RecipeID#">View this recipe</a></p>			
			</cfloop>
			<p style="margin-bottom:1em;"><a class="recipeAction" href="/recipes.cfm">Full Recipe List</a></p>
			</div> 
		</div>	
</div>
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>

<!--- *** PARTIAL VIEW:  RECIPE LIST *** --->
<cffunction name="getRecipeList" output="false" returntype="string" access="public">

<cfscript>
//  get the recipe info query, which may consist of 1 or more records 
var qryRecipeCatInfo = view_do.getRecipeCatInfo();
var qryPopRecipes	= view_do.getRecipeTitles(0);
var qryShorts		= "";
</cfscript>

<cfxml variable="myContent">
<cfoutput>
<div id="recipeContent">
<div id="recipeDesc" class="clearfix">
<div id="recipeRHS">
<div id="recipePopular">
<span style="font-weight: bold; padding-bottom: 6px; display: block;">5 Most Popular</span>
<ul>
<cfloop query="qryPopRecipes" startrow="1" endrow="5">
<li><a href="/recipes.cfm?RecipeID=#qryPopRecipes.RecipeID#">#Title#</a></li></cfloop>
</ul> 
</div>
<div id="addYourRecipe">
<span style="font-weight: bold; padding-bottom: 6px; display: block;">Add Your Recipe</span>
<p>
Send us your recipe and if we like it we will add it here.
<a href="mailto:recipes@vegexp.co.uk?subject=Recipe Suggestion">recipes@vegexp.co.uk</a>
</p>
</div>
</div>	
<cfloop query="qryRecipeCatInfo">
<div id="rCat#(currentrow-1)#" class="recipeCat" <cfif currentrow neq 1>style="height:18px;"<!--- <cfelse>style="margin-top:6px;" ---></cfif>>
<cfset qryShorts=view_do.getRecipeShorts(RecipeCatID)>
<cfset elHeight = 155 + (qryShorts.recordcount * 50)>
<a id="rCat#currentrow-1#-hide" class="minimise" href="javascript:void(0)" onclick="RECIP.minMax('rCat#currentrow-1#', #elHeight#, 18)">Hide</a>			
<a id="rCat#currentrow-1#-show" class="maximise" href="javascript:void(0)" onclick="RECIP.minMax('rCat#currentrow-1#', 18, #elHeight#)">Show</a>		
<h2>#Title#</h2>
<img src="#thumbsrc#" alt="#ImageAlt#"  />
<p>#Description#</p>
<ul class="recipeShorts">
<cfloop query="qryShorts">
<li><a href="/recipes.cfm?RecipeID=#RecipeID#">#qryShorts.Title#</a><br />
<span>#qryShorts.Yield#, Prep time: #qryShorts.PrepTime#, Cooking time: #qryShorts.CookTime#</span></li>	
</cfloop>
</ul>
</div>
</cfloop> 
</div>	
</div>
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>

<!--- *** REMOTE AJAX/TACONITE: DISPLAY RECIPE INFORMATION *** --->
<cffunction name="recipeInfoRemote" output="true" returntype="void" access="remote">
<cfargument name="ProductID" type="string" required="true" />
<cfargument name="TargetID" type="string" required="true" />
<cfargument name="showPosition" type="string" required="false" default="mid" />


<!--- get the recipe info query, which may consist of 1 or more records --->
<cfset var prodDescription 	= view_do.getStockDesc(ARGUMENTS.ProductID)> 
<cfset var qryRecipeInfo 	= view_do.getRecipeInfo(ARGUMENTS.ProductID)>
<cfset var recipeNumber 	= randrange(1, qryRecipeInfo.recordcount)> 
<cfset var qryPopRecipes	= view_do.getRecipeTitles(qryRecipeInfo.recipeID[recipeNumber])>

<cfcontent type="text/xml" /> 
<cfoutput>
<taconite-root xml:space="preserve">
<taconite-replace  contextNodeID="#ARGUMENTS.TargetID#" parseInBrowser="true">
<div id="pInfoDivContent">	 
<cfif ARGUMENTS.showPosition eq "mid">
<img id="pInfoDiv-pointer" src="/skin/default/productInfo-pointer-v2.png" />
<cfelse>
<img id="pInfoDiv-pointer" style="top: 226px;" src="/skin/default/productInfo-pointer-down-v2.png" />
</cfif>
<div id="pInfoDiv-hd"></div>
<div id="pInfoDiv-body">
<div id="pInfoInnerWrap">
<cfif isQuery(qryRecipeInfo)>
<p id="pInfoProdTitle"><span>Sample recipe using <strong>#convertCodesFull(prodDescription)#</strong></span></p>
<p id="pInfoProdDesc" class="clearfix">		
<div id="recipeRHS">
<img src="#XMLFormat(qryRecipeInfo.ThumbSrc[recipeNumber])#" alt="#XMLFormat(qryRecipeInfo.ImageAlt[recipeNumber])#" />
<p> 
<strong>Popular Recipes</strong><br />
<cfloop query="qryPopRecipes" startrow="1" endrow="4">
#Title# <br />
</cfloop> 
</p>
</div> 
<span id="rTitle">#XMLFormat(trim(qryRecipeInfo.Title[recipeNumber]))#</span><br /><br />
#recipeListLimit(qryRecipeInfo.Description[recipeNumber], 10)#<br /> 
Click the <img class="icon" src="/skin/default/icon_recipe_small.gif" alt="recipes" /> icon to view Full recipe details<br />
</p>
<cfelse> 
<p id="pInfoProdTitle"><span>Sorry no information found for this item</span></p>
<p id="pInfoProdDesc">
Sorry no information found for this item
</p>
</cfif>
</div>
</div>
<div id="pInfoDiv-foot"></div>
</div>		
</taconite-replace>
</taconite-root>
</cfoutput>

</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ SPECIAL OFFERS /---------------------------------------- /
     /*******************************************************************************/--->


<!--- *** PARTIAL VIEW:  OFFER LIST *** --->
<cffunction name="getOfferList" output="false" returntype="string" access="public">

<cfscript>
//  get the recipe info query, which may consist of 1 or more records 
var qryOfferCatInfo = view_do.getOfferCatInfo();
var qryShorts		= "";
</cfscript>

<cfxml variable="myContent">
<cfoutput>
<div id="offerContent">
		<div id="offerDesc" class="clearfix">
			<cfif qryOfferCatInfo.recordcount>
			<cfloop query="qryOfferCatInfo">
			<cfset qryShorts=view_do.getOfferShorts(OfferID)>
			<!--- check if thumbnail is available, yes use 127 as height calc, no use 30 --->
			<cfset elHeight = 112>
			<!--- adjust initial height if ie6  --->
			<cfif SESSION.UserAgent.id eq "IE" AND SESSION.UserAgent.version lte 6>
				<cfset elHeight = 148>
			</cfif>
			<cfloop query="qryShorts">
					<cfset elHeight = elHeight + IIF(len(ThumbSrc) gt 0, DE("117"), DE("39")) /> 
			</cfloop>
						
			<div id="oCat#(currentrow-1)#" class="offerCat" <cfif currentrow eq 1>style="margin-top:0px;height:#elHeight#px"<cfelse>style="height:#elHeight#px"</cfif>>	
				<div id="offerTitle">
						<h1><a href="javascript:void(0)" onclick="OFFER.show('oCat#currentrow-1#')">#XMLFormat(Description)#</a></h1>
					    <span id="offerEnds">Offer ends: #LSDateFormat(Expiry, "dddddd d mmmm yyyy")#</span>
					    <span id="offerDiscount">All items listed are priced at #Discount#% discount off normal list price</span>
				</div>
				<div>
						<ul class="offerShorts">

						<cfloop query="qryShorts">
						<li<cfif len(qryShorts.Description) eq 0 AND len(ThumbSrc) eq 0> style="margin-bottom:6px; line-height: 12px; height: 30px;"</cfif>><span class="fldItemDesc">#XMLFormat(qryShorts['"itemdesc"'][currentrow])#</span> <span class="fldPriceInfo">£#XMLFormat(qryShorts.SalePrice)# for #XMLFormat(qryShorts.UnitOfSale)#</span>
						<cfif len(qryShorts.Description) gt 0><br /><span class="fldDesc">#XMLFormat(qryShorts.Description)#</span></cfif>
						<cfif len(ThumbSrc) gt 0><br /><img src="#ThumbSrc#" alt="#ImageAlt#" /></cfif>
						<a <cfif len(qryShorts.Description) eq 0 AND len(ThumbSrc) eq 0>class='addtobasketnoimage'<cfelse>class='addtobasket'</cfif> href='#cgi.script_name#?#xmlformat(cgi.QUERY_STRING)#&amp;ev=basket&amp;action=Add&amp;ProductID=#qryShorts.StockID#'>Add to Basket</a>
						</li></cfloop> 
						</ul>		
				<a id="oCat#currentrow-1#-hide" class="minimise" href="javascript:void(0)" onclick="OFFER.minMax('oCat#currentrow-1#', #elHeight#, 75)" style="display: block;">Hide</a>			
				<a id="oCat#currentrow-1#-show" class="maximise" href="javascript:void(0)" onclick="OFFER.minMax('oCat#currentrow-1#', 75, #elHeight#)" style="display: block;">Show</a>		
				</div>
			</div>
			</cfloop>
			<cfelse>
			<div id="noOffers" style="padding-left: 1em;">Please contact our sales team via 01923 249714 to get our current offers.</div>
			</cfif> 
		</div>	
</div>
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ CONTACT US /--------------------------------------------- /
     /*******************************************************************************/--->

<!--- *** FORM:  Contact Us *** --->
<cffunction name="getContactForm" output="false" returntype="string" access="public">

<cfscript>
//  vars

</cfscript>

<cfsavecontent variable="myContent">
<cfoutput>
						<div id="contactFormContainer">
							<cfform id="frmContact" name="frmContact" action="contact.cfm" onsubmit="return CONTfrm.chkPref()" method="post" format="html">
							<p style="margin-bottom:1em;">To contact us call us on 01923 249714, <a href="mailto:sales@vegexp.co.uk">email us</a> or use the simple form below:</p>
							<span class="fieldsetTitle">Please enter your details and a short message below</span>
							<p style="color: ##177730; margin-top:1em;">Fields marked * are required</p>
								<fieldset>
								 <p>
								    <label for="company">Company name: *</label>
								    <input type="text" name="company" id="company" required="true" message="Please enter your company name"  <cfif isdefined("form.company")>value="#form.company#"</cfif> />
								</p>
							    <p>
									<label for="firstName">First name: *</label>
								    <input type="text" class="small" name="firstname" id="firstName" <cfif isdefined("form.firstname")>value="#form.firstname#"</cfif> />
								    <label for="lastName" class="fldinline">Last name: *</label>
								    <input type="text" class="small" name="lastname" id="lastName"   <cfif isdefined("form.lastName")>value="#form.lastName#"</cfif>/>
								</p>
							     <p>
									<label for="contactPref" class="long">Contact Preference: <span>Telephone</span></label>
								    <input type="radio" class="radiobtn" name="contactPref" id="contactPref" value="phone" <cfif isdefined("form.contactPref") and form.contactPref eq "phone">checked="true"</cfif> />
								    <label for="contactPref" class="fldinline">Email:</label>
								    <input type="radio" class="radiobtn" name="contactPref" id="contactPref" value="email" <cfif isdefined("form.contactPref") and form.contactPref eq "email">checked="true"</cfif> />
								</p>
							    <p>
								    <label for="telnum">Telephone number:</label>
								    <input type="text" class="med" name="telnum" id="telnum" <cfif isdefined("form.telnum")>value="#form.telnum#"</cfif> />
								</p>
								<p>
								    <label for="emailAddress">Email Address: </label>
								    <input type="text" class="med" name="emailaddress" id="emailAddress" <cfif isdefined("form.emailAddress")>value="#form.emailAddress#"</cfif>/>
								</p>
							    <p>
								     <label for="message">Your Message: *</label>
								     <textarea name="message" id="message" required="true" validate="noblanks" message="Please enter a message so we can respond to your question(s)!"> </textarea>
							    </p>


								    <input type="hidden" name="submitted" value="1" />
                                    <input type="hidden" name="captcha_check" value="#FORM.captcha_check#" />
							    <p>
                            	<label for="captchanull"> </label>
								<cfimage action="captcha" height="75" width="363" text="#request.strCaptcha#" difficulty="low" fonts="verdana,arial,times new roman,courier" fontsize="28" />
                                </p>

                                <p>
									<cfif isdefined("request.sCaptchaError")>
                                            <label for="captcha" style="color: red">#request.sCaptchaError#</label>
										<cfelse>
                                            <label for="captcha">Please enter text in image:</label>
									</cfif>
                                    <input type="text"  name="captcha" id="captcha" value="" style="width: 200px;" />
								</p>

								</fieldset>
								<p style="text-align: center">
								<label for="accType"></label><input type="submit" name="frmSubmit" value="Submit" /> 
								</p>
								</cfform>				
							</div>						
</cfoutput>
</cfsavecontent>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>

<cffunction name="getContactThanks" output="false" returntype="string" access="public">

<cfscript>
//  vars

</cfscript>

<cfxml variable="myContent">
<cfoutput>
						<div id="contactFormContainer">	
								<div>
									<p><img src="/resources/ok.gif"  alt="Message Sent" style="float:left;padding: 6px 6px 6px 6px;" />
									</p>
									</div>
									<div style="margin-left: 80px; font-size: 0.9em;">
									<p style="margin-bottom: 1em;"><strong>Thanks for your comments/message.</strong></p>
									<p style="margin-bottom: 4em;">A member of staff will contact you shortly, but this make take up to 24 hours. Please be patient while we respond. If you need to contact us urgently you can always call us on 01923 249714. Thank you.</p>	
								</div>
						</div>						
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ ADVANCED SEARCH /--------------------------------------------- /
     /*******************************************************************************/--->

<!--- *** FORM:  Contact Us *** --->
<cffunction name="getAdvancedSearchForm" output="true" returntype="string" access="public">

<cfscript>
//  vars
qryCats = view_do.getCategories();
</cfscript>

<cfsavecontent variable="myContent">
<cfoutput>
						<div id="advSearchFormContainer">
							<cfform id="frmAdvSearch" name="frmAdvSearch" action="advanced_search.cfm" method="post" format="html">
							<p style="margin-bottom:1em;">Use our advanced search to find the products quickly and easily:</p>
								<fieldset>
								 <p>
								    <label for="qFilter">Filter: </label>
								    <select class="med" name="qFilter" id="qFilter">
								    	<option value="All">All</option>
								    	<option value="Organic">Organic</option>
								    	<option value="Vegan">Vegan</option>
								    	<option value="GlutenFree">Gluten Free</option>
								    </select>
								</p>
								<p>
								    <label for="qCategory">Category: </label>
								   <select id="qCategory">
								    <option selected="selected" value="All">All</option>
									<cfloop query="qryCats">
										<option value="#CategoryID#">#xmlformat(Category)#</option>
									</cfloop>
									</select>
								</p>
								<p>
								    <label for="qDescription">Product Description:</label>
								    <input class="med" type="text" name="qDescription" id="qDescription" />
								</p>
								</fieldset>
								<p style="text-align: center">
								<label for="accType"></label><input type="submit" name="frmSubmit" value="Search" /> 
								</p>
								</cfform>				
							</div>						
</cfoutput>
</cfsavecontent> 

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>

</cffunction>


<!---/*******************************************************************************/
	 / ------------------/ UTILITIES /----------------------------------------------- /
     /*******************************************************************************/--->

<!--- *** UTIL:STRING:REPLACE I.E. REPLACE "ORG" WITH "ORGANIC"... *** --->
<cffunction name="convertCodesFull" access="private" returnType="string" hint="Looks for the Organic, Gluten Free and Vegan codes and converts them to icons">
<cfargument name="description" type="String"  required="true"  hint="the string to check" />

<cfscript>

if (Find("(ORG)", description)) { 
description = replace(description, "(ORG)", "");
description = "Organic " & description; 
}

if (Find("(Vegan)",description)) { 
description = replace(description, "(Vegan)", "");
description = "Vegan " & description; 
}

if (Find("(Gluten Free)",description)) { 
description = replace(description, "(Gluten Free)", "");
description = "Gluten Free " & description;
}

return description;	
</cfscript>
</cffunction>

<!--- *** UTIL:XHTML:TRUNCATE -  UNOREDERED XHTML LIST TO DESIRED NUMBER OF ITEMS --->
<cffunction name="recipeListLimit" access="private" returnType="string" output="false" hint="takes a unordered list and limits/truncates to a set number of items">
<cfargument name="XHTMLList" type="string" required="true" />
<cfargument name="itemLimit" type="numeric" required="true" />

<cfscript>
var xmlList 			= xmlparse(ARGUMENTS.XHTMLList);
var ListElementCount 	= ArrayLen(xmlList.ul.li);
var newList				= "";
var deleteCount 		= 0;
var deleteList			= "";

if (ListElementCount LTE ARGUMENTS.itemLimit) {
	return ARGUMENTS.XHTMLList;
} else {

		/* ******* remove other list elements **************
		To make this work properly we need to work backwards through
		the <li> xml array. The array length is reduced by 1 
		everytime we use ArrayDeleteAt so if we work backwards
		we can reduce the our counter (ListElementCount) by 1 every time
		an element is deleted. */ 
		
		
		for (i=ListElementCount-1; i gte ARGUMENTS.itemLimit; i=i-1) {
			ArrayDeleteAt(xmlList.ul.li, i);
		}

		xmlList.ul.xmlChildren[ARGUMENTS.itemLimit+1] = XmlElemNew(xmlList, "li");
		xmlList.ul.li[ARGUMENTS.itemLimit+1].xmlText = "(more ingredients)...";
		xmlList.ul.li[ARGUMENTS.itemLimit+1].xmlAttributes["class"] = "moreIngredients";
		
newList=replace(toString(xmlList), '<?xml version="1.0" encoding="UTF-8"?>', '');
newList=ReReplace(newList, "[\r\n]+", "#Chr(10)#", "ALL");
return  reReplace(newList, ">[[:space:]]+#chr( 13 )#<", "ALL");
}

</cfscript>
</cffunction>

</cfcomponent>