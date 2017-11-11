<!--- 
	Filename: /cfc/departments/delivery.cfc 
	Created by:  Matt Barfoot on 11/05/2006 Clearview Webmedia Limited
	Purpose:  retrieves and sets delivery information
--->
<cfcomponent name="delivery" displayname="delivery"  output="false" hint="retrieves and sets delivery information">

<!--- / Object declarations / --->
<cfscript>
dep_do	= createObject("component", "cfc.departments.do");
util 	= createObject("component", "cfc.shop.util");
</cfscript>


<cffunction name="init" output="false" access="public">

<cfreturn this> 

</cffunction>

<cffunction name="getMinimumOrderValue" output="false" returntype="numeric" access="public" hint="returns the minimum order value">
<cfargument name="AccountID" type="string" required="true" hint="the AccountID of the user" />
    <cfscript>
        var ret = 40;
        if (getDelVan(ARGUMENTS.AccountID) eq "90") {
            ret = 60;
        }
        return ret;
    </cfscript>
</cffunction>


<cffunction name="isAbleToViewFC" output="false" returntype="boolean" access="public" hint="determines whether a user is able to view frozen/chilled goods">
<cfargument name="AccountID" type="string" required="false" default="" hint="the AccountID of the user" />
<cfargument name="PostCode" type="string" required="false" default="" hint="postcode for the users address">

<cfset var vans=0/>

<cfif ARGUMENTS.AccountID eq "" AND Arguments.Postcode eq "">
	<cfreturn false />
<cfelseif ARGUMENTS.AccountID neq "" AND Arguments.Postcode eq "">	
	
	<cfset vans=dep_do.getVan(AccountID)/>
	
	<!--- VAN 90 and empty drop code means courier/can only deliver dry goods --->
	<cfif vans eq "90">
		<cfreturn false />
	<cfelse>
		<cfreturn true />
	</cfif>		

<cfelseif ARGUMENTS.AccountID eq "" and ARGUMENTS.Postcode neq "">
	
	<cfset vans=dep_do.getVansByPostcode() />
	
	<!--- VAN no. 9 and empty drop code means courier/can only deliver dry goods --->	
	<cfif vans eq "90">
		<cfreturn false />
	<cfelse>
		<cfreturn true />
	</cfif>	
	
	
<cfelse>
	<cfreturn false/>
</cfif>

</cffunction>

<cffunction name="getAddress" output="false" returntype="struct" access="public">
<cfscript>
var myDelAddress = structnew();
var myQryDelAddress = dep_do.getDelAddress();
//populate address struct
if (myQryDelAddress.recordcount eq 1) {
	myDelAddress.building 	= myQryDelAddress.building;
	myDelAddress.line1	 	= myQryDelAddress.line1;
	myDelAddress.line2 		= myQryDelAddress.line2;
	myDelAddress.line3 		= myQryDelAddress.line3;
	myDelAddress.town 		= myQryDelAddress.town;
	myDelAddress.county 		= myQryDelAddress.county;
	myDelAddress.postcode 	= myQryDelAddress.postcode;
} else {
	myDelAddress.building = "No address found";	
}

return myDelAddress;
</cfscript>
</cffunction>

<cffunction name="getDeliveryNotes" output="false" returntype="string" access="public">
<cfscript>
var myQryDelNotes = dep_do.getDelNotes();
var myDelNotesString="";
if (myQryDelNotes.recordcount eq 1) {
	myDelNotesString = myQryDelNotes.delline1 & chr(13) &
		myQryDelNotes.delline2 & chr(13) &
		myQryDelNotes.delline3 & chr(13) &
		myQryDelNotes.delline4 & chr(13) &
		myQryDelNotes.delpostcode;
						
	return myDelNotesString;
} else {

return "";	

}

</cfscript>
</cffunction>

<cffunction name="getDeliveryContact"  output="false" returntype="string" access="public">
<cfreturn dep_do.getDeliveryContact() />
</cffunction>

<cffunction name="viewFC" output="false" returntype="string" access="public">
<cfargument name="postcode" required="true" type="string" />

<cfscript>
/* 	check postcode against postcode list 
if there is a defined delivery profile then check the profile to see whether 
delivery of frozen and chilled products is available to that area */
	
var viewFC=false;
var firstPostCodeSegment="";
var deliveryProfileID = 0;
var daysCanDeliver = "";

// 6 char postcode
if (len(ARGUMENTS.Postcode) eq 6) {
	firstPostCodeSegment = left(ucase(ARGUMENTS.Postcode), 3);	
}
// 7 char postcode
else if (len(ARGUMENTS.Postcode eq 7)) {
	firstPostCodeSegment = left(ucase(ARGUMENTS.Postcode), 4);	
} 

daysCanDeliver = dep_do.getDeliveryDaysByPostcode(firstPostCodeSegment);


return daysCanDeliver;
</cfscript>
</cffunction>

<cffunction name="getDelDay" output="false" returntype="string" access="public">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />	
<cfscript>
var deliveryDay = calcDelDay(ARGUMENTS.AccountID);

if (deliveryDay neq "") {
	/* check if delivery day is more than a week from current day
	i.e. if it is monday and ordering on a friday after 3pm then delivery day is Monday (Week) not coming monday
	*/
	if (DateDiff("d", now(), deliveryDay) gte 7) {
		return DayOfWeekAsString(DayOfWeek(deliveryDay)) & "(week)";
	} else {
		return DayOfWeekAsString(DayOfWeek(deliveryDay));
	}

} else {
return "";	
}
</cfscript>
</cffunction>

<cffunction name="getDelDate" output="false" returntype="any" access="public">
	<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />	
<cfscript>
var deliveryDay = calcDelDay(ARGUMENTS.AccountID);
if (deliveryDay neq "") {
return deliveryDay;
} else {
return "";	
}
</cfscript>
</cffunction>

<cffunction name="getDelDrop" output="false" returntype="any" access="public">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />
<cfreturn dep_do.getDelDrop(ARGUMENTS.AccountID) />
</cffunction>

<cffunction name="getDelVan" output="false" returntype="any" access="public">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />
<cfreturn dep_do.getDelVan(ARGUMENTS.AccountID) />
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

<cffunction name="setOrderTimeToTomorrowsOpenTime" output="false" returntype="date" access="private" hint="returns a new order time set to start of next business day">

<cfscript>
	var currentDate = now()+1;
    var OrderDateTime = CreateDateTime(Year(currentDate), Month(currentDate), Day(currentDate), 9, 0, 0);

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


<cffunction name="calcDelDay" output="true" returntype="any" access="private">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />		
<cfscript>
var OrderDateTime = now();
var FirstPossibleDeliveryDay = "";
var CustomerDeliveryDays = "";

/* if current time is after the "Order By Time" then Order by time is 
	  set to the next day but first hours of business operation */
if (isLaterThanLastOrderTime(OrderDateTime)) {
	OrderDateTime = setOrderTimeToTomorrowsOpenTime();
}

// first possible date for delivery is always next day
FirstPossibleDeliveryDay = Dateadd("d", 1, OrderDateTime);

// get a list of day numbers 1=Sun,7=Sat
CustomerDeliveryDays = dep_do.getDeliveryDays(ARGUMENTS.accountid);

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
	} else if (DayOfWeek(FirstPossibleDeliveryDay) eq 2) {
        FirstPossibleDeliveryDay = Dateadd("d", 1, FirstPossibleDeliveryDay);
    }

	
}

return FirstPossibleDeliveryDay;

</cfscript>

</cffunction>

<cffunction name="isValidDelDay" access="private" returntype="boolean">
<cfargument name="delDay" required="true" type="date" />
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />	

<cfset var qrySlots = dep_do.getDelSlots()>
<cfset var matchedDay = false>

<!--- iterate through the delivery slots to check there is actually a delivery scheduled that day  --->
<cfloop query="qrySlots">
	<cfif DayOfWeek(delDay) eq DelSlotDate>
		<cfset matchedDay=true>
		<cfbreak />
	</cfif>
</cfloop>

<cfreturn matchedDay>
</cffunction>

<cffunction name="isValidNextDay" access="public" returntype="boolean" output="true">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />			
<cfscript>
deliveryDate = getDelDate(ARGUMENTS.AccountID);
theDateToday = CreateDate(Year(Now()), Month(Now()), day(Now()));

// test vars
//theDateToday = CreateDate(Year(Now()), Month(Now()), "10");
//deliveryDate = CreateDate(Year(Now()), Month(Now()), "13");

// check if it not a friday, subtract one from deldate to see if it is today

if (dayofWeek(theDateToday) neq 6) {
	if (dayofYear(dateadd("y", "-1", deliveryDate)) eq dayofYear(theDateToday)) {
	return true;
	} else {
	return false;	
	}
	
} // if it is a friday, check with Monday is the next delivery day 
  else {
	if (dayofYear(dateadd("y", "-3", deliveryDate)) eq dayofYear(theDateToday)) {
	return true;
	} else {
	return false;	
	}	
}
</cfscript>
</cffunction>

</cfcomponent>