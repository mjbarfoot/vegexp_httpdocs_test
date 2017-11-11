<cfscript>
//create log files
if (not isdefined("application.crontsklog")) { 
application.crontsklog 			= createObject("component", "cfc.logwriter.logwriter").init("D:\JRun4\servers\vegexp\cfusion-war\logs\", "crontsklog");
}

//write crontask started
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Crontask: Add Org/GlutenFree/Vegan Classification: started" );
</cfscript>

<cfset tickBegin=getTickCount()>
 
<cfquery name="qryGetProducts" datasource="#APPLICATION.dsn#">
select StockID, Description from tblProducts
</cfquery>

<cfset updatecount=0>
<cfset errorCount=0>
<cfset found_in_desc=false>

<cfloop query="qryGetProducts">

<cfif Find("(ORG)", description)>
	<cfset found_in_desc=true>
	<cfset query_col="Organic">
<cfelseif Find("(Vegan)",description)>
	<cfset found_in_desc=true>
	<cfset query_col="Vegan">
<cfelseif Find("(Gluten Free)",description)>
	<cfset found_in_desc=true>
	<cfset query_col="GlutenFree">
</cfif>

<cfif found_in_desc>
	<cftry>

		<cfquery name="qryUpdateProductClassification" datasource="#APPLICATION.dsn#">
		update tblProducts
		set #query_col# = 1
		where StockID = #StockID#
		</cfquery>

		<cfset updatecount=updatecount+1>

	<cfcatch type="database">
		<cfset errorCount=errorCount+1>
			<cfscript>
			//write errors
			application.crontsklog.write("Update Failed: Database error while updating tblProducts column #query_col# for stockid: #stockid# to 1");
			</cfscript>
	</cfcatch>
	</cftry>

	<cfset found_in_desc=false>
</cfif>

</cfloop>

<cfset tickEnd=getTickCount()>
<cfset tickinterval=decimalformat((tickend-tickbegin)/1000)>

<cfscript>
//write errors
application.crontsklog.write("Crontask ended. Updated #updatecount# records but could not update #errorCount# recods in : #tickinterval# seconds");
</cfscript>



