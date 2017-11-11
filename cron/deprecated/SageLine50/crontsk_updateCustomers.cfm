<!--- 
	cron task: crontsk_updateCustomers.cfm
	File: /cron/crontsk_updateCustomers.cfm
	Description: retrieves a list of new accounts and iterates through them  updating the database
	Author: Matt Barfoot
	Date: 07/08/2006
	Revisions:
	--->

<!---initalise variables--->	
<cfparam name="URL.startrow" default=1>
<cfparam name="URL.endrow" default=10>
<cfset  tickBegin=getTickCount()>
<cfset  tickEnd=0>
<cfset  session.tickinterval=0>

<cfif URL.startrow eq 1>
<cfset temp=StructDelete(SESSION, "UserIDList") />
</cfif>

<!---create User list that needs updating if not already created--->
<cfif not isdefined("SESSION.UserIDList")>
<cfquery name="SESSION.UserIDList" datasource="#APPLICATION.dsn#">
SELECT UserID, AccountID 
FROM tblUsers
WHERE newCustomer = 1
</cfquery>
</cfif>

<!---if startrow is greater than the number of rows in the query, job done! Abort! --->
<cfif URL.startrow gt SESSION.UserIDList.recordcount>
<cfoutput>Cron Job finished... all customers up to date</cfoutput>

<cfabort />
<!--- if endrow is greater than the number of records, set it the recordcount  --->
<cfelseif URL.endrow gt SESSION.UserIDList.recordcount>
	<cfset URL.endrow = SESSION.UserIDList.recordcount />

<!---iterating through 10 records, output which records are being updated--->
<cfelseif URL.startrow neq 1>
<cfoutput>
Last records updated in #session.tickinterval# seconds <br />
Currently updating records #URL.startrow# to #URL.endrow#.
</cfoutput>
</cfif>


<cfscript>
//intialise the Sage Connector
VARIABLES.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();
</cfscript>

<cfloop query="SESSION.UserIDList" startrow="#URL.startrow#" endrow="#URL.endrow#">
<cfscript>
// get the customers data from the Sage Database
//customerXML=getCustomerData(AccountID);

//cron task script  
customerXML = VARIABLES.sageWSGW.postRequest(generateSoap(AccountID), "GetCustomerData");

//parse the data
MyXmlDoc=xmlParse(customerXML);

//strip off unwanted elements
CustomerData=MyXmlDoc.xmlRoot.xmlChildren[2].GetCustomerDataResponse.GetCustomerDataResult;


//set firstname and lastname by splitting string at position of space. 
posSpace = Findnocase(" ", CustomerData.TradeContact.xmlText); 
if (posSpace) {
	firstName = mid(CustomerData.TradeContact.xmlText,1,posSpace); 
	lastname  = mid(CustomerData.TradeContact.xmlText, (posSpace+1), len(CustomerData.TradeContact.xmlText));	
} else {
	firstname = "";
	lastname  =	CustomerData.TradeContact.xmlText;
}
</cfscript>


<cfquery name="qryUpdateCustomer" datasource="#APPLICATION.dsn#">
UPDATE tblUsers
SET 
AccountOnHold = #CustomerData.AccountOnHold.xmlText#,
firstname = '#firstName#',
lastName = '#lastname#',
company = '#xmlformat(ReplaceNoCase(CustomerData.AccountName.xmlText, "ONHOLD", "", "ALL"))#',
discountRate = '#CustomerData.discountRate.xmlText#',
telnum = '#CustomerData.TelephoneNumber.xmlText#',
emailAddress = '#CustomerData.EMailAddress.xmlText#',
contactPref = 'phone',
<!--- accPass = '#CustomerData.Password.xmlText#', --->
building = '#CustomerData.AccountAddressLine1.xmlText#',
postcode = '#CustomerData.AccountAddressPostCode.xmlText#',
viewFC = 1,
line1 = '#CustomerData.AccountAddressLine2.xmlText#',
town = '#CustomerData.AccountAddressLine3.xmlText#',
county = '#CustomerData.AccountAddressLine4.xmlText#',
delRoute = '#CustomerData.ContactName.xmlText#',
delline1 = '#CustomerData.DeliveryAddressLine1.xmlText#',
delline2 = '#CustomerData.DeliveryAddressLine2.xmlText#',
delline3 = '#CustomerData.DeliveryAddressLine3.xmlText#',
delline4 = '#CustomerData.DeliveryAddressLine4.xmlText#',
delPostcode = '#CustomerData.DeliveryAddressPostCode.xmlText#',
delContactName = '#CustomerData.DeliveryContactName.xmlText#',
delFaxNumber = '#CustomerData.DeliveryFaxNumber.xmlText#',
delName = '#CustomerData.DeliveryName.xmlText#',
delTelephoneNumber = '#CustomerData.DeliveryTelephoneNumber.xmlText#',
AllowEmailPost = 1,
AllowPhoneCalls = 1,
creditAccount = 1,
creditAccountAuth = 1,
AuthLevel = 1,
LastUpdatedDate = <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,<!--- #DateFormat(now(), "dd/mm/yyyy")#, --->
LastUpdatedTime = <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,<!--- #TimeFormat(now(), "H:MM TT")#, --->
LastUpdatedBy = 'CronTask',
newCustomer = 0
WHERE UserID = #UserID#
</cfquery>
</cfloop>


<cfscript>
tickEnd=getTickCount();
session.tickinterval=(tickend-tickbegin)/1000;
URL.startrow=URL.startrow+10;
URL.endRow=URL.endrow+10;
</cfscript>

<cfoutput>
<script language="javascript">
location.href="crontsk_updateCustomers.cfm?startrow=#URL.startrow#&endrow=#URL.endrow#";
</script>
</cfoutput>

<cffunction name="generateSOAP" output="false" returntype="string" access="private">
<cfargument name="accountCode" type="string" required="true" />
<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCustomerData xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <accountCode><cfoutput>#XMLFormat(ARGUMENTS.accountCode)#</cfoutput></accountCode>
    </GetCustomerData>
  </soap:Body>
</soap:Envelope>
</cfxml>


<cfreturn toString(soap)>
</cffunction>

<!--- <cffunction name="getCustomerData" output="true" returntype="string">
<cfargument name="AccountCode" type="string" required="true" />

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCustomerData xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <accountCode>#XMLFormat(trim(ARGUMENTS.AccountCode))#</accountCode>
    </GetCustomerData>
  </soap:Body>
</soap:Envelope>
</cfxml>

<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx"
			method="post">
	<cfhttpparam type="header" name="SOAPAction" value="http://www.aspidistra.com/WebService/AccountsIntegration/GetCustomerData">
	<cfhttpparam name="xml" value="#toString(soap)#" type="xml" />
</cfhttp>

<cfreturn trim(cfhttp.filecontent) />

</cffunction> --->