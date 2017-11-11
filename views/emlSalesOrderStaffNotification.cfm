<cfscript>
server_name = CGI.SERVER_NAME;
server_port = CGI.SERVER_PORT;
delivery=createObject("component", "cfc.departments.delivery");

if (NOT isdefined("Msg")) {
Msg = structnew();
Msg.OrderID = "999999";

Msg.title = "Sales Order Notification - Order No: " & Msg.OrderID;

//get the readonly shopping list 
Msg.DeliveryDate = delivery.getDelDate();
//get the delivery notes
Msg.deliveryNotes = delivery.getDeliveryNotes();
//get the shopping list
Msg.shoppingList = session.basketContents.getStaffFormattedList();
}	

</cfscript>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
#wrapper {margin-left: 100px; margin-right: auto; width: 500px; padding: 1em; border: 1px solid #177730;}
#logo {background: url(https://orders.vegetarianexpress.co.uk/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
#header {height: 20px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: #177730; color: White; padding-left: 1em;}
p {magin-bottom: 1.6em;}
p a {color: #177730;}
#questions {background-image: url(https://orders.vegetarianexpress.co.uk/pix/icon-info.gif); background-position: top left; background-repeat: no-repeat; padding-left: 70px; margin-bottom: 1em;}

/* Check Out Container, Table etc */
#checkoutContainer {background-color: White; /*border: 1px solid #649C32;*/ font-size: 0.9em; padding:0.7em; margin-top: 0.6em; }
#checkoutContainer div.chkoutSec {margin: 1em 0em;}
#checkoutContainer div.chkoutSec span.chkoutSecTitle {position: relative; border-bottom: 1px solid #177730; font-weight: bold; font-size: 0.9em; display: block; padding-bottom: 0.4em; margin-top:0.4em;}
/*******************************************************************************/
/* ------------------/ Checkout: Read only Shopping List----------------------- */
/*******************************************************************************/
/* myBasketItems Table */
#myBasketItems {font-size: 0.9em; width: 480px; border: none !important; border-bottom:1px solid #CBE7B3; border-collapse: collapse;} 
#myBasketItems th {text-align:left; padding: 3px; border-right: none !important; border-left: none !important; border-bottom: 1px solid #CBE7B3; background-color: #CBE7B3;} 
#myBasketItems td {padding: 3px;  border-right: none !important; border-left: none !important;  border-bottom: 1px solid #CBE7B3;}
#myBasketItems td a.basketItemDelete {color: Black; text-decoration: none;	font-weight: Bold;}
#myBasketItems td a.basketItemDelete:hover {color: Black; text-decoration: none;	font-weight: Bold; text-decoration: underline;}
#myBasketItems #myBasketItemsGrandTotal {font-weight: Bold; font-size: 1.2em;}
#myBasketItems #myBasketItemsGrandTotal td {padding: 5px 3px;}
#myBasketItems #myBasketItemsGrandTotal #myBasketItemsGrandTotalTxt {text-align: right;}
#myBasketItemsFooter td {border: none; background-color: #CBE7B3;}

</style>
</head>
<body>
<div id="wrapper">
	<cfoutput>
	<div id="logo"></div>
	<div id="header">
		<h1>#Msg.title#</h1>
	</div>
	
	<div id="checkoutContainer">
		<div class="chkoutSec">
		<p>
			Dear Sales Team,<br />
			The following web sales order was transferred to Sage 200.
		</p>
		</div>
		<div class="chkoutSec">
				<span class="chkoutSecTitle">Order #Msg.OrderID# Submitted by: </span>
		AccountID: #SESSION.AUTH.AccountID# <br />
		Company: #SESSION.Auth.Company# <br />
		Contact: #SESSION.AUTH.Firstname# #SESSION.AUTH.lastname# <br />
		</div>	
		
		<div class="chkoutSec">
			<span class="chkoutSecTitle">Delivery Date</span>			
			Order Delivery Date: #dateformat(Msg.DeliveryDate, "dd/mm/yyyy")#
		</div>	

			
		<div class="chkoutSec">
			<span class="chkoutSecTitle">Ordered items</span>
			#Msg.shoppingList#
		</div>	
	</div>
	</cfoutput>
</div>
</body>
</html>