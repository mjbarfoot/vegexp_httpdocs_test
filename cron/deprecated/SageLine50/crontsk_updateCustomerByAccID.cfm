<!--- 
	cron task: crontsk_updateCustomerByAccID.cfm
	File: /cron/crontsk_updateCustomerByAccID.cfm
	Description: retrieves a list of new accounts and iterates through them  updating the database
	Author: Matt Barfoot
	Date: 24/05/2007
	Revisions:
	--->

<!---initalise variables--->	
<cfparam name="URL.AccountID" default="" />

<cfif isdefined("FORM.frmSubmit")>
	<cfset URL.AccountID=FORM.AccountID />
</cfif>	

<cfif URL.AccountID eq "">
	<cfif isdefined("FORM.AccountID") AND FORM.AccountID eq ""><cfoutput>Sorry! No Sage Acount code specified.</cfoutput></cfif>
	<cfoutput>#getAccountUpdateForm()#</cfoutput>
	<cfabort />
</cfif>


<cfset  tickBegin=getTickCount()>
<cfset  tickEnd=0>
<cfset  session.tickinterval=0>


<cfscript>
//write crontask started
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateCustomerByAccID Started *****");

//intialise the Sage Connector
VARIABLES.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();	
	
// get the customers data from the Sage Database
//customerXML=getCustomerData(AccountID);
//cron task script


customerXML = VARIABLES.sageWSGW.postRequest(generateSoap(), "GetCustomerData");

//parse the data
MyXmlDoc=xmlParse(customerXML);

//strip off unwanted elements
CustomerData=MyXmlDoc.xmlRoot.xmlChildren[2].GetCustomerDataResponse.GetCustomerDataResult;


//set firstname and lastname by splitting string at position of space. 
posSpace = Findnocase(" ", CustomerData.ContactName.xmlText); 
if (posSpace) {
	firstName = mid(CustomerData.ContactName.xmlText,1,posSpace); 
	lastname  = mid(CustomerData.ContactName.xmlText, (posSpace+1), len(CustomerData.ContactName.xmlText));	
} else {
	firstname = "";
	lastname  =	CustomerData.ContactName.xmlText;
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
building = '#CustomerData.AccountAddressLine1.xmlText#',
postcode = '#CustomerData.AccountAddressPostCode.xmlText#',
viewFC = 1,
line1 = '#CustomerData.AccountAddressLine2.xmlText#',
town = '#CustomerData.AccountAddressLine3.xmlText#',
county = '#CustomerData.AccountAddressLine4.xmlText#',
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
WHERE AccountID = '#Trim(URL.AccountID)#'
</cfquery>


<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateCustomerByAccID complete - Execution time: #tickInterval# s *****");
WriteOutput("#trim(URL.AccountID)# Account has been updated. Task executed in #tickInterval# s");
WriteOutput(getAccountUpdateForm());
</cfscript>


<cffunction name="generateSOAP" output="false" returntype="string" access="private">
<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCustomerData xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <accountCode><cfoutput>#XMLFormat(trim(URL.AccountID))#</cfoutput></accountCode>
    </GetCustomerData>
  </soap:Body>
</soap:Envelope>
</cfxml>

<cfreturn toString(soap)>
</cffunction>


<cffunction name="getAccountUpdateForm" output="false" returntype="string" access="private">
<cfset var strMyForm=""/>
<cfxml variable="myForm">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title>Account Update Form</title>
<style>
<![CDATA[
* {font-family: "Trebuchet MS", Arial, Sans-Serif;}
body {padding: 2em 1em 1em 2em; margin: 0; border: 0; }
]]>
</style>
</head>
 <body> 
	<h1>Update Sage Account Details</h1>
	<form name="myform" method="post" action="<cfoutput>#cgi.script_name#</cfoutput>">
		<fieldset>
			<label>Please enter the Account Code to update:</label>
			<input type="text" name="AccountID" id="AccountID" />
			<input type="submit" name="frmSubmit" value="submit" />
		</fieldset>
	</form>
</body>
</html>
</cfxml>
<cfset strMyForm=toString(myForm)>
<cfset strMyForm=replace(strMyForm, "<![CDATA[", "") />
<cfset strMyForm=replace(strMyForm, "]]>", "") />
<cfreturn strMyForm />
</cffunction>


