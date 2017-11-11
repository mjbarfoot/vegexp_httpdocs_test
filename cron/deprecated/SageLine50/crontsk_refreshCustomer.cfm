<cfprocessingdirective  suppressWhiteSpace = "Yes">
<cfparam name="URL.accountCode" default="" />

<cfif URL.accountCode eq "">
<cfoutput>Please specify a Sage Customer Account Code</cfoutput>
<cfabort />
</cfif>

<cfscript>

//write crontask started
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: refreshCustomerData Started *****");

//intialise the Sage Connector
VARIABLES.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();

// start the stop watch
tickBegin=getTickCount(); tickEnd=0; tickinterval=0;

//cron task script  
xCustomerDataEnv = VARIABLES.sageWSGW.postRequest(generateSoap(URL.accountCode), "GetCustomerData");

//update the database
if (saveCustomerData(xCustomerDataEnv)) {
	application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: refreshCustomerData Complete *****");
} else {
	application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: refreshCustomerData Failed *****");
}
</cfscript>


<cffunction name="saveCustomerData" output="true" returnType="boolean"  access="private">
<cfargument name="xCustomerDataEnv" required="true" type="string" />

<cfscript>
var MyXmlDoc = "";
var posSpace = 0;
var firstName ="";
var lastname = "";
var CustomerData = "";

//parse the data
MyXmlDoc=xmlParse(ARGUMENTS.xCustomerDataEnv);

//check if Sage returned the Customer's XML data
if (StructKeyExists(MyXmlDoc.xmlRoot.xmlChildren[2], "GetCustomerDataResponse")) {
	//strip off the root XML data leaving just the customer's xml recordset
	CustomerData=MyXmlDoc.xmlRoot.xmlChildren[2].GetCustomerDataResponse.GetCustomerDataResult;
	//update the database
	DAOcustomerUpdate(URL.AccountCode, CustomerData);
} else {
	// Something went wrong, dump and diagnose
	dump(MyXMLDoc);
} 

return true;
</cfscript>

</cffunction>


<cffunction name="DAOcustomerUpdate" access="private" output="false" returntype="boolean">
<cfargument name="AccountCode" type="string" required="true" />
<cfargument name="xCustomerData" type="xml" required="true" />

<cfscript>
var customerData = ARGUMENTS.xCustomerData;
var firstName ="";
var lastname = "";

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


<!--- does customer exist --->
<cfquery name="qIsCustomer" datasource="#APPLICATION.dsn#">
SELECT AccountID 
FROM tblUsers
WHERE AccountID = '#ARGUMENTS.AccountCode#'
</cfquery>


<cfif qIsCustomer.recordCount>

	<cfquery name="qryUpdateCustomer" datasource="#APPLICATION.dsn#">
	UPDATE tblUsers
	SET 
	AccountOnHold = #CustomerData.AccountOnHold.xmlText#,
	firstname = '#firstName#',
	lastName = '#lastname#',
	company = '#xmlformat(ReplaceNoCase(CustomerData.AccountName.xmlText, "ONHOLD", "", "ALL"))#',
	<cfif CustomerData.discountRate.xmlText eq "">
	discountRate = 0,
	<cfelse>	
	discountRate = '#CustomerData.discountRate.xmlText#',
	</cfif>
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
	delroute = '#CustomerData.ContactName.xmlText#',
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
	WHERE AccountID = '#ARGUMENTS.AccountCode#'
	</cfquery>
	<cfscript>
	application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: refreshCustomerData - Account: #ARGUMENTS.AccountCode# Updated *****");
	</cfscript>
<cfelse>
	<cfquery name="qryInsProducts" datasource="#APPLICATION.dsn#"> 
	INSERT INTO tblUsers
	(AccountID, Company, AccountOnHold, firstname, lastname, discountrate, telnum,
	emailAddress, contactPref, building, postcode, viewFC, line1, town, county,
	delroute, delline1, delline2, delline3, delline4, delPostCode, delContactName, delFaxNumber, delName, 
	delTelephoneNumber, AllowEmailPost, AllowPhoneCalls, creditAccount, creditAccountAuth, AuthLevel,
	CreateDate, CreateTime, LastUpdatedDate, LastUpdatedTime, LastUpdatedBy, newCustomer)
	Values ('#CustomerData.AccountCode.xmlText#', '#CustomerData.AccountName.xmlText#', #CustomerData.AccountOnHold.xmlText#, '#firstname#', '#lastname#', <cfif CustomerData.discountRate.xmlText eq "">0,<cfelse>#CustomerData.discountRate.xmlText#</cfif>, '#CustomerData.TelephoneNumber.xmlText#',
			'#CustomerData.EMailAddress.xmlText#', 'phone', '#CustomerData.AccountAddressLine1.xmlText#', '#CustomerData.AccountAddressPostCode.xmlText#', 1, '#CustomerData.AccountAddressLine2.xmlText#', '#CustomerData.AccountAddressLine3.xmlText#', '#CustomerData.AccountAddressLine4.xmlText#',
			'#CustomerData.ContactName.xmlText#','#CustomerData.DeliveryAddressLine1.xmlText#', '#CustomerData.DeliveryAddressLine2.xmlText#', '#CustomerData.DeliveryAddressLine3.xmlText#',  '#CustomerData.DeliveryAddressLine4.xmlText#', '#CustomerData.DeliveryAddressPostCode.xmlText#',	 '#CustomerData.DeliveryContactName.xmlText#',	'#CustomerData.DeliveryFaxNumber.xmlText#',  '#CustomerData.DeliveryName.xmlText#',			
			'#CustomerData.DeliveryTelephoneNumber.xmlText#', 1, 1, 1, 1, 1,
			<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">, 
		    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		    <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		    'CronTask',
		    0);
	</cfquery>
	<cfscript>
	application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: refreshCustomerData - Account: #ARGUMENTS.AccountCode# Added *****");
	</cfscript>
</cfif>


<cfreturn true />

</cffunction>


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

<cffunction name="dump" access="private" returntype="void">
<cfargument name="dumpVar" type="any" required="true">
<cfdump var=#ARGUMENTS.dumpVar#>
<cfabort />
</cffunction>


</cfprocessingdirective>