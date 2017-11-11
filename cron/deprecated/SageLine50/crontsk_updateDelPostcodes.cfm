<cfscript>
//write crontask started
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateDelPostcode Started *****");

// start the stop watch
tickBegin=getTickCount(); tickEnd=0; tickinterval=0;

// fetch the customer records
routes = qGetRoutes();
badRoutes = "";
newRoutes = "";
LorryNo = ""; DayNo = "";

// iterate through them
for (i = 1; i lte ArrayLen(routes["postcode"]); i=i+1) {

	// check we have a route, ignore all others
	if (find("/", routes["delRoute"][i]) AND len(routes["delRoute"][i] lte 8) and routes["postcode"][i] neq "") {
		// find which days deliveries go to the customer
		
		
		// is there than one route
		// build a list of all route options for available postcode
		if (find(".", routes["delRoute"][i])) {
			
			//iterate over segements of route code using the "." as a list seperator
			for (x=1; x lte listLen(routes["delRoute"][i], "."); x=x+1) {
				// get the route segment
				RouteSegment = listGetAt(routes["delRoute"][i], x, ".");		

				//add each lorry / day combination to the array row
				LorryNo = getLorryNo(RouteSegment);
				DayNo = getDayNo(RouteSegment);
		
				// in the next columns add the lorry/day
				if (setLorryDay(getPostCodeSegment(routes["postcode"][i]), "#LorryNo#/#DayNo#")) {
			 			newRoutes = listAppend(newRoutes, "#routes['postcode'][i]# : #LorryNo#/#DayNo#");
				}

				//reset lorry and dayno
				LorryNo = ""; DayNo = "";
			}	
						
		} else {
			LorryNo = getLorryNo(routes["delRoute"][i]);
			DayNo = getDayNo(routes["delRoute"][i]);
			
			if (setLorryDay(getPostCodeSegment(routes["postcode"][i]), "#LorryNo#/#DayNo#")) {
			 newRoutes = listAppend(newRoutes, "#routes['postcode'][i]# : #LorryNo#/#DayNo#");
			}
			
			LorryNo = ""; DayNo = ""; 	
		}				 
				 	
	} else {
		badRoutes = listAppend(badRoutes, "#routes['AccountID'][i]# : #routes['postcode'][i]# : #routes['delRoute'][i]#");
	}
}



// check if they're postcode is in the postcodes table



// after finished looping through customer records, add/update postcode route options


//output to screen the bad routes and routesArray
displayNewRoutes(newRoutes);
displayBadRoutes(badRoutes);

tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateDelPostcode Ended - Duration: #tickinterval# s *****");
</cfscript>


<cffunction name="displayNewRoutes" access="private" returntype="string">
<cfargument name="nR" type="string" required="true">

<cfscript>
WriteOutput("Number of new Routes inserted: #listlen(nR)# <br />");
for (i=1; i lte listlen(ARGUMENTS.nR); i=i+1) {
writeOutput(listGetAt(ARGUMENTS.nR, i) & "<br />");	
} 
</cfscript>

</cffunction>

<cffunction name="setLorryDay" access="private" returntype="boolean">
<cfargument name="postcode" type="string" required="true" />
<cfargument name="lorryday" type="string" required="true" />

<cfset var lorry = left(ARGUMENTS.lorryday, find("/", ARGUMENTS.lorryday)-1) />
<cfset var day = mid(ARGUMENTS.lorryday, find("/", ARGUMENTS.lorryday)+1, 1) />
<cfset var recordAdded=true />

<cftry>
<cfquery name="q" datasource="#APPLICATION.dsn#">
SELECT 1 FROM tblDelLorryDay
WHERE Postcode = '#ARGUMENTS.postcode#'
AND Lorry =  #lorry#
AND Day = #day#
</cfquery>
<cfcatch type="database">
	<cfset recordAdded = false />
</cfcatch>
</cftry>

<!--- if there is already a record don't need to add a new one --->
<cfif q.recordcount neq 0>
	<cfset recordAdded = false />
	<cfreturn recordAdded />

<cfelse>
	<cftry>
		<cfquery name="qI" datasource="#APPLICATION.dsn#">
		INSERT INTO tblDelLorryDay
		(Postcode, Lorry, Day)
		VALUES ('#Postcode#', #Lorry#, #Day#)
		</cfquery>
	
		<cfreturn true />
	<cfcatch type="database">
		<cfreturn false />
	</cfcatch>
	</cftry>
</cfif>

</cffunction>

<cffunction name="displayBadRoutes" access="private" returntype="string">
<cfargument name="bR" type="string" required="true">

<cfscript>
WriteOutput("These records did not have valid route information (#listlen(ARGUMENTS.bR)#): <br/ >");
for (i=1; i lte listlen(ARGUMENTS.bR); i=i+1) {
writeOutput(listGetAt(ARGUMENTS.bR, i) & "<br />");	
}
</cfscript>

</cffunction>

<cffunction name="getPostCodeSegment" access="private" returntype="string">
<cfargument name="pSeg" type="string" required="true">

<cfscript>
var posSpace = find(" ", pSeg);
if (find(" ", pSeg) eq 0) { 
	return pSeg;
} else {
	return left(pSeg, posSpace-1); 	
}
</cfscript>

</cffunction>

<cffunction name="getLorryNo" access="private" returntype="string">
<cfargument name="rSeg" type="string" required="true">

<cfscript>
return left(ARGUMENTS.rSeg, IIF(find("/", ARGUMENTS.rSeg), find("/", ARGUMENTS.rSeg)-1, len(ARGUMENTS.rSeg))); 
</cfscript>

</cffunction>

<cffunction name="getDayNo" access="private" returntype="string">
<cfargument name="rSeg" type="string" required="true">

<cfscript>
//return mid(ARGUMENTS.rSeg, find("/", ARGUMENTS.rSeg), IIF(find(".", ARGUMENTS.rSeg), find(".", ARGUMENTS.rSeg), (len(ARGUMENTS.rSeg)-(find("/", ARGUMENTS.rSeg)-1))));
return mid(ARGUMENTS.rSeg, find("/", ARGUMENTS.rSeg)+1, 1);
</cfscript>

</cffunction>

<cffunction name="qGetRoutes" access="private" returntype="query">

<cfquery name="q" datasource="#APPLICATION.dsn#">
SELECT USERID, ACCOUNTID, DELROUTE, POSTCODE
FROM tblUsers
</cfquery>

<cfreturn q />

</cffunction>