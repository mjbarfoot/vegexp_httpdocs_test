<!--- 
	Component: order.cfc
	File: /cfc/shop/order.cfc
	Description: retrieves, edits and saves customer orders
	Author: Matt Barfoot
	Date: 25/05/2006
	Revisions:
	--->

<cfcomponent output="false" name="order" displayname="order" hint="retrieves, edits and saves customer orders">
	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//
// get the shop Data Object save order data to the web db
VARIABLES.shopDO=createObject("component", "cfc.shop.do").init();

//get the email dispatcher//get the email dispatcher

VARIABLES.eml	=createObject("component", "cfc.shop.dispatchMsg");

//get the delivery object
VARIABLES.delivery = createObject("component", "cfc.departments.delivery");

//return a copy of this object
return this;
</cfscript>
</cffunction> 

 <!--- *** SAVE METHOD *** --->
<cffunction name="save" access="public" returntype="void" output="false">
<cfargument name="FORM" type="struct" required="true">
<cfscript>
/* 		 - checks quantity available and returns to basket if not enough
		 - converts basket to order with order id
		 - saves order to database
		 - adds to order queue
		 - confirms order to customer via email
		 - if copyOrder = true notifySalesTeam
		 - confirms order to customer via screen 
		 
*/
var myorder = createObject("component", "cfc.model.order").init();


if (APPLICATION.stockService.stockAvailable(SESSION.shopper.basket)) {
	if (myorder.createOrder(SESSION.shopper.basket)) {

		myorder.save(); // save order to database

		APPLICATION.orderqueueService.add(myorder); // add to order queue
		
		notifycustomer(); // notify customer
		
		// order successful		
		session.shopper.orderStatus="complete";	
		
		
	} // order could not be created
		else {
		// log fatal error 
		// return to check out screen
		session.shopper.orderStatus = "OrderServiceUnavailable";
	}	
}  // no stock for specific items... basket updated... go back to checkout
	else {
	session.shopper.orderStatus = "StockUnavilable";
}



</cfscript>

</cffunction>







<cffunction name="notifyCustomer" access="private" returntype="boolean" output="false">

<cfscript>
var fromEmailAddress = APPLICATION.var_DO.getVar("WebSalesEmailAddress");
var salesEmailAddress = APPLICATION.var_DO.getVar("salesEmailAddress");
    
/***********************************************
				EMAIL - Email Customer & copy to Sales
Email customer in all instances apart from paymentIncomplete
where the customer will check payment details and resubmit
**********************************************/
if (session.shopper.orderStatus neq "paymentDeclined") {

	Msg = structnew();
	
	if (session.shopper.orderStatus neq "complete") {
	Msg.OrderID = right(session.shopper.orderID, 6);
	} else {
	Msg.OrderID = session.shopper.orderID;
	}
	
	Msg.title = "Sales Order #Msg.OrderID# Confirmation";
	
	//get the readonly shopping list 
	Msg.DeliveryDate = VARIABLES.delivery.getDelDate(SESSION.Auth.AccountID);
	//get the delivery notes
	Msg.deliveryNotes = VARIABLES.delivery.getDeliveryNotes();
	//get the shopping list
	Msg.shoppingList = session.basketContents.showCheckOut(true);
	
	// Send Customer Confirmation email
	if (Application.appMode neq "development") {
		ccEmailAddress = "sales@vegexp.co.uk";
		} else {
		ccEmailAddress = "matt.barfoot@clearview-webmedia.co.uk";
	}
	
	
	VARIABLES.eml.sendEmail(SESSION.Auth.EmailAddress,
				            fromEmailAddress,
							"Your Sales Order Confirmation - Order No: #Msg.OrderID#", 
							msg,
							"/views/emlSalesOrderConfirmation.cfm");
	
	
	
	Msg.shoppingList = session.basketContents.getStaffFormattedList(true);
	// Send Copy to Sales staff
	VARIABLES.eml.sendEmail(salesEmailAddress,
				            ccEmailAddress,
							"New Sales Order Notification: Order No: #Msg.OrderID#", 
							msg,
							"/views/emlSalesOrderStaffNotification.cfm");

</cfscript>


</cffunction>


</cfcomponent>