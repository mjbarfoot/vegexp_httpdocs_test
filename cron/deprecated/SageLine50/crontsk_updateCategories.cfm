<cfprocessingdirective  suppressWhiteSpace = "Yes">
<cfscript>
/***************************************************************************
Title: updateCategories
Purpose: Retrieve a list of product categories from Sage Line 50 and upload them
Author: Matt Barfoot (c) Clearview Webmedia Limited 2007
Date: 03/01/2007
Description
1) Sends HTTP post XML to SageWS asking for category list
2) Loops over categories and formats them in Capitilised lowercase words 
   and removes bracketed category numbers
3) Checks custom filters for category ranges to be disabled
4) Removes existing categories and iserts the new ones
History:
*****************************************************************************/

//create log files
//if (not isdefined("application.crontsklog")) { 
//application.crontsklog 			= createObject("component", "cfc.logwriter.logwriter").init("D:\JRun4\servers\vegexpMySQL\cfusion-war\logs\", "crontsklog");
//}

//write crontask started
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateCategories Started *****");


//intialise the Sage Connector
VARIABLES.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();


//initalise the deparement do and get a list of filtered (out) categories
VARIABLES.dep_do = createObject("component", "cfc.departments.do");
VARIABLES.qFilteredCats = VARIABLES.dep_do.getFilterCats("category");

tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;

//cron task script
sageData = VARIABLES.sageWSGW.postRequest(generateSoap(), "GetStockCategoryList");
//writeOutput(sageData);

updateCategories(sageData); //update the categories

tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateCategories complete - Execution time: #tickInterval# s *****");

writeOutput("Job Done!");
</cfscript>

<cffunction name="updateCategories" output="true" returntype="void" access="private">
<cfargument name="soapResponse" type="string" />

<!--- initialise xml and timing variables --->

<cfset var xml="" /> 
<cfset var xmlCats="" />
<cfset var tickBegin=getTickCount() />
<cfset var tickEnd=0 />
<cfset var tickinterval=0 />
<cfset var enabledCategoryCount=0 />
<cfset var disabledCategoryCount=0 />

<cftry>
	<cfset xml=xmlParse(arguments.soapResponse) /> 
<cfcatch type="any">
	<cfoutput>#arguments.soapResponse#</cfoutput>
	<cfoutput>Programmed Abort</cfoutput>
	<cfabort />
</cfcatch>
</cftry>

<cfset xmlCats=xml.xmlRoot.xmlChildren[2].GetStockCategoryListResponse.GetStockCategoryListResult.StockCategory>

<!--- delete existing categories --->
<cfquery name="qRemoveCategories" datasource="#APPLICATION.dsn#">
truncate tblCategory
</cfquery>


<!--- iterate through categories --->
<cfloop from="1" to="#arraylen(xmlCats)#" index="x">
<!--- check if the catgory number is in a valid range and determine department by checking the first digit --->	
<cfif isValidCategory(xmlCats[x].Number.xmlText)>
	<!--- insert the ENABLED category into the database --->
	<cfquery name="qInsertCategory" datasource="#APPLICATION.dsn#">
	INSERT INTO tblCategory
	(DepartmentID, Department, CategoryID, Category, Disabled)
	VALUES (
	<!--- is it a chilled product --->
	<cfif left(xmlCats[x].Number.xmlText, 1) eq 1>
	1, 'Frozen', #xmlCats[x].Number.xmlText#, <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(xmlCats[x].Name.xmlText)#">, 0
	<!--- is it a frozen product --->
	<cfelseif left(xmlCats[x].Number.xmlText, 1) eq 2>
	2, 'Chilled', #xmlCats[x].Number.xmlText#, <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(xmlCats[x].Name.xmlText)#">, 0
	<!--- is it a ambient product --->
	<cfelseif left(xmlCats[x].Number.xmlText, 1) gte 6>
	3, 'Ambient', #xmlCats[x].Number.xmlText#, <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(xmlCats[x].Name.xmlText)#">, 0
	</cfif>
	)	
	</cfquery>
	
	<cfset enabledCategoryCount=enabledCategoryCount + 1/>
<!--- product is within the disabled/filtered category range --->		
<cfelse>

	<!--- insert the category anyway marking it as diabled --->
	<cfquery name="qInsertCategory" datasource="#APPLICATION.dsn#">
	INSERT INTO tblCategory
	(DepartmentID, Department, CategoryID, Category, Disabled)
	VALUES (0, 'Disabled', #xmlCats[x].Number.xmlText#, <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(xmlCats[x].Name.xmlText)#">, 1)	
	</cfquery>

	<cfset disabledCategoryCount=disabledCategoryCount + 1/>
</cfif>
</cfloop>

<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Added #enabledCategoryCount# Enabled Categories and #disabledCategoryCount# Disabled (#tickInterval# s)");
</cfscript>

</cffunction>

<cffunction name="generateSOAP" output="false" returntype="string" access="private">
<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetStockCategoryList xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfxml>

<cfreturn toString(soap)>
</cffunction>

<cffunction name="isValidCategory" output="false" returntype="boolean" access="private">
<cfargument name="stockcategorynumber" type="string" required="true" />

<cfset var isValid=true>

<cfloop query="VARIABLES.qFilteredCats">
	<!--- if it is in the filter range it can be ignore and is not a valid category --->
	<cfif ARGUMENTS.stockcategorynumber gte Start AND ARGUMENTS.stockcategorynumber lte End>
		<cfset isValid = false />
		<cfbreak />
	</cfif>
</cfloop>

<cfreturn isValid />

</cffunction>

<cffunction name="categoryFormat" output="false" returntype="string" access="private">
<cfargument name="str" required="true" type="string" />
<cfscript>
var replacementStr="";
var newStr = "";
//iterate through string using a whitespace as the delimiter for the list
for (x=1; x lte listlen(ARGUMENTS.str, " "); x=x+1) {
 	
 	// capilise first letter and lower case rest of the word
 	if (len(listgetat(ARGUMENTS.str, x, " ")) gt 1) {
 	replacementStr = ucase(left(listgetat(ARGUMENTS.str, x, " "), 1)) & lcase(mid(listgetat(ARGUMENTS.str, x, " "), 2, len(listgetat(ARGUMENTS.str, x, " "))));
 	}
	
	// replace the updated string within the word 
 	if (x eq 1) {newStr = replacementStr;} else {newStr = newStr & " " & replacementStr;}
}

//lose the category number on the end

newStr = rereplace(newStr, "\([0-9]{1,}\)", "");

return newStr;
</cfscript>

</cffunction>

</cfprocessingdirective>