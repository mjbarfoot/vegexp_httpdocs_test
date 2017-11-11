<cfif IsDefined("form.frmSaveData") eq True>
   <cfgridupdate grid = "GlobalVarsGrid" dataSource = "#APPLICATION.dsn#" Keyonly="no"
      tableName = "tblGlobalVars">
</cfif>
<!--- Query the database to fill up the grid. --->
<cfquery name = "qryGetVars" dataSource = "#APPLICATION.dsn#">
SELECT varID, varName, varValue, SERVER_NAME
FROM tblGlobalVars
ORDER by SERVER_NAME ASC, varName asc
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
<h1>Global Vars</h1>

<!--- cfgrid must be inside a cfform tag. --->
<cfform>
   <cfgrid name = "GlobalVarsGrid" format="flash"
      insert = "Yes" delete = "Yes" font = "Arial" fontSize="10" rowHeaders = "No" 
	   maxRows="6" width="600" pictureBar="yes"
	  colHeaderBold = "Yes"  selectMode = "EDIT"
   	  insertButton = "Insert a Row" deleteButton = "Delete selected row"
      query = "qryGetVars">
    <cfgridcolumn name = "varID" header = "ID" width="20">
	<cfgridcolumn name = "varName" header = "varName" width="150">
	<cfgridcolumn name = "varValue" header = "varValue" width="250">
	<cfgridcolumn name = "SERVER_NAME" header = "SERVER_NAME" width="150">   
</cfgrid>
<cfinput label="Save Data" type="submit" name="frmSaveData" value="Save Data" id="frmSaveData"  />
</cfform>
</div>
</body>
</html>