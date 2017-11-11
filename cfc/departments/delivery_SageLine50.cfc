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

<cffunction name="viewFC" output="false" returntype="boolean" access="public">
<cfargument name="postcode" required="true" type="string" />

<cfscript>
/* 	check postcode against postcode list 
if there is a defined delivery profile then check the profile to see whether 
delivery of frozen and chilled products is available to that area */
	
var viewFC=false;
var firstPostCodeSegment="";
var deliveryProfileID = 0;

// 6 char postcode
if (len(ARGUMENTS.Postcode) eq 6) {
	firstPostCodeSegment = left(ARGUMENTS.Postcode, 3);	
}
// 7 char postcode
else if (len(ARGUMENTS.Postcode eq 7)) {
	firstPostCodeSegment = left(ARGUMENTS.Postcode, 4);	
} 



// get the delivery profile, returns 0/false if none found
deliveryProfileID = dep_do.getDelProfileID(firstPostCodeSegment);

/*if one is found check against the deliveryprofile to see 
if frozen/chilled goods are delivered to postal area */
if (deliveryProfileID) {
viewFC = dep_do.isAllowedViewFC(deliveryProfileID);	
}

return viewFC;
</cfscript>
</cffunction>

<cffunction name="getDelDay" output="false" returntype="string" access="public">
<cfscript>
var deliveryDay = calcDelDay();
if (deliveryDay neq "") {
	/* check if delivery day is more than a week from current day
	i.e. if ordering on a friday after 3pm then delivery day is Monday (Week) not coming monday
	*/
	if (DateDiff("d", LSdateformat(now()), LSdateformat(deliveryDay)) gte 7) {
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
<cfscript>
var deliveryDay = calcDelDay();
if (deliveryDay neq "") {
return deliveryDay;
} else {
return "";	
}
</cfscript>
</cffunction>


<cffunction name="calcDelDay" output="true" returntype="any" access="private">
<cfscript>
var OrderDateTime = now();
var OrderDay = LSDateformat(now(), "dd/mm/yyyy");
var OrderByTime = 0;
var OrderStartTime = 0;
var delDay = "";
var qrySlots = "";

// has a delivery profile ID been assigned to the shoppers session?
if (NOT isdefined("session.Auth.DelProfileID")) {
session.Auth.DelProfileID=dep_do.getDelProfileID();
}

// get the order by time for their delivery profile;
orderByTime = dep_do.getOrdByTime();

/* if current time is after the "Order By Time" then Order by time is 
  set to the next day but first hours of business operation */
if (DateDiff("n", LStimeformat(now()), LStimeformat(orderByTime)) lte 0) {

// get the time order taking begins at the next day
OrderStartTime = dep_do.getOrderStartTime();	

// create the new order time by combining the date of the next day and the time order taking begins


// do date add
OrderDayPlusOne = DateFormat(Dateadd("d", 1, OrderDay),"dd/mm/yyyy");
OrderDateTime = CreateDateTime((Right(OrderDayPlusOne, 4)),  Mid(OrderDayPlusOne,4, 2), left(OrderDayPlusOne, 2), 
							Hour(OrderStartTime), Minute(OrderStartTime), 0);


	//check the new order day is valid, order days are mon-fri 
	if (dayOfWeek(OrderDateTime) eq 1) {
		// if it is a sunday add 1 day to make it monday
		OrderDateTime=DateAdd("d", 1, OrderDateTime);
	} else if (dayOfWeek(OrderDateTime) eq 7) {
		// it it is a Saturday add 2 days
		OrderDateTime=DateAdd("d", 2, OrderDateTime);
	}

}


// iterate through days from the next day from orderdate until a matched delivery day is found
for (i=1; i lte 7; i=i+1) {
	
	//if a matched one is found return day of week as a string
	if (isValidDelDay(DateAdd("d", i, OrderDateTime))) {
	delDay = DateAdd("d", i, OrderDateTime);
	break;
	}

}

if (delDay neq "") {
	return delDay;
} else {
	return "";
}
</cfscript>

</cffunction>

<cffunction name="isValidDelDay" access="private" returntype="boolean">
<cfargument name="delDay" required="true" type="date" />

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
<cfscript>
delivery	=createObject("component", "cfc.departments.delivery");
deliveryDate = delivery.getDelDate();
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