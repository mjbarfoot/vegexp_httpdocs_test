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

<cfscript>
delivery=createObject("component", "cfc.departments.delivery");
dep_do	= createObject("component", "cfc.departments.do");
deliveryday = delivery.getDelDay(AccountID="WEBTEST");
deliverydate = delivery.getDelDate(AccountID="WEBTEST");
orderByTime = dep_do.getOrdByTime();
OrderDay = LSDateformat(now(), "dd/mm/yyyy");
//TheTimeNow = CreateDateTime(2006,10,27,16,18,0);
TheTimeNow=now();
OrderDateTime = TheTimeNow;

if (DateDiff("n", LStimeformat(TheTimeNow), LStimeformat(orderByTime)) lte 0) {

// get the time order taking begins at the next day
OrderStartTime = dep_do.getOrderStartTime();	

// create the new order time by combining the date of the next day and the time order taking begins
OrderDateTime = CreateDateTime((Right(OrderDay, 4)),  Mid(OrderDay,4, 2), left(OrderDay, 2)+1, 
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
	//if (isValidDelDay(DateAdd("d", i, OrderDateTime))) {
	if (isValidDelDay(DateAdd("d", i, OrderDateTime))) {
	delDay = DateAdd("d", i, OrderDateTime);
	//writeOutput("loop broke at " & i & "day of week = " & dayofWeek(DateAdd("d", i, OrderDateTime)));
	break;
	}

}

</cfscript>
<cfoutput>
<!--- <p>Delivery day: #deliveryday#</p>
<p>Delivery date: #deliveryDate#</p> --->
<p>The time now: #timeformat(TheTimeNow, "HH:MM:SS")# </p>
<p>Order by time: #timeformat(orderByTime, "HH:MM:SS")#</p>
<p>Difference in minutes between now and order by time: #DateDiff("n", LStimeformat(TheTimeNow), LStimeformat(orderByTime))#</p> 
<p>OrderDateTime: #LSdateformat(OrderDateTime, "dd/mm/yyyy")# #LStimeformat(OrderDateTime, "HH:MM:SS")#</p>
<p>New Delivery Day: #LSDateFormat(delDay, "dd/mm/yyyy")#</p>
<p>Difference in days between now and delivery date: #DateDiff("d", LSdateformat(now()), LSdateformat(delDay))#</p>
<p>isValidDelDay(DateAdd("d", 1, OrderDateTime)): #isValidDelDay(DateAdd("d", 1, OrderDateTime))# #DayOfWeek(DateAdd("d", 1, OrderDateTime))#</p>
</cfoutput>

<cfquery name="qryGetDelSlots"  datasource="#APPLICATION.dsn#">
	SELECT DelSlotDate, DelSlotTime
	FROM tblDelSlot
	WHERE DelProfileID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.Auth.DelProfileID#" /> 
</cfquery>

<cfoutput query="qryGetDelSlots">
delslotdate: #delslotdate# delslottime #delslottime# <br />	
</cfoutput>

