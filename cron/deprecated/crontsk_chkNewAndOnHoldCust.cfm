<cfprocessingdirective  suppressWhiteSpace = "Yes">

<!--- *** Crontask script *** --->
<cfscript>
// get and upload new customers into database
customerUpload(getNewCustomers());
//writeOutput(HTMLEditFormat(getNewCustomers()));
</cfscript>

<!--- *** Method: Get a list of account codes, names from Sage AccountsWS *** --->
<cffunction name="getNewCustomers" output="true" returntype="string">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soap:Body>
   <GetCustomerList xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfxml>


<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx"
			method="post">
	<cfhttpparam type="header" name="SOAPAction" value="http://www.aspidistra.com/WebService/AccountsIntegration/GetCustomerList">
	<cfhttpparam name="xml" value="#toString(soap)#" type="xml" />
</cfhttp>

<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>SageWS response time: #tickinterval# seconds <br /></cfoutput>

<cfreturn trim(cfhttp.filecontent) />

</cffunction>


<!--- *** Method: If customer does not exist, insert into database *** --->
<cffunction name="customerUpload" returntype="void" output="true" acess="private">
<cfargument name="customerXML" type="string" required="true" />

<!--- initialise xml and timing variables --->
<cfset var MyXmlDoc=xmlParse(ARGUMENTS.customerXML)> 
<cfset var xmlCustomers = MyXmlDoc.xmlRoot.xmlChildren[2].GetCustomerListResponse.GetCustomerListResult.xmlChildren>
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>
<cfset var tickinterval=0>
<cfset var updateCounter=0>
<cfset var onHoldCounter=0 />

<cftransaction>	
<cfloop from="1" to="#arraylen(xmlCustomers)#" index="x">

<cfquery name="qryCheckCustomerExists" datasource="#APPLICATION.dsn#">
SELECT AccountID from tblUsers
where AccountID = '#xmlCustomers[x].AccountCode.xmlText#'
</cfquery>

<cfif qryCheckCustomerExists.recordcount eq 0>
	<cfquery name="qryInsProducts" datasource="#APPLICATION.dsn#"> 
	INSERT INTO tblUsers
	(AccountID, Company, CreateDate, CreateTime, LastUpdatedDate, LastUpdatedTime, LastUpdatedBy, newCustomer)
	Values ('#xmlCustomers[x].AccountCode.xmlText#', 
  			'#xmlCustomers[x].AccountName.xmlText#',
			<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,<!--- #DateFormat(now(), "dd/mm/yyyy")# --->
		    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,<!--- #DateFormat(now(), "dd/mm/yyyy")# --->
		    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,<!--- #DateFormat(now(), "dd/mm/yyyy")# --->
		    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,<!--- #DateFormat(now(), "dd/mm/yyyy")# --->
		    'CronTask',
		    1);
	</cfquery>
	<cfset updateCounter=incrementVal(updateCounter) />
<cfelse>
	<!--- check if the account has been put on hold --->
	<cfif FindNoCase("ONHOLD", xmlCustomers[x].AccountName.xmlText) NEQ 0>
		<cfquery name="qryUpdProducts" datasource="#APPLICATION.dsn#"> 
			UPDATE tblUsers
			SET AccountOnHold = <cfqueryparam cfsqltype="cf_sql_smallint" value="1">
			WHERE AccountID = '#xmlCustomers[x].AccountCode.xmlText#'
		</cfquery>
		<cfset onHoldCounter=onHoldCounter+1 />
	</cfif>
</cfif>


</cfloop>
 
</cftransaction>

<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Found #arraylen(xmlCustomers)# records in Sage<br />New customers added: #updateCounter#<br />
Customers put on hold: #onHoldCounter# <br />
XML parsed, checked and uploaded into database: #tickinterval# seconds</cfoutput>
</cffunction>


</cfprocessingdirective>