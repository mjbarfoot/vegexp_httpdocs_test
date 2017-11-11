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


<cffunction name="saveRemote" access="remote" returntype="void" output="true">
    <cfargument name="delbuilding" type="string" required="false" default="" />
    <cfargument name="delline1" type="string" required="false" default="" />
    <cfargument name="delline2" type="string" required="false" default="" />
    <cfargument name="delline3" type="string" required="false" default="" />
    <cfargument name="deltown" type="string" required="false" default="" />
    <cfargument name="delcounty" type="string" required="false" default="" />
    <cfargument name="delpostcode" type="string" required="false" default="" />
    <cfargument name="delnotes" type="string" required="false" default="" />
    <cfargument name="customerPO" type="string" required="false" default="" />

    <cfset var FORM = structnew() />
    <cfset FORM.delbuilding = ARGUMENTS.delbuilding />
    <cfset FORM.delline1 = ARGUMENTS.delline1 />
    <cfset FORM.delline2 = ARGUMENTS.delline2 />
    <cfset FORM.delline3 = ARGUMENTS.delline3 />
    <cfset FORM.deltown = ARGUMENTS.deltown />
    <cfset FORM.delcounty = ARGUMENTS.delcounty />
    <cfset FORM.delpostcode = ARGUMENTS.delpostcode />
    <cfset FORM.delnotes = ARGUMENTS.delnotes />
    <cfset FORM.customerPO = ARGUMENTS.customerPO />


   <cfscript>
       init();
       save(FORM);
   </cfscript>

    <cfcontent type="text/xml" />
    <cfoutput>
        <taconite-root xml:space="preserve">
        <taconite-replace  contextNodeID="checkoutContainer" parseInBrowser="true">
            <div id="checkoutContainer">
                <script type="text/javascript">
                  location.reload();
              </script>
            </div>
    </taconite-replace>
    </taconite-root>
    </cfoutput>

</cffunction>
 
 <!--- *** SAVE METHOD *** --->
<cffunction name="save" access="public" returntype="void" output="false">
<cfargument name="FORM" type="struct" required="true" />


    <cfscript>    
        var ResultPlaceSalesOrder="";
        var Payment_Status=false;
        var OrderPostedToSage_Status=false;
        var orderStatusDesc="";
        var ccEmailAddress = "";

        // write application log
        application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Processing Web Order - " & right(session.shopper.orderID, 6));

        if (APPLICATION.AppMode eq "development") {
            sleep(5000);
                //ResultPlaceSalesOrder = "123456" & randRange(1,9) & randRange(1,9) & randRange(1,9) & randRange(1,9);
            session.shopper.WebOrderRef =  "123456" & randRange(1,9) & randRange(1,9) & randRange(1,9) & randRange(1,9);
            session.shopper.orderID = session.shopper.WebOrderRef
            ResultPlaceSalesOrder = false;
            session.shopper.orderStatus="NotPostedToSage";
        } else {
            ResultPlaceSalesOrder=VARIABLES.sageGW.PlaceSalesOrder(ARGUMENTS.FORM);

        }

		
		if (NOT ResultPlaceSalesOrder) {
			// ********  oops could not post to SAGE, set status to processing and inform shopper!
			session.shopper.orderStatus="NotPostedToSage";
			orderStatusDesc = "The Sage Gateway would not accept the Order. Additional information available by logging into the website";	
			session.shopper.orderID=session.shopper.WebOrderRef;

        
		} else {		
		// ********** order paid for, saved to web database and posted to sage... complete!	
			session.shopper.orderID = ResultPlaceSalesOrder; //session.shopper.WebOrderRef;
			session.shopper.orderStatus="complete";	
		}    
        
        
        /***********************************************
        DATABASE - SAVE ORDER HANDLER - status handler not required, because if order can't be saved 
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
        notifyCustomer(session.shopper.orderStatus);

       
    
    </cfscript>
</cffunction>    
    


<cffunction name="notifyCustomer" access="private" returntype="void" output="false">
<cfargument name="orderStatus" type="string" required="true" hint="the status of the order" />

<cfscript>
var fromEmailAddress = APPLICATION.var_DO.getVar("WebSalesEmailAddress");
var salesEmailAddress = APPLICATION.var_DO.getVar("salesEmailAddress");


/***********************************************
  Development hooks
**********************************************/
if (APPLICATION.AppMode eq "development") {
    salesEmailAddress = "matt.barfoot@clearview-webmedia.co.uk";
    SESSION.auth.emailAddress = "matt.barfoot@clearview-webmedia.co.uk";
}


/***********************************************
				EMAIL - Email Customer & copy to Sales
Email customer in all instances apart from paymentIncomplete
where the customer will check payment details and resubmit
**********************************************/

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
	


    if (ARGUMENTS.orderStatus eq "complete") {
        VARIABLES.eml.sendEmail(SESSION.Auth.EmailAddress,
                                fromEmailAddress,
                                "Your Sales Order Confirmation - Order No: #Msg.OrderID#",
                                msg,
                                "/views/emlSalesOrderConfirmation.cfm");



        Msg.shoppingList = session.basketContents.getStaffFormattedList(true);
        // Send Copy to Sales staff
        VARIABLES.eml.sendEmail(salesEmailAddress,
                                fromEmailAddress,
                                "Sage Web Sales Order Confirmation: Order No: #Msg.OrderID#",
                                msg,
                                "/views/emlSalesOrderStaffNotification.cfm");
    } else {
            Msg.title = "Sales Order #Msg.OrderID# Delayed Order Confirmation";
            VARIABLES.eml.sendEmail(SESSION.Auth.EmailAddress,
            fromEmailAddress,
            "Your Sales Order Confirmation and Delay Notification - Order No: #Msg.OrderID#",
            msg,
            "/views/emlSalesOrderErrorConfirmation.cfm");


            Msg.title = "Error Adding Sales Order #Msg.OrderID# to Sage - Immediate Action Required";
            Msg.shoppingList = session.basketContents.getStaffFormattedList(true);
// Send Copy to Sales staff
            VARIABLES.eml.sendEmail(salesEmailAddress,
            fromEmailAddress,
            "Error adding Web Sales Order to Sage - Immediate Action required - Order No: #Msg.OrderID#",
            msg,
            "/views/emlSalesOrderStaffErrorNotification.cfm");

    }
</cfscript>


</cffunction>

    
<!--- *** SAVE METHOD *** --->
<cffunction name="save_new" access="public" returntype="void" output="false">
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
    

</cfcomponent>