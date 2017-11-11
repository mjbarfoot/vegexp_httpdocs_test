<cffunction name="setOrderTimeToTomorrowsOpenTime" output="false" returntype="date" access="private" hint="returns a new order time set to start of next business day">

<cfscript>
	
	// get the time order taking begins at the next day
	//var OrderStartTime = CreateDateTime(Year(now()), Month(now()), Day(now()), 9, 0, 0);	
	var OrderDateTime = CreateDateTime(Year(now()), Month(now()), (Day(now())+1), 9, 0, 0);
	/*
	// create the new order time by combining the date of the next day and the time order taking begins
	// do date add
	OrderDayPlusOne = DateFormat(Dateadd("d", 1, OrderDay),"dd/mm/yyyy");
	OrderDateTime = CreateDateTime((Right(OrderDayPlusOne, 4)),  Mid(OrderDayPlusOne,4, 2), left(OrderDayPlusOne, 2), 
								Hour(OrderStartTime), Minute(OrderStartTime), 0);
	
	*/

	//check the new order day is valid, order days are mon-fri 
	if (dayOfWeek(OrderDateTime) eq 1) {
		// if it is a sunday add 1 day to make it monday
		OrderDateTime=DateAdd("d", 1, OrderDateTime);
	} else if (dayOfWeek(OrderDateTime) eq 7) {
		// it it is a Saturday add 2 days
		OrderDateTime=DateAdd("d", 2, OrderDateTime);
	}
	
	return OrderDateTime;

</cfscript>
</cffunction>

<cffunction name="isLaterThanLastOrderTime" output="false" returntype="boolean" access="private" hint="checks if the current order time is later than the set cut off time">
<cfargument name="OrderDateTime" type="date" required="true" hint="the current ordertime as datetime">

<cfscript>
var cutOffTime = CreateDateTime(Year(now()), Month(now()), Day(now()), 15, 30, 0);
if (DateDiff("n", now(), cutOffTime) lte 0) {
	return true;
} else {
	return false;
}

</cfscript>
</cffunction>

<cfscript>
delivery=createObject("component", "cfc.departments.delivery");
dep_do	= createObject("component", "cfc.departments.do");

writeOutput("delivery.getDelDate(AccountID='LONBUS'):" & delivery.getDelDate(AccountID="LONBUS"));
writeOutput("<br/>");


/* deliveryday = delivery.getDelDate(AccountID="LONBUS");
deliverydrop = delivery.getDelDrop(AccountID="LONBUS");
writeOutput("delivery day is:" & deliveryday & " delivery drop is: " & deliverydrop);

CustomerDeliveryDays = dep_do.getDeliveryDays(AccountID="LONBUS");
writeOutput("<br/> delivery days:" & CustomerDeliveryDays);
*/


OrderDateTime = now();
FirstPossibleDeliveryDay = "";
CustomerDeliveryDays = "";

/* if current time is after the "Order By Time" then Order by time is 
	  set to the next day but first hours of business operation */
if (isLaterThanLastOrderTime(OrderDateTime)) {
	OrderDateTime = setOrderTimeToTomorrowsOpenTime();
}

// first possible date for delivery is always next day
FirstPossibleDeliveryDay = Dateadd("d", 1, OrderDateTime);

// get a list of day numbers 1=Sun,7=Sat
CustomerDeliveryDays = dep_do.getDeliveryDays(AccountID="LONBUS");

/* check to see if 0 (everyday) is in the list of days for the customer
if it isn't then vans delivery on specific days for customers
for 7 iterations add a day each time to the first possible deliver day until
we have a match, once we find one break the loop and we now have the first possible delivery date */
if (FindNoCase("0",CustomerDeliveryDays) eq 0) {
	for (i=0; i lte 6; i=i+1) {
					
					// subtract 1 because cf dayofweek starts Sunday (1), VegExp starts Monday (1), but CF is (2)
					if (FindNoCase((DayOfWeek(FirstPossibleDeliveryDay)-1),CustomerDeliveryDays) neq 0)	{		
							break;
					} 
					
					FirstPossibleDeliveryDay = Dateadd("d", 1, FirstPossibleDeliveryDay);
					
	}
} else {
	// check for saturday (7) or Sunday (1), if so move to monday	
	//ack = DayOfWeek(FirstPossibleDeliveryDay);
	if (DayOfWeek(FirstPossibleDeliveryDay) eq 7) {
		FirstPossibleDeliveryDay = Dateadd("d", 2, FirstPossibleDeliveryDay);
	} else if (DayOfWeek(FirstPossibleDeliveryDay) eq 1) {
		FirstPossibleDeliveryDay = Dateadd("d", 1, FirstPossibleDeliveryDay);
	}	

	
}

writeOutput("FirstPossibleDeliveryDay:" & FirstPossibleDeliveryDay);

</cfscript>
