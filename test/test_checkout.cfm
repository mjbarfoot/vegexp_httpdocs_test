<cfscript>
    isCreditAuthorised = true;

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


//add the css file
    if (isdefined("request.css")) {
        request.css=request.css & "," & session.shop.skin.path & "checkout.css";
    } else {
        request.css= session.shop.skin.path & "checkout.css";
    }


    request.js = "/js/formUI.js";
</cfscript>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title><cfif isdefined("shopperBreadcrumbTrail")><cfoutput>#request.pageTitle#</cfoutput><cfelse>Welcome to Vegetarian Express</cfif></title>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<cfloop list="#session.shop.skin.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
</cfloop>
<cfloop list="#request.css#" index="cssfile"><link rel="stylesheet" type="text/css" href="<cfoutput>#cssfile#</cfoutput>" />
</cfloop>
    <link rel="icon" href="favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
    <script type="text/javascript" src="/js/prototype.lite.js"></script>
    <script type="text/javascript" src="/js/moo.fx.js"></script>
    <script type="text/javascript" src="/js/fat.js"></script>
    <script type="text/javascript" src="/js/taconite-parser.js"></script>
    <script type="text/javascript" src="/js/taconite-client.js"></script>
    <script type="text/javascript" src="/js/vegexp.js"></script>
<cfif SESSION.Auth.AccountID neq "" AND SESSION.Auth.IsCookieOK eq "">
        <script type="text/javascript" src="/js/ModalPopups.js"></script>
        <script type="text/javascript" src="/js/ve-modal.js"></script>
</cfif>
<script type="text/javascript" src="<cfoutput>#session.shop.skin.path#</cfoutput>fx.js"></script>
<cfif isdefined("request.js")><cfloop list="#request.js#" index="jsfile"><script type="text/javascript" src="<cfoutput>#jsfile#</cfoutput>"></script>
</cfloop></cfif>
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
        width: 800px;
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


</head>
<body>
<cfif SESSION.Auth.AccountID neq "" AND SESSION.Auth.IsCookieOK eq "">
    <script>
        ModalPopupsConfirm();
    </script>
</cfif>
<div id="wrapper">
<div id="head">
<cfinclude template="/views/partHeadTop.cfm" />
				<cfinclude template="/views/partHeadTabs.cfm" />
</div>
    <div id="body_topborder"></div>
<div id="body" class="clearfix">
<cfinclude template="/views/partRHSnav.cfm" />

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
        <tr>
            <td class="delColDesc" style="vertical-align:top;">Delivery Contact:</td>
        <td><span class="delField"><input style="margin-top: 0em; width: 200px; font-weight: normal; margin-bottom: 0.4em; font-size: 0.9em;" name="deliveryContact" id="deliveryContact" value="#deliveryContact#" /></span></td>
        </tr>
        <tr>
            <td class="delColDesc" style="vertical-align:top;">Delivery Notes:</td>
        <td><span class="delField"><textarea name="delnotes" id="delnotes" wrap="HARD" cols="40" rows="5">#IIF(REFind("[A-z0-9]", deliveryNotes) neq 0, DE((XMLFormat(deliveryNotes))), DE(" "))#</textarea></span></td>
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



<cfinclude template="/views/partOrdHotline.cfm" />
</div>
<cfinclude template="/views/partFoot.cfm" />
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
</body>
</html>