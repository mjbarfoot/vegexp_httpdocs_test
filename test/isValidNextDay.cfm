<cffunction name="isValidNextDay" access="public" returntype="boolean">
<cfscript>
delivery	=createObject("component", "cfc.departments.delivery");
//deliveryDate = delivery.getDelDate();
//theDateToday = CreateDate(Year(Now()), Month(Now()), day(now()));

theDateToday = CreateDate(Year(Now()), Month(Now()), "10");
deliveryDate = CreateDate(Year(Now()), Month(Now()), "13");

if (dayofWeek(theDateToday) neq 6) {
	if (dayofYear(dateadd("y", "-1", deliveryDate)) eq dayofYear(theDateToday)) {
	return true;
	}
} else {
	if (dayofYear(dateadd("y", "-3", deliveryDate)) eq dayofYear(theDateToday)) {
	return true;
	} else {
	return false;	
	}	
	
}
</cfscript>
</cffunction>
<cfscript>
delivery	=createObject("component", "cfc.departments.delivery");
writeoutput(isValidNextDay());
writeOutput(theDateToday & " " & deliveryDate);
</cfscript> 