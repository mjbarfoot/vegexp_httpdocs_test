<cfscript>
/* create the departements view object
request.departments.view=createObject("component", "cfc.departments.view");

//add the css file
if (isdefined("request.css")) {
	request.css=request.css & "," & session.shop.skin.path & "checkout.css";
} else {
	request.css= "checkout.css";
}

session.shopper.OrderID="1234";

content = request.departments.view.orderComplete();	
*/

content=cgi.server_name;
</cfscript>

<cfinclude template="/views/default.cfm">