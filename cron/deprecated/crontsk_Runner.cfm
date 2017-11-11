<!--- 
Time Intervals
# m: Months
# y: Days of year (same as d)
# d: Days
# w: Weekdays (same as ww)
# ww: Weeks
# h: Hours
# n: Minutes
# s: Seconds  --->

<!--- *** Method: Get Cron Jobs *** --->
<cffunction name="getCronJobs" returnType="query">
	<cfquery name = "qryGetJobs" dataSource = "#APPLICATION.dsn#">
	SELECT CronJobID, CronJobName, CronJobDesc, CronJobFile, CronStatus, Frequency, FreqUnit, LastRun, NextRun
	FROM tblCronSchedule
	ORDER BY LastRun Desc
	</cfquery>

<cfreturn qryGetJobs />
</cffunction>

<!--- *** Method: Update Cron Job *** --->
<cffunction name="setNextRunDate" returnType="boolean">
<cfargument name="CronJobID" 		type="numeric" required="true" />	
<cfargument name="NextRunDate"     type="date" required="true" />	

	<cfquery name = "qryUpdateCronJob" dataSource = "#APPLICATION.dsn#">
	UPDATE tblCronSchedule
	SET NEXTRUN = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ARGUMENTS.NextRunDate#">
	WHERE CronJobID = #ARGUMENTS.CronJobID#
	</cfquery>

<cfreturn true />
</cffunction>

<!--- *** Method: Set Job Active *** --->
<cffunction name="setJobRunning" returnType="boolean">
<cfargument name="CronJobID" 		type="numeric" required="true" />	

	<cfquery name = "qryUpdateCronJob" dataSource = "#APPLICATION.dsn#">
	UPDATE tblCronSchedule
	SET LASTRUN  = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
	CronStatus = 'Running'
	WHERE CronJobID = #ARGUMENTS.CronJobID#
	</cfquery>

<cfreturn true />
</cffunction>

<!--- *** Method: Set Job Complete *** --->
<cffunction name="setJobComplete" returnType="boolean">
<cfargument name="CronJobID" 		type="numeric" required="true" />	

	<cfquery name = "qryUpdateCronJob" dataSource = "#APPLICATION.dsn#">
	UPDATE tblCronSchedule
	SET	CronStatus = 'Complete'
	WHERE CronJobID = #ARGUMENTS.CronJobID#
	</cfquery>

<cfreturn true />
</cffunction>

<!--- *** Method: Run Cron Job --->
<cffunction name="runCronJob" returnType="void" output="true">
<cfargument name="CronJobID" 		type="numeric" required="true" />	
<cfargument name="CronJobName" 		type="string"  required="true" />
<cfargument name="CronJobFile" 		type="string"  required="true" />


<cfinclude template="/cron/#CronJobFile#">
<!--- <cfoutput>Running job: #ARGUMENTS.CronJobID# #ARGUMENTS.CronJobName# #ARGUMENTS.CronJobFile# <br /></cfoutput> --->

<cfscript>
setJobComplete(ARGUMENTS.CronJobID);
</cfscript>

</cffunction>


<cfscript>
if (not isdefined("application.crontsklog")) {
application.crontsklog		    = createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "crontsklog");	
}

application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Cron Task Runner Started");
</cfscript>

<cfset qryGetJobs = getCronJobs() />

<cfloop query="qryGetJobs">
<cfscript>

// run the job if a iterative job and lastrun and nextrun are default values
if 		  (Frequency neq 0 AND lastRun eq "1900-01-01 00:00:00.0" AND nextRun eq "1900-01-01 00:00:00.0") {
				
				setJobRunning(CronJobID); // set Job Status to running and update last run to now.
				
				setNextRunDate(CronJobID, DateAdd(FreqUnit, Frequency, now()));	
				
				//log start
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Running: #CronJobID#, #CronJobName#, #CronJobFile#");
				
				//run job
				runCronJob(CronJobID,CronJobName,CronJobFile);		
				
				//log end
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Finished: #CronJobID#, #CronJobName#, #CronJobFile#");
}  else 

// run the job if lastRunDate + interval  < current time and next run date is default value
if (Frequency neq 0  AND (DateAdd(FreqUnit, Frequency, LastRun) lte now()) AND  nextRun eq "1900-01-01 00:00:00.0") {
				
				setJobRunning(CronJobID); // set Job Status to running and update last run to now.
				
				setNextRunDate(CronJobID, DateAdd(FreqUnit, Frequency, now()));	
				
				//log start
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Running: #CronJobID#, #CronJobName#, #CronJobFile#");
				
				//run job
				runCronJob(CronJobID,CronJobName,CronJobFile);		
				
				//log end
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Finished: #CronJobID#, #CronJobName#, #CronJobFile#");
				
}  else 

//update the nextRunDate if the lastRunDate + interval > current time  and nextrun is default value
if (Frequency neq 0 AND DateAdd(FreqUnit, Frequency, LastRun) gte now() AND  nextRun eq "1900-01-01 00:00:00.0") {
				
				setNextRunDate(CronJobID, DateAdd(FreqUnit, Frequency, LastRun));	

} else 

// run the job if the nextRunDate < current date/time
if (Frequency neq 0 AND NextRun lte now()) {
				
				setJobRunning(CronJobID); // set Job Status to running and update last run to now.
				
				setNextRunDate(CronJobID, DateAdd(FreqUnit, Frequency, now()));	
				
				//log start
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Running: #CronJobID#, #CronJobName#, #CronJobFile#");
				
				//run job
				runCronJob(CronJobID,CronJobName,CronJobFile);		
				
				//log end
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Finished: #CronJobID#, #CronJobName#, #CronJobFile#");
				
} else 

// run the job if it's a one off job (frequency=0) and status != 'Complete'
if (Frequency eq 0 AND NextRun lte now() AND CronStatus neq "Complete") {
				
				//need function to set job active!
				setJobRunning(CronJobID); // set Job Status to running and update last run to now.
							
				//log start
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Running: #CronJobID#, #CronJobName#, #CronJobFile#");
				
				//run job
				runCronJob(CronJobID,CronJobName,CronJobFile);		
				
				//log end
				application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Finished: #CronJobID#, #CronJobName#, #CronJobFile#");
				
				//set run date to zero
				setNextRunDate(CronJobID, 0);
}


</cfscript>	
</cfloop>

<cfscript>
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Cron Task Runner Finished");
</cfscript>

