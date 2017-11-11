stockDO=APPLICATION.stockDO,discountRate=SESSION.auth.discountRate<!---
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

// get the payment gateway
VARIABLES.payGW=createObject("component", "cfc.shop.paymentGW").init();

// get the shop Data Object save order data to the web db
VARIABLES.shopDO=createObject("component", "cfc.shop.do").init();

// get the sage Gateway
VARIABLES.sageGW=createObject("component", "cfc.sagegw.sageWSGW");

//get the email dispatcher
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
<!--- use to check credit is authorised in case of form variable manipulation 
isCreditAuthorised = request.seccontrol.isCreditAuthorised();--->

<cfscript>
/********************   Credit is Authorised 	***************************************
Payment 	| Sage  	  | Payment      | Order  | 	
GW Enabled  | GW Enabled  | Accepted     | Posted |  session.shopper.orderStatus
-------------------------------------------------------------------------------------
False		|	False	  |	True 		 |	N/A   |		NotPostedToSage
False		|	True	  |	True         |  True |		Complete
True		|	False	  |	True	 	 |	N/A   |		NotPostedToSage	
True		|	True	  |	True         |	True  |		Complete

********************   ** NO Credit, Pay via Credit Card ****************************
Payment 	| Sage  	  | Payment      | Order  | 	
GW Enabled  | GW Enabled  | Accepted     | Posted |  session.shopper.orderStatus
-------------------------------------------------------------------------------------
False		|	False	  |	N/A		 	 |	N/A   |		NotPostedToSage (Payment Not Taken)
False		|	True	  |	N/A 		 |	True  |		paymentIncomplete
True		|	False	  |	False	 	 |	N/A   |		paymentDeclined (retry)
True		|	True	  |	False	 	 |	True  |		paymentDeclined (retry)
***************************************************************************************/

var ResultPlaceSalesOrder="";
var Payment_Status=false;
var OrderPostedToSage_Status=false;
var orderStatusDesc="";
var ccEmailAddress = "";

// check again whether credit is authorised
ARGUMENTS.FORM.isCreditAuthorised = request.seccontrol.isCreditAuthorised();	

// if account is on hold then payment must be taken via the payment gateway
if (request.seccontrol.isAccountOnHold()) {
ARGUMENTS.FORM.isCreditAuthorised = false;
}

// *********** CREDIT IS AUTHORISED
if (ARGUMENTS.FORM.isCreditAuthorised) {
	
	 //*********** CASE 1: No PayGW and No SageGW
	 if (NOT APPLICATION.payGWenabled AND NOT APPLICATION.sageGWenabled) {
		
		// write application log
		application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 1: No PayGW and No SageGW");
		
		// order cannot be posted via Sage GW, inform Shopper
		session.shopper.orderStatus="NotPostedToSage";
		orderStatusDesc = "This order was not posted into Sage because the Sage Gateway is currently disabled";	
	 } 
	 
	 //*********** CASE 2: No PayGW but SageGW OK
	 else if (NOT APPLICATION.payGWenabled AND APPLICATION.sageGWenabled) {
		
		
		// write application log
		application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 2: No PayGW but SageGW OK");
		
		//MB: 04/08/08 - Disabled because discounting not working 
		// awaiting Aspidistra fix	
		//ResultPlaceSalesOrder = true; 
		ResultPlaceSalesOrder=VARIABLES.sageGW.PlaceSalesOrder(ARGUMENTS.FORM);
		
		if (NOT ResultPlaceSalesOrder) {
			// ********  oops could not post to SAGE, set status to processing and inform shopper!
			session.shopper.orderStatus="NotPostedToSage";
			orderStatusDesc = "The Sage Gateway would not accept the Order. Additional information avaible by logging into the website";	
			session.shopper.orderID=session.shopper.WebOrderRef;
		} else {		
		// ********** order paid for, saved to web database and posted to sage... complete!	
			session.shopper.orderID = ResultPlaceSalesOrder; //session.shopper.WebOrderRef;
			session.shopper.orderStatus="complete";	
		}	
	 } 
	 
 	  //*********** CASE 3:  PayGW OK, No SageGW
	 else if (APPLICATION.payGWenabled AND NOT APPLICATION.sageGWenabled) {
			
		// write application log
		application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 3:  PayGW OK, No SageGW");
			
			// ********  oops could not post to SAGE, set status to processing and inform shopper!
			session.shopper.orderStatus="NotPostedToSage";
			orderStatusDesc = "This order was not posted into Sage because the Sage Gateway is currently disabled";	
	 }	
	 
	 //*********** CASE 4:  PayGW OK, SageGW OK
	 else if (APPLICATION.payGWenabled AND APPLICATION.sageGWenabled) {	
		
		// write application log
		application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 4:  PayGW OK, SageGW OK");
		
		// payment not required, post order to sage
		ResultPlaceSalesOrder = VARIABLES.sageGW.PlaceSalesOrder(ARGUMENTS.FORM);
		
		if (NOT ResultPlaceSalesOrder) {
			// ********  oops could not post to SAGE, set status to processing and inform shopper!
			session.shopper.orderStatus="NotPostedToSage";
			orderStatusDesc = "The Sage Gateway would not accept the Order. Additional information avaible by logging into the website";	
		} else {		
		// ********** order paid for, saved to web database and posted to sage... complete!	
			session.shopper.orderID = ResultPlaceSalesOrder;
			session.shopper.orderStatus="complete";	
		}	
	 }
} 

// *********** CREDIT NOT AUTHORISED
else {
	
	 //*********** CASE 5:  No PayGW, No SageGW 
	 if (NOT APPLICATION.payGWenabled AND NOT APPLICATION.sageGWenabled) {
		 	
		 	// write application log
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 5:  No PayGW, No SageGW");
		 	
		 	// ********  Order saved in web db, but payment could not be processed 
			session.shopper.orderStatus="NotPostedToSage";
			orderStatusDesc = "Payment Gateway Disabled and Sage Gateway Disabled. Please login to collect order and payment details";	
	 } 
	 
	 //*********** CASE 6:  No PayGW, SageGW OK
	 else if (NOT APPLICATION.payGWenabled AND APPLICATION.sageGWenabled) {	
	 		
	 		// write application log
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 6:  No PayGW, SageGW OK");
	 		
	 		//********* Post order to Sage
			ResultPlaceSalesOrder = VARIABLES.sageGW.PlaceSalesOrder(ARGUMENTS.FORM);
			
			if (NOT ResultPlaceSalesOrder) {
				// ********  Order Post Failed: Data
				session.shopper.orderStatus="NotPostedToSage";
				orderStatusDesc = "The Sage Gateway would not accept the Order. Additional information available by logging into the website";	
			} else {		
			// ********** Order Post Successful, Order Complete	
				session.shopper.orderID = ResultPlaceSalesOrder;
				session.shopper.orderStatus="paymentIncomplete";
				orderStatusDesc = "Payment Gateway Disabled. Please login to collect and process payment details before processing order";		
			}				
	 } 
	 
	 //*********** CASE 7:  PayGW OK, No SageGW 
	 else if (APPLICATION.payGWenabled AND NOT APPLICATION.sageGWenabled) {
	 	
	 	
	 	// write application log
		application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 7:  PayGW OK, No SageGW");
	 	
	 	// **********process payment
		Payment_Status = VARIABLES.payGW.debit(ARGUMENTS.FORM);
		
		if (NOT Payment_Status) {
			// ************* payment declined
			session.shopper.orderStatus="paymentDeclined";
		} else {
						// ********  oops could not post to SAGE, set status to processing and inform shopper!
			session.shopper.orderStatus="NotPostedToSage";
			orderStatusDesc = "This order was not posted into Sage because the Sage Gateway is currently disabled";			
		}
	 }	// END CASE 7
	 
	 //*********** CASE 8:  PayGW OK, SageGW  OK
	 else if (APPLICATION.payGWenabled AND APPLICATION.sageGWenabled) {	
	 
	 	// write application log
		application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6) & " - CASE 8:  PayGW OK, SageGW  OK");
	 	
	 	
	 	// **********process payment
	 	Payment_Status = VARIABLES.payGW.debit(ARGUMENTS.FORM);
		
		// ************* payment declined
		if (NOT Payment_Status) {
					session.shopper.orderStatus="paymentDeclined";
		} 
		// ************* payment accepted
		else {
			//********* Post order to Sage
			ResultPlaceSalesOrder = VARIABLES.sageGW.PlaceSalesOrder(ARGUMENTS.FORM);
			
			if (NOT ResultPlaceSalesOrder) {
				// ********  Order Post Failed: Data
				session.shopper.orderStatus="NotPostedToSage";
				orderStatusDesc = "The Sage Gateway would not accept the Order. Additional information available by logging into the website";	
			} else {		
			// ********** Order Post Successful, Order Complete	
				session.shopper.orderID = ResultPlaceSalesOrder;
				session.shopper.orderStatus="complete";	
			}	
		} //endif payment status
	 }// END CASE 8
	
} //END Payment and Sage Processing
	

/***********************************************
				DATABASE - SAVE ORDER HANDLER
 ** status handler not required, because if order can't be saved 
a database exception will occur - handler by application.cfc
**********************************************/

//save to database via shop Data Object
FORM.orderStatusDesc = orderStatusDesc;
VARIABLES.shopDO.saveOrder(ARGUMENTS.FORM);


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
	
	
	VARIABLES.eml.sendEmail(SESSION.Auth.EmailAddress
									,ccEmailAddress,
									"Your Sales Order Confirmation - Order No: #Msg.OrderID#", 
									msg,
									 "/views/emlSalesOrderConfirmation.cfm");
	
	
	
	Msg.shoppingList = session.basketContents.getStaffFormattedList(true);
	// Send Copy to Sales staff
	VARIABLES.eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress")
									,ccEmailAddress,
									"New Sales Order Notification: Order No: #Msg.OrderID#", 
									msg,
									 "/views/emlSalesOrderStaffNotification.cfm");
	
}
	
</cfscript>
</cffunction>

</cfcomponent>