<!---
    Import authorised lists
--->
<cfset task = attributes.task />

<!---for testing --->
<cfif not isdefined("task.metaData")>
    <cfset task.metaData = structnew() />
</cfif>

<cfinclude template="../cronUtil_UDF.cfm" />

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
VARIABLES.crontaskName="import Allowed and Disallowed Lists";
VARIABLES.logFileName="crontsklog";
VARIABLES.importXMLFileName="custmanagedlists.xml";
VARIABLES.result  = {};

/*******************************************************************************
*  PATH SETTINGS	  												           *
*******************************************************************************/
if (VARIABLES.isProduction) {
    VARIABLES.inbound_path="/var/www/orders.vegetarianexpress.co.uk/web/xml_inbound/";

} else {
    VARIABLES.inbound_path="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/xml_inbound/";
}

/*******************************************************************************
*  DO THE ACTUAL WORK  												           *
*******************************************************************************/
try {
    qML = getWDDXfromFilename(VARIABLES.inbound_path, VARIABLES.importXMLFileName);
    importIntoTblAuthCustomerList(qML);
} catch (Any e) {
    dump(e);
}


task.metaData = {
    name = VARIABLES.crontaskName,
    results = VARIABLES.result
};

dump(task.metaData);


</cfscript>


<cffunction name="importIntoTblAuthCustomerList" output="false" returntype="any" hint="truncates and inserts cust managed list data">
    <cfargument name="q" type="query" required="true" hint="a query containing customer managed list data">

    <cfscript>
        var ret=false;
    </cfscript>


<!--- truncate --->
    <cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
	DELETE FROM tblAuthCustomerList
	</cfquery>


<!--- import custmanagedlist data --->
    <cfloop query="ARGUMENTS.q">
            <cfquery name="chk" datasource="#VARIABLES.crontaskdsn#">
	          select 1 from tblAuthCustomerList where account_ref = '#ACCOUNT_REF#' and ANALYSISCODE9 = '#ANALYSISCODE9#'
	        </cfquery>

            <cfif chk.recordcount eq 0>
                <cfquery name="i" datasource="#VARIABLES.crontaskdsn#" result="qRes">
                INSERT INTO tblAuthCustomerList
                (ACCOUNT_REF, MANAGED_LIST, ANALYSISCODE5, ANALYSISCODE9)
                VALUES('#ACCOUNT_REF#','#ANALYSISCODE5#','#ANALYSISCODE5#','#ANALYSISCODE9#')
                </cfquery>
            </cfif>
    </cfloop>

    <cfreturn ret />

</cffunction>
