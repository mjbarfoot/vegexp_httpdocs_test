<cfprocessingdirective  suppressWhiteSpace = "Yes">

<!--- *** Crontask script *** --->
<cfscript>
// compare list of customers from Sage with those in database
// if there ones in database which don't exist in Sage, delete them

//intialise the Sage Connector
VARIABLES.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();

//cron task script  
customerXML = VARIABLES.sageWSGW.postRequest(generateSoap(), "GetCustomerList");

removeOldCustomers(customerXML);

</cfscript>


<cffunction name="generateSOAP" output="false" returntype="string" access="private">
<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
 <GetCustomerList xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfxml>


<cfreturn toString(soap)>
</cffunction>
<!--- *** Method: Get a list of account codes, names from Sage AccountsWS *** --->
<!--- <cffunction name="getListOfCustomers" output="true" returntype="string">

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

<cfoutput>Task: getListOfCustomers Execution time: #tickinterval# seconds <br /></cfoutput>

<cfreturn trim(cfhttp.filecontent) />

</cffunction> --->



<!--- *** Method: If customer does not exist, delete from database *** --->
<cffunction name="removeOldCustomers" returntype="void" output="true" access="private">
<cfargument name="customerXML" type="string" required="true" />

<!--- initialise xml and timing variables --->
<cfset var MyXmlDoc=xmlParse(ARGUMENTS.customerXML) /> 
<cfset var xmlCustomers = MyXmlDoc.xmlRoot.xmlChildren[2].GetCustomerListResponse.GetCustomerListResult.xmlChildren />
<cfset var tickBegin=getTickCount() />
<cfset var tickEnd=0 />
<cfset var tickinterval=0 />
<cfset var deleteCount=0 />
<cfset var foundAccountID=false />

<!---truncate tblSageUserPad --->
<cfquery name="truncateSageUserPad" datasource="#APPLICATION.dsn#">
delete from tblSageUserPad
</cfquery>

<!--- add accountids to database table - tblSageUserPad --->
<cfloop from="1" to="#arraylen(xmlCustomers)#" index="x">
	<!---do not add unprocessed web registrations--->
	<cfif findNoCase("web0", xmlCustomers[x].AccountCode.xmlText) eq 0>
		<cfquery name="qryInsertSageCustomerIDs" datasource="#APPLICATION.dsn#">
		INSERT INTO tblSageUserPad
		(SageAccountID) Values ('#xmlCustomers[x].AccountCode.xmlText#')
		</cfquery>
	</cfif>
</cfloop>	

<!--- count the number of customers in db now --->
<cfquery name="qryCountCustomers" datasource="#APPLICATION.dsn#">
SELECT count(AccountID) as "PrevCount" from tblUsers
</cfquery>

<!--- remove any that don't exist in sageUserPad --->
<cfquery name="qryRemoveOldCustomerIDs" datasource="#APPLICATION.dsn#">
DELETE FROM tblUsers
where AccountID NOT IN (select SageAccountID from tblSageUserPad)
</cfquery>

<!--- count them again to see how many we deleted --->
<cfquery name="qryCountCustomers2" datasource="#APPLICATION.dsn#">
SELECT count(AccountID) as "NewCount" from tblUsers
</cfquery>

<!--- set deleteCount var  --->
<!--- <cfset deleteCount = val(qryCountCustomers['"PrevCount"'][1]) - val(qryCountCustomers2['"NewCount"'][1]) /> --->

<cfset deleteCount = val(qryCountCustomers.PrevCount) - val(qryCountCustomers2.NewCount) />

<!--- stop the stop watch! --->
<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Task: removeOldCustomers Customers  Removed: #deleteCount#  Execution time: #tickinterval# seconds noSageCustomers: #arraylen(xmlCustomers)# <br /></cfoutput>

</cffunction>


</cfprocessingdirective>