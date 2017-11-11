<cfscript>
delivery	= createObject("component", "cfc.departments.delivery");
delday = delivery.getDelDay();
WriteOutput("session.Auth.DelProfileID: " & session.Auth.DelProfileID & 
			"Delivery day: " & delday);
</cfscript>