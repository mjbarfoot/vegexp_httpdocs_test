<cfif IsDefined("form.frmSaveData") eq True>
   <cfgridupdate grid = "CronJobGrid" dataSource = "#APPLICATION.dsn#" Keyonly="yes"
      tableName = "tblCronSchedule">
</cfif>
<!--- Query the database to fill up the grid. --->
<cfquery name = "qryGetJobs" dataSource = "#APPLICATION.dsn#">
SELECT CronJobID, CronJobName, CronJobDesc, CronJobFile, CronStatus, Frequency, FreqUnit, LastRun, NextRun
FROM tblCronSchedule
ORDER BY LastRun Desc, CronJobID asc
</cfquery>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
 <head>
  <title>Vegetarian Express Prototype website - running on <cfoutput>#cgi.SERVER_NAME# #application.Appmode# logging to: #application.logpath#</cfoutput></title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<style>
* {font-family: Arial; margin:0; padding:0; font-size: 1em;}	
div#content {margin-left: Auto; margin-right: Auto; width: 700px;}
input {font-size: 0.9em;}
</style>
</head>
<body> 
<div id="content">
<h1>Cron Task Scheduler</h1>

<!--- cfgrid must be inside a cfform tag. --->
<cfform>
   <cfgrid name = "CronJobGrid" format="flash"
      insert = "Yes" delete = "Yes" font = "Arial" fontSize="10" rowHeaders = "No" 
	   maxRows="6" width="900" pictureBar="yes"
	  colHeaderBold = "Yes"  selectMode = "EDIT"
   	  insertButton = "Insert a Row" deleteButton = "Delete selected row"
      query = "qryGetJobs">
    <cfgridcolumn name = "CronJobID" header = "ID" width="20" select="no">
	<cfgridcolumn name = "CronJobName" header = "Name" width="100" select="yes">
	<cfgridcolumn name = "CronJobDesc" header = "Description" width="200" select="yes">
	<cfgridcolumn name = "CronJobFile" header = "Cron Job" width="150" select="yes">
	<cfgridcolumn name = "CronStatus" header = "Status"   width="75" select="no">  
	<cfgridcolumn name = "Frequency" header = "Frequency" width="75" select="yes">  
	<cfgridcolumn name = "FreqUnit" header = "Unit" width="50" select="yes">
	<cfgridcolumn name = "LastRun" header = "Last Run" width="100"  select="no">      
	<cfgridcolumn name = "NextRun" header = "Next Run" width="100" select="no">      
</cfgrid>
<cfinput label="Save Data" type="submit" name="frmSaveData" value="Save Data" id="frmSaveData"  />
</cfform>
</div>
</body>
</html>