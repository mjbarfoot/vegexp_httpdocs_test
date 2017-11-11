<!--- Gets customers from Sage 200

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk

--->	

<!--- include common utility functions --->
<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="upload Customers";
VARIABLES.crontaskDesc="Exports Sage Accounts List from Sage 200 database and FTPs XML to website on a daily basis";
VARIABLES.LOGGERS = structnew();
VARIABLES.LOGGERS["getCustomersLog"] = structnew();
VARIABLES.LOGGERS["getCustomersLog"].name = "getCustomersLog";
VARIABLES.LOGGERS["customers.xml"] = structnew();
VARIABLES.LOGGERS["customers.xml"].name = "customers.xml";


//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;


// *** END OF VARS *** //


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/

// *** setup the files to write output to. 
setUpFileWriters();

// *** 1) Extract list and item data from database
qCUST = getCustomers();

// did we get a query object?
if (isQuery(qCUST))  {
	
	// 2) Convert to WDDX and 3) Write to FileSystem
	isComplete = writeCustomersXML(qCUST);
	if (NOT isComplete) abortTask(getLogger("getCustomersLog"), VARIABLES.LOGGERS["getCustomersLog"].name);
} else {
	abortTask(getLogger("getCustomersLog"), VARIABLES.LOGGERS["getCustomersLog"].name);
}

// 4) Ftp to Server 
// *** ftp the favourites.xml file to the VE Web Server
isComplete = ftpToWebServer("customers.xml", getLogger("getCustomersLog"));
if (isComplete) {
	setStatusComplete(VARIABLES.LOGGERS, VARIABLES.crontaskName, VARIABLES.task_tickinterval);
} else {
	abortTask(getLogger("getCustomersLog"), VARIABLES.LOGGERS["getCustomersLog"].name);
}


/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="getCustomers" output="false" returntype="any" hint="extracts product data from Sage 200">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>



<cftry>
	<!---
	CAVEATS/NOTES ON THIS QUERY
	1) < no. customer records may be returned if there is record in SLCustomContactRole.
	Sage Line 200 / M2M have setup one per customer with 1 contact = 1 Account (preferred contact role).
	Account role = R.SYSTRADERCONTACTROLEID = 1 and Preferred Contact = R.ISPREFERREDCONTACTFORROLE = 1 (1=true,0=false)
	** Sage 200 enforces uniqueness so although their can be more than 1 contact with the account role, only 1 can be preferred contact.
	Not sure it creates this by default?
	2) Customer Contact Sys Contact Type = 0 Phonenumber
	3) Customer Contact Sys Contact Type = 2 Email Address
	4) Customers may have many delivery address notes, only descriptions marked 1 are retrieved to the website
	5) If Customer Contact conventions i.e. switching use of contact type or redefining them then phone number and email address 
	   maybe overwritten. 
	6) Customers have one to one relationship with location: SLCustomerLocation   	
	--->
	<cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  result="qRes" blockfactor="100">
	SELECT	DISTINCT	CA.CUSTOMERACCOUNTNUMBER 		AS ACCOUNT_REF,
						CA.ACCOUNTISONHOLD 				AS ACCOUNTONHOLD,
						CA.CUSTOMERACCOUNTNAME			AS ACCOUNTNAME,
						PB.NAME							AS PRICEBAND,
						CA.INVOICELINEDISCOUNTPERCENT 	AS DISCOUNTRATE,		
						CON.CONTACTNAME 				AS CONTACTNAME,
						CV1.CONTACTVALUE 				AS PHONENUMBER,
						CV2.CONTACTVALUE 				AS EMAILADDRESS,
						LOC.ADDRESSLINE1 				AS BUILDING,
						LOC.ADDRESSLINE2 				AS LINE1,
						LOC.ADDRESSLINE3 				AS TOWN,
						LOC.ADDRESSLINE4 				AS COUNTY,
						LOC.POSTCODE					AS POSTCODE,
						DEL.ADDRESSLINE1 				AS DELLINE1,
						DEL.ADDRESSLINE2 				AS DELLINE2,
						DEL.ADDRESSLINE3 				AS DELLINE3,
						DEL.ADDRESSLINE4 				AS DELLINE4,
						DEL.POSTCODE 					AS DELPOSTCODE,
						DEL.CONTACT 					AS DELCONTACTNAME,
						DEL.TELEPHONENO 				AS DELTELNUMBER,
						DEL.FAXNO						AS DELFAXNO
	FROM	SLCUSTOMERACCOUNT CA
			LEFT  JOIN CUSTDELIVERYADDRESS DEL 
	ON		CA.SLCUSTOMERACCOUNTID = DEL.CUSTOMERID AND DEL.DESCRIPTION = '1'
			LEFT JOIN SLCUSTOMERCONTACT CON
	ON		CA.SLCUSTOMERACCOUNTID = CON.SLCUSTOMERACCOUNTID
			INNER JOIN SLCUSTOMERCONTACTROLE R  
	ON		CON.SLCUSTOMERCONTACTID = R.SLCUSTOMERCONTACTID
			AND R.SYSTRADERCONTACTROLEID = 1
			AND R.ISPREFERREDCONTACTFORROLE = 1
			LEFT JOIN SLCUSTOMERLOCATION LOC
	ON		CA.SLCUSTOMERACCOUNTID = LOC.SLCUSTOMERACCOUNTID
			LEFT JOIN SLCUSTOMERCONTACTVALUE CV1
	ON		CON.SLCUSTOMERCONTACTID = CV1.SLCUSTOMERCONTACTID
			AND	CV1.SYSCONTACTTYPEID = 0
			LEFT JOIN SLCUSTOMERCONTACTVALUE CV2
	ON		CON.SLCUSTOMERCONTACTID = CV2.SLCUSTOMERCONTACTID
			AND	CV2.SYSCONTACTTYPEID = 2
			LEFT JOIN PRICEBAND PB
	ON		CA.PRICEBANDID = PB.PRICEBANDID
	</cfquery>
	
	<cfscript>
	
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getCustomersLog").write("#timeformat(now(), 'H:MM:SS')# Success: getCustomers - fetched #q.recordcount# records in #tickinterval# ms");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getCustomers", "	SLCUSTOMERACCOUNT,CUSTDELIVERYADDRESS,SLCUSTOMERCONTACT,SLCUSTOMERLOCATION,SLCUSTOMERCONTACTVALUE,SLCUSTOMERCONTACTVALUE,PRICEBAND",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	getLogger("getCustomersLog").write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>

<cfreturn ret />


</cffunction>

<cffunction name="writeCustomersXML" output="false" returntype="boolean" hint="writes out customer data as WDDX packet">
<cfargument name="q" type="query" required="true" hint="a query containing customer data" />

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>


<cfwddx action="cfml2wddx" input="#ARGUMENTS.q#" output="qXml" />


<cfscript>
tickEnd=getTickCount();
tickinterval=decimalformat((tickend-tickbegin)/1000);
getLogger("customers.xml").write(trim(qXml));
getLogger("getCustomersLog").write("#timeformat(now(), 'H:MM:SS')# Success: writeCustomersXML - Wrote Customers XML to filesystem (#tickinterval# s)");
</cfscript>

<cfreturn true/>
</cffunction>


