<!--- Sync Customers for Sage 200

This task syncs customer records from Sage 200 with the Website Orders database (MySQL)

It will by default query for records which have been updated since the last time the job run
This is passed to the job as MetaData.

The records are batched into groups of 100 and calls are made to the API to update
or create new records in the web database as required.


Created for: Vegetarian Express
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk
--------------------------------------------------------------------------------
History: Version 1.0 11/07/2015
--->
<cfinclude template="cronVars.cfm" />

<cfset task = attributes.task />

<cfscript>

/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="sync Customers";
VARIABLES.chunkSize = 100;
VARIABLES.start = 1;
VARIABLES.end =  VARIABLES.start + (VARIABLES.chunkSize -1);
VARIABLES.result  = {};
VARIABLES.result.recordsFetched = 0;
VARIABLES.result.countUpdated = 0;
VARIABLES.result.countCreated = 0;
VARIABLES.result.countSkipped = 0;
VARIABLES.result.recordsSkipped = [];
VARIABLES.result.recordsUpdated = [];
VARIABLES.result.recordsCreated = [];
VARIABLES.lastModifiedDate = now()-1/24;

/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/


try {

    // Set lastModifiedDate from taskMetaData if available
    if (isdefined("task.metaData")) {
        if (!isStruct(task.metaData)) {
            if (isdefined("task.metaData.dateOfLastExecution"))
                VARIABLES.lastModifiedDate = task.metaData.dateOfLastExecution;
        }
    }

    //url override
    if (isdefined("url.syncDays")) {
        VARIABLES.lastModifiedDate = now() - url.syncDays;
    }

    //store in results so is available in log
    VARIABLES.result.lastModifiedDate = lsdateformat(VARIABLES.lastModifiedDate, "yyyy-mm-dd") & " " & lstimeformat(VARIABLES.lastModifiedDate, "HH:mm:ss");


    qCust = getCustomers(VARIABLES.lastModifiedDate);

    // record number of records checked
    VARIABLES.result.recordsFetched = qCust.recordCount;

//iterate in chunks
    while (VARIABLES.start lte qCust.recordCount) {

        // double check incase we get a result < 100
        if (VARIABLES.end gt qCust.recordCount) {
            VARIABLES.end = qCust.recordCount;
        }

        //create a new array
        custArray = [];

        for (i=VARIABLES.start; i lte VARIABLES.end; i++) {

            record = {};
            record["account_ref"] = qCust["account_ref"][i];
            record["accountonhold"] = qCust["accountonhold"][i];
            record["accountname"] =  qCust["accountname"][i];
            record["priceband"] = qCust["priceband"][i];
            record["discountrate"] =  qCust["discountrate"][i];
            record["contactname"] =  qCust["contactname"][i];
            record["phonenumber"] = qCust["phonenumber"][i];
            record["emailaddress"] = qCust["emailaddress"][i];
            record["building"] = qCust["building"][i];
            record["line1"] = qCust["line1"][i];
            record["town"] = qCust["town"][i];
            record["county"] = qCust["county"][i];
            record["postcode"] = qCust["postcode"][i];
            record["delline1"] = qCust["delline1"][i];
            record["delline2"] = qCust["delline2"][i];
            record["delline3"] = qCust["delline3"][i];
            record["delline4"] = qCust["delline4"][i];
            record["delpostcode"] = qCust["delpostcode"][i];
            record["delcontactname"] = qCust["delcontactname"][i];
            record["deltelnumber"] = qCust["deltelnumber"][i];
            record["delfaxno"] = qCust["delfaxno"][i];
            record["dateaccountdetailslastchanged"] = lsdateformat(qCust["dateaccountdetailslastchanged"][i], "yyyy-mm-dd") & " " & lstimeformat(qCust["dateaccountdetailslastchanged"][i], "HH:mm:ss");
            arrayAppend(custArray, record);

        }

        //call the web service or for testing write out to file system
        data = serializeJSON(custArray);

        //FileWrite(expandPath(".") & "\customers" & VARIABLES.start & ".json", data, "utf-8");
        httpService = new http();

        httpService.setMethod("post");
        httpService.setCharset("utf-8");
        httpService.setUrl("https://orders.vegetarianexpress.co.uk/api/syncCustomers");
        httpService.addParam(type="formfield", name="data", value="#data#");

        response = httpService.send().getPrefix();
        responseJSON = deserializeJSON(response.filecontent);

        //update the results
        VARIABLES.result.countUpdated = VARIABLES.result.countUpdated + responseJSON.countUpdated;
        VARIABLES.result.countCreated = VARIABLES.result.countUpdated + responseJSON.countUpdated;;
        VARIABLES.result.countSkipped = VARIABLES.result.countSkipped + responseJSON.countSkipped;;
        arrayAppend(VARIABLES.result.recordsSkipped, responseJSON.recordsSkipped);
        arrayAppend(VARIABLES.result.recordsUpdated, responseJSON.recordsUpdated);
        arrayAppend(VARIABLES.result.recordsCreated, responseJSON.recordsCreated);


        //update the loop variables
        VARIABLES.start = VARIABLES.end + 1;
        VARIABLES.end =  VARIABLES.start + (VARIABLES.chunkSize -1);
        if (VARIABLES.end gt qCust.recordCount) {
            VARIABLES.end = qCust.recordCount;
        }

    }


    task.metaData = {
        name = VARIABLES.crontaskName,
        results = VARIABLES.result
    };

    dump(task.metaData);

    //Update Task Meta Data
   if (isdefined("task.metaData")) {
       if (!isStruct(task.metaData)) {


       }
   }

   if (isdefined("URL.dump")) {
       dump(VARIABLES.result);
   }

} catch (Any e) {
    dump(e);
}


</cfscript>

<cffunction name="getCustomers" output="false" returntype="query" hint="extracts product data from Sage 200">
<cfargument name="lastModifiedDate" required="true" type="date" />
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
    <cfquery name="q" datasource="#VARIABLES.Sage200_dsn#"  blockfactor="100">
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
						DEL.FAXNO						AS DELFAXNO,
						CA.DATEACCOUNTDETAILSLASTCHANGED AS DATEACCOUNTDETAILSLASTCHANGED
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
	WHERE   CA.DATEACCOUNTDETAILSLASTCHANGED > <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#lastModifiedDate#" />
	</cfquery>


<cfreturn q />

</cffunction>