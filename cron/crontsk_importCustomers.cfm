<!--- Imports customer data from a wddx file (customers.xml) on the server
stored in the httpdocs/xml_inbound directory

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Convert the xml file to wddx
2) import into tblUsers
--->	

<cfinclude template="cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="import Customers";
VARIABLES.logFileName="crontsklog";
VARIABLES.importXMLFileName="customers.xml";

//time the task
VARIABLES.task_tickBegin=getTickCount();
VARIABLES.task_tickEnd=0;
VARIABLES.task_tickinterval=0;

// Sage Line 200 ColdFusion DSN
VARIABLES.crontaskdsn=APPLICATION.dsn;
// Favourites DB
//VARIABLES.FavDB_dsn="veFavDb";
//line break 
VARIABLES.linebreak = "#chr(13)##chr(10)#";
// dev of prod mode?
VARIABLES.isProduction = isProductionServer();

//email params
if (VARIABLES.isProduction) {
	VARIABLES.inbound_path="/var/www/orders.vegetarianexpress.co.uk/web/xml_inbound/";
	VARIABLES.logPath = "/var/www/orders.vegetarianexpress.co.uk/web/logs/";
	VARIABLES.email_notify=true;
	VARIABLES.email_notification_to = "webmaster@vegetarianexpress.co.uk";
	VARIABLES.email_notification_cc = "willmatier@vegexp.co.uk";
	VARIABLES.email_notification_from = "crontask@vegetarianexpress.co.uk";
} else {
	VARIABLES.inbound_path="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/xml_inbound/";
	VARIABLES.logPath = "/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";
	VARIABLES.email_notify=false;
	VARIABLES.email_notification_to = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_cc = "";
	VARIABLES.email_notification_from = "dev-crontask@vegetarianexpress.co.uk";
}
// *** END OF VARS *** //


/*******************************************************************************
*  TASK INITIALISATION													       *
*******************************************************************************/
VARIABLES.logger = application.crontsklog;


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - STARTED.");

// 1) Convert products.xml to query object
qCUST = getWDDXfromFilename(VARIABLES.inbound_path, importXMLFileName, VARIABLES.logger);


VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# Starting Import into tblUsers");    
// 2) Insert them into a temporary table (importIntoTblAuthCustomerList)
if (isQuery(qCUST))  {
	isComplete = importIntoTblCustomers(qCUST);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	abortTask(VARIABLES.logger);
}

// 3) Remove old customers
if (isQuery(qCUST))  {
	isComplete = deleteOldCustomers(qCUST);
	if (NOT isComplete) abortTask(VARIABLES.logger);
} else {
	abortTask(VARIABLES.logger);
}


isComplete = removeZeroWebAccounts();
if (NOT isComplete) abortTask(VARIABLES.logger);



// stop the clock
VARIABLES.task_tickEnd=getTickCount();
VARIABLES.task_tickinterval=decimalformat((VARIABLES.task_tickend-VARIABLES.task_tickbegin)/1000);
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s");

//email results
//emailLogFiles(isComplete=true, logFileName=VARIABLES.logFileName, crontaskName=VARIABLES.cronTaskName);
/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>






<cffunction name="importIntoTblCustomers" output="false" returntype="any" hint="truncates and inserts price data">
<cfargument name="q" type="query" required="true" hint="a query containing  price data">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
var updateCount=0;
var addCount=0; 
</cfscript>


<!--- import customer data --->
<cfloop query="ARGUMENTS.q">
<cftry>
	 <!---check if customer exists --->
	<cfquery name="chk" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	SELECT 1 FROM tblUsers where AccountID =  '#ACCOUNT_REF#'					
	</cfquery>
	
	<!--- Add  or Update customers,  but ignore 0WEB accounts --->
	<cfif findNoCase("0WEB", Account_Ref) eq 0>
		<cfif chk.recordcount eq 1>
			<cfset updateCount = updateCount + 1 />
			<cfset ret = updateCustomer(rowCopy(q, currentrow)) /> 
		<cfelseif chk.recordcount eq 0>
			<cfset addCount = addCount + 1/>
			<cfset ret = addCustomer(rowCopy(q, currentrow)) />
		</cfif>
	</cfif>
			
	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: importIntoTblCustomers - ADDED #addCount# records, UPDATED #updateCount# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>
	
	
<cfcatch type="any">

	<cfscript>
	formattedError=returnFormattedQueryError("importIntoTblCustomers", "TBLUSERS",  "INSERT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
	
    <cfrethrow />
    
	<cfbreak />
		
</cfcatch>
</cftry>
</cfloop>

<cfreturn ret />

</cffunction>

<cffunction name="addCustomer" output="true" returntype="any" hint="adds a customer record">
<cfargument name="c" type="struct" required="true" hint="a query containing  price data">

<cfscript>
var posSpace="";
var firstname="";
var lastname="";
var ret=false;

//set firstname and lastname by splitting string at position of space. 
posSpace = Findnocase(" ", ARGUMENTS.c.CONTACTNAME); 
if (posSpace) {
	firstName = mid(ARGUMENTS.c.CONTACTNAME,1,posSpace); 
	lastname  = mid(ARGUMENTS.c.CONTACTNAME, (posSpace+1), len(ARGUMENTS.c.CONTACTNAME));	
} else {
	firstname = "";
	lastname  =	ARGUMENTS.c.CONTACTNAME;
}
</cfscript>



<cftry>
	<!--- check if customer exists --->
	<cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	INSERT INTO tblUsers
	(AccountID,
	AccountOnHold,
	firstname,
	lastName,
	company,
	discountRate, 
	priceband,
	telnum,
	emailAddress,
	contactPref, 
	building,
	postcode, 
	viewFC,
	line1, 
	town, 
	county,
	delline1, 
	delline2, 
	delline3, 
	delline4, 
	delPostcode,
	delContactName, 
	delName,
	delTelephoneNumber, 
	delFaxNumber,
	AllowEmailPost,
	AllowPhoneCalls,
	creditAccount,
	creditAccountAuth,
	AuthLevel,
	LastUpdatedDate, 
	LastUpdatedTime, 
	LastUpdatedBy, 
	newCustomer)
	VALUES ('#ACCOUNT_REF#',
			#ARGUMENTS.c.ACCOUNTONHOLD#,
			'#FIRSTNAME#',
			'#LASTNAME#',
			'#xmlformat(ReplaceNoCase(ARGUMENTS.c.ACCOUNTNAME, "ONHOLD", "", "ALL"))#',
			'#ARGUMENTS.c.DISCOUNTRATE#',
			'#ARGUMENTS.c.PRICEBAND#',
			'#ARGUMENTS.c.PHONENUMBER#',
			'#ARGUMENTS.c.EMAILADDRESS#',
			'PHONE',
			'#ARGUMENTS.c.BUILDING#',
			'#ARGUMENTS.c.POSTCODE#',
			1,
			'#ARGUMENTS.c.LINE1#',
			'#ARGUMENTS.c.TOWN#',
			'#ARGUMENTS.c.COUNTY#',
			'#ARGUMENTS.c.DELLINE1#',
			'#ARGUMENTS.c.DELLINE2#',
			'#ARGUMENTS.c.DELLINE3#',
			'#ARGUMENTS.c.DELLINE4#',
			'#ARGUMENTS.c.DELPOSTCODE#',
			'#ARGUMENTS.c.DELCONTACTNAME#',
			'#ARGUMENTS.c.DELCONTACTNAME#',
			'#ARGUMENTS.c.DELTELNUMBER#',
			'#ARGUMENTS.c.DELFAXNO#',
			1,
			1,
			1,
			1,
			1,
			<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			'CronTask',
			0)

	</cfquery>
	
	<cfset ret=true />
	
<cfcatch type="any">
		
	<cfscript>
	formattedError=returnFormattedQueryError("addCustomer", "TBLUSER",  "INSERT", cfcatch);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
    <cfrethrow />

</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>

<cffunction name="updateCustomer" output="true" returntype="any" hint="adds a customer record">
<cfargument name="c" type="struct" required="true" hint="a query containing  price data">

<cfscript>
var posSpace="";
var firstname="";
var lastname="";
var ret=false;

//set firstname and lastname by splitting string at position of space. 
posSpace = Findnocase(" ", ARGUMENTS.c.CONTACTNAME); 
if (posSpace) {
	firstName = mid(ARGUMENTS.c.CONTACTNAME,1,posSpace); 
	lastname  = mid(ARGUMENTS.c.CONTACTNAME, (posSpace+1), len(ARGUMENTS.c.CONTACTNAME));	
} else {
	firstname = "";
	lastname  =	ARGUMENTS.c.CONTACTNAME;
}
</cfscript>

<cftry>
	<!--- check if customer exists --->
	<cfquery name="u" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	UPDATE tblUsers
	SET 
	AccountOnHold = #ARGUMENTS.c.ACCOUNTONHOLD#,
	firstname = '#FIRSTNAME#',
	lastName = '#LASTNAME#',
	company = '#xmlformat(ReplaceNoCase(ARGUMENTS.c.ACCOUNTNAME, "ONHOLD", "", "ALL"))#',
	discountRate = '#ARGUMENTS.c.DISCOUNTRATE#',
	priceband = '#ARGUMENTS.c.PRICEBAND#',
	telnum = '#ARGUMENTS.c.PHONENUMBER#',
	emailAddress = '#ARGUMENTS.c.EMAILADDRESS#',
	contactPref = 'PHONE',
	building = '#ARGUMENTS.c.BUILDING#',
	postcode = '#ARGUMENTS.c.POSTCODE#',
	viewFC = 1,
	line1 = '#ARGUMENTS.c.LINE1#',
	town = '#ARGUMENTS.c.TOWN#',
	county = '#ARGUMENTS.c.COUNTY#',
	delline1 = '#ARGUMENTS.c.DELLINE1#',
	delline2 = '#ARGUMENTS.c.DELLINE2#',
	delline3 = '#ARGUMENTS.c.DELLINE3#',
	delline4 = '#ARGUMENTS.c.DELLINE4#',
	delPostcode = '#ARGUMENTS.c.DELPOSTCODE#',
	delContactName = '#ARGUMENTS.c.DELCONTACTNAME#',
	delName = '#ARGUMENTS.c.DELCONTACTNAME#',
	delTelephoneNumber = '#ARGUMENTS.c.DELTELNUMBER#',
	delFaxNumber = '#ARGUMENTS.c.DELFAXNO#',
	AllowEmailPost = 1,
	AllowPhoneCalls = 1,
	creditAccount = 1,
	creditAccountAuth = 1,
	AuthLevel = 1,
	LastUpdatedDate = <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
	LastUpdatedTime = <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
	LastUpdatedBy = 'CronTask',
	newCustomer = 0
	WHERE AccountID = '#ACCOUNT_REF#'
	</cfquery>

	<cfset ret=true />
	
<cfcatch type="any">

	<cfscript>
	formattedError=returnFormattedQueryError("updateCustomer", "TBLUSER",  "UPDATE", cfcatch);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>

    
    <cfrethrow />
</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>

<cffunction name="deleteOldCustomers" output="false" returntype="any" hint="truncates and inserts price data">
<cfargument name="q" type="query" required="true" hint="a query containing  price data">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
var deleteCount=0;
</cfscript>

	<cfquery name="g" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	SELECT AccountID FROM tblUsers 			
	</cfquery>


<!--- import customer data --->
<cfloop query="g">
<cftry>
	 <!---check if customer exists --->
	<cfquery name="chk" dbtype="query">
	SELECT 1 FROM ARGUMENTS.q where ACCOUNT_REF = '#ACCOUNTID#'					
	</cfquery>
	
	<cfif chk.recordcount eq 0>
		<cfset deleteCount = deleteCount + 1 />
		<cfset ret = deleteCustomer(ARGUMENTS.q["ACCOUNT_REF"][CURRENTROW]) /> 
	</cfif>
	
			
	<cfif currentrow eq ARGUMENTS.q.recordcount>
		<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: deleteOldCustomers - DELETED #deleteCount# records (#tickinterval# s)");
		ret=true;
		</cfscript> 
	</cfif>
	
	
<cfcatch type="any">
	
	<cfscript>
	formattedError=returnFormattedQueryError("deleteOldCustomers", "TBLUSERS",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
	
    <cfrethrow />	
    
	<cfbreak />
		
</cfcatch>
</cftry>
</cfloop>

<cfreturn ret />

</cffunction>

<cffunction name="deleteCustomer" output="true" returntype="any" hint="deletes a customer record">
<cfargument name="Account_Ref" type="String" required="true" hint="The account reference of the customer to delete">

<cfscript>
var ret=false;
</cfscript>

<cftry>
	<!--- check if customer exists --->
	<cfquery name="d" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	DELETE FROM tblUsers
	WHERE AccountID = '#ARGUMENTS.ACCOUNT_REF#'
	</cfquery>

	<cfset ret=true />
	
<cfcatch type="any">

	<cfscript>
	formattedError=returnFormattedQueryError("deleteCustomer", "TBLUSER",  "DELETE", cfcatch);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
		
    	<cfrethrow />
</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>

<cffunction name="removeZeroWebAccounts" output="true" returntype="any" hint="removes zeroweb customer records">

<cfscript>
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>
	<!--- check if customer exists --->
	<cfquery name="d" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	DELETE FROM tblUsers
	WHERE AccountID LIKE  '0WEB%'
	</cfquery>
	
	<cfscript>
		tickEnd=getTickCount();
		tickinterval=decimalformat((tickend-tickbegin)/1000);
		VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeZeroWebAccounts - DELETED TEMPORARY ""OWEB"" REGISTRATION ACCOUNTS (#tickinterval# s)");
		ret=true;
	</cfscript> 
	
	<cfset ret=true />
	
<cfcatch type="any">


	<cfscript>
	formattedError=returnFormattedQueryError("deleteCustomer", "TBLUSER",  "DELETE", cfcatch);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>
    <cfrethrow />
</cfcatch>
</cftry>

<cfreturn ret />
</cffunction>