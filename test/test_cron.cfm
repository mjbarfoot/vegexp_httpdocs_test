<!--- <cfmail to="matt@barfoot.f2s.com" from="crontest@barfoot.f2s.com"  subject="This was sent at #timeformat(now(), 'H:MM:SS')#"  type="text">
This is a test
</cfmail> --->
<cfoutput>Test cron run! #cgi.SERVER_NAME#</cfoutput>
<cfscript>WriteOutput(APPLICATION.var_DO.getVar("salesEmailAddress"));</cfscript>

<!--- <cfmail to="mjbarfoot@gmail.com" from="sales@vegexp.co.uk"  subject="This was sent at #timeformat(now(), 'H:MM:SS')#"  type="text">
This is a test
</cfmail>  --->

<cfscript>
//get the email dispatcher
VARIABLES.eml	=createObject("component", "cfc.shop.dispatchMsg");

	Msg = structnew();
	Msg.OrderID = "Ack1234"
	
	Msg.title = "This is a test Message from orders.vegetarianexpress.co.uk";
	
	//get the readonly shopping list 
	Msg.DeliveryDate = now() //VARIABLES.delivery.getDelDate(SESSION.Auth.AccountID);
	//get the delivery notes
	Msg.deliveryNotes = "";//VARIABLES.delivery.getDeliveryNotes();
	//get the shopping list
	Msg.shoppingList = ""; //session.basketContents.showCheckOut(true);
	
	// Send Customer Confirmation email

	ccEmailAddress = "websales@vegexp.co.uk";
	//ccEmailAddress = "";
	
	
	//VARIABLES.eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress") &  ";matt.barfoot@clearview-webmedia.co.uk",ccEmailAddress,
	VARIABLES.eml.sendEmail("matt.barfoot@clearview-webmedia.co.uk",ccEmailAddress,
									"Your Sales Order Test Email", 
									msg,
									 "/views/emlSalesOrderConfirmation.cfm");
									 
</cfscript>									 