<!--- Imports categories data from a wddx file (categories.xml) on the server
stored in the httpdocs/xml_inbound directory

Created for: Vegetarian Express 
Author:    Matt Barfoot (c) Clearview Webmedia Limited 2008
Contact: 07968 175 795 / matt.barfoot@clearview-webmedia.co.uk


Design Spec
---------------------------------------------------------------
1) Convert categories.xml to query object
2) Insert them into a temporary table (tblProductsPad)
3) Remove any products from website product inventory whose stockcode is our temporary holding table
4) Update existing products

--->

<cfinclude template="cronUtil_UDF.cfm"/>

<cfscript>
/*******************************************************************************
*  GLOBAL VARS		  												           *
*******************************************************************************/
    VARIABLES.crontaskName = "import Categories";
    VARIABLES.logFileName = "crontsklog";
    VARIABLES.XMLfilename = "categories.xml";
    VARIABLES.enabledCategoryCount = 0;
    VARIABLES.disabledCategoryCount = 0;

//time the task
    VARIABLES.time_started = now();
    VARIABLES.task_tickBegin = getTickCount();
    VARIABLES.task_tickEnd = 0;
    VARIABLES.task_tickinterval = 0;

    VARIABLES.linebreak = "#chr(13)##chr(10)#";

// dev of prod mode?
    VARIABLES.isProduction = isProductionServer();

//email params
    if (VARIABLES.isProduction) {
        VARIABLES.inbound_path = "/var/www/orders.vegetarianexpress.co.uk/web/xml_inbound/";
        VARIABLES.logPath = "/var/www/orders.vegetarianexpress.co.uk/web/logs/";
        VARIABLES.email_notify = true;
        VARIABLES.email_notification_to = "philipcrawford@vegexp.co.uk";
        VARIABLES.email_notification_cc = "willmatier@vegexp.co.uk";
        VARIABLES.email_notification_from = "crontask@vegetarianexpress.co.uk";
    } else {
        VARIABLES.inbound_path = "/Users/mbarfoot/VHOSTS/vegexp_httpdocs/xml_inbound/";
        VARIABLES.logPath = "/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";
        VARIABLES.email_notify = false;
        VARIABLES.email_notification_to = "matt.barfoot@clearview-webmedia.co.uk";
        VARIABLES.email_notification_cc = "";
        VARIABLES.email_notification_from = "dev-crontask@vegetarianexpress.co.uk";
    }

//initalise the deparement do and get a list of filtered (out) categories
    VARIABLES.dep_do = createObject("component", "cfc.departments.do");
    VARIABLES.qFilteredCats = VARIABLES.dep_do.getFilterCats("category");

//setup log file
    VARIABLES.logger = APPLICATION.crontsklog;
// *** END OF VARS *** //


/*******************************************************************************
*  TASK SCRIPT START													       *
*******************************************************************************/
    VARIABLES.logger.write("#timeformat(now(), 'h:mm:ss')# CRONJOB: #VARIABLES.crontaskName# - STARTED");

// 1) Convert products.xml to query object
    q = getWDDXfromFilename(VARIABLES.inbound_path, VARIABLES.XMLfilename, VARIABLES.logger);

// 1.5) Get rid of padding zeros in stockCategoryNumber
    qCat = removeStockCatNumPaddedZeros(q);

// 2) Insert them into a temporary table (tblProductsPad)
// did we get a query object?
    if (isQuery(qCat)) {
// 2) Convert to WDDX and 3) Write to FileSystem
        isComplete = updateCategories(qCat);
        if (NOT isComplete) abortTask(VARIABLES.logger);
    } else {
        dump(qCat);
        abortTask(VARIABLES.logger);
    }

// stop the clock
    VARIABLES.task_tickEnd = getTickCount();
    VARIABLES.task_tickinterval = decimalformat((VARIABLES.task_tickend - VARIABLES.task_tickbegin) / 1000);
    VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: #VARIABLES.crontaskName# - COMPLETE. Duration #VARIABLES.task_tickinterval# s");

//email results
   // emailLogFiles(isComplete = true, logFileName = VARIABLES.logFileName, crontaskName = VARIABLES.cronTaskName);
/*******************************************************************************
*  TASK SCRIPT END													           *
*******************************************************************************/
</cfscript>

<cffunction name="removeStockCatNumPaddedZeros" output="false" returntype="any" hint="stips of zero-padding from the Stock Category Number">
    <cfargument name="q" type="query" required="true" hint="">

    <cfscript>
        var tickBegin = getTickCount();
        var tickEnd = 0;
        var tickinterval = 0;
        var ret = false;
    </cfscript>

<!--- combine order details with items ordered --->
    <cfloop query="q">
        <cftry>

            <cfscript>
                QuerySetCell(q, "CategoryID", "#reReplace(CategoryID, '(0|00)(?=\d)', '')#", currentrow);
            </cfscript>

            <cfif currentrow eq q.recordcount>
                <cfscript>
                    tickEnd = getTickCount();
                    tickinterval = decimalformat((tickend - tickbegin) / 1000);
                    VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: removeStockCatNumPaddedZeros - updated #q.recordcount# records (#tickinterval# s)");
                    ret = q;
                </cfscript>
            </cfif>

            <cfcatch type="any">

                <cfscript>
                    formattedError = returnFormattedQueryError("removeStockCatNumPaddedZeros", "ARGUMENTS.q", "UPDATE", cfcatch);
                    tickEnd = getTickCount();
                    tickinterval = decimalformat((tickend - tickbegin) / 1000);
                    VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
                </cfscript>

                <cfbreak/>
            </cfcatch>
        </cftry>
    </cfloop>

    <cfreturn ret/>

</cffunction>

<cffunction name="updateCategories" output="false" returntype="any" hint="Updates categories">
    <cfargument name="q" type="query" required="true" hint="a query containing just the category codes and info from Sage 200">

    <cfscript>
        var i = 1;
        var tickBegin = getTickCount();
        var tickEnd = 0;
        var tickinterval = 0;
        var ret = false;
    </cfscript>

<!--- delete existing categories --->
    <cfquery name="qRemoveCategories" datasource="#APPLICATION.dsn#">
TRUNCATE table tblCategory
</cfquery>


<!--- iterate through categories --->
    <cfloop query="ARGUMENTS.q">
<!--- check if the catgory number is in a valid range and determine department by checking the first digit --->
        <cfif isValidCategory(CategoryID)>
<!--- insert the ENABLED category into the database --->
            <cftry>
                <cfquery name="chk" datasource="#APPLICATION.dsn#">
                    select 1 from tblCategory where CategoryID = '#val(CategoryID)#'
                 </cfquery>

               <cfif chk.recordcount eq 0>
                    <cfquery name="qInsertCategory" datasource="#APPLICATION.dsn#">
                    INSERT INTO tblCategory
                    (DepartmentID, Department, CategoryID, Category, Disabled)
                    VALUES (
                    <!--- is it a chilled product --->
                                <cfif left(CategoryID, 1) eq "1">
                                    1, 'Frozen', #val(CategoryID)#,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(category)#">, 0
                    <!--- is it a frozen product --->
                                    <cfelseif left(CategoryID, 1) eq "2">
                                    2, 'Chilled', #val(CategoryID)#,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(category)#">, 0
                    <!--- is it a ambient product --->
                                    <cfelseif left(CategoryID, 1) gte "6">
                                    3, 'Ambient', #val(CategoryID)#,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(category)#">, 0
                    </cfif>
                                )
                    </cfquery>

                    <cfset enabledCategoryCount = enabledCategoryCount + 1/>
<!--- product is within the disabled/filtered category range --->
                </cfif>
                <cfcatch type="any">

                    <!---<cfrethrow/>

                    <cfscript>
                        formattedError = returnFormattedQueryError("updateCategories", "tblCategory", "INSERT", cfcatch);
                        tickEnd = getTickCount();
                        tickinterval = decimalformat((tickend - tickbegin) / 1000);
                        VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
                    </cfscript>

                    <cfbreak/>--->

                </cfcatch>
            </cftry>
            <cfelse>

            <cftry>

<!--- insert the category anyway marking it as diabled --->
                <cfquery name="qInsertCategory" datasource="#APPLICATION.dsn#">
		INSERT INTO tblCategory
		(DepartmentID, Department, CategoryID, Category, Disabled)
		VALUES (0, 'Disabled', #val(categoryid)#,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryFormat(category)#">, 1)
		</cfquery>

                <cfset disabledCategoryCount = disabledCategoryCount + 1/>

                <cfcatch type="any">

                    <!---<cfrethrow/>

                    <cfscript>
                        formattedError = returnFormattedQueryError("updateCategories", "tblCategory", "INSERT", cfcatch);
                        tickEnd = getTickCount();
                        tickinterval = decimalformat((tickend - tickbegin) / 1000);
                        VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
                    </cfscript>

                    <cfbreak/>--->

                </cfcatch>
            </cftry>
        </cfif>

        <cfif currentrow eq ARGUMENTS.q.recordcount>
            <cfscript>
                tickEnd = getTickCount();
                tickInterval = (tickEnd - tickBegin) / 1000;
                VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')#" & " Added #enabledCategoryCount# Enabled Categories and #disabledCategoryCount# Disabled (#tickInterval# s)");
                VARIABLES.enabledCategoryCount = enabledCategoryCount;
                VARIABLES.disabledCategoryCount = disabledCategoryCount;
                ret = true;
            </cfscript>

        </cfif>

    </cfloop>

    <cfreturn ret/>

</cffunction>

<cffunction name="categoryFormat" output="false" returntype="string" access="private">
    <cfargument name="str" required="true" type="string"/>
    <cfscript>
        return rereplace(REReplace(ARGUMENTS.str, "\b(\S)(\S*)\b", "\u\1\L\2", "all"), "([()])\d*", "", "all");
    </cfscript>

</cffunction>

<cffunction name="isValidCategory" output="false" returntype="boolean" access="private">
    <cfargument name="stockcategorynumber" type="string" required="true"/>

    <cfset var isValid = true>

<!--- check against tblFilter which defines upper limits and lower limits for category numbers--->
    <cfloop query="VARIABLES.qFilteredCats">
<!--- if it is in the filter range it can be ignore and is not a valid category --->
        <cfif ARGUMENTS.stockcategorynumber gte Start AND ARGUMENTS.stockcategorynumber lte End>
            <cfset isValid = false/>
            <cfbreak/>
        </cfif>
    </cfloop>

<!---disable any non-numeric codes--->
    <cfif val(stockcategorynumber) eq 0>
        <cfset isValid = false/>
    </cfif>

    <cfreturn isValid/>

</cffunction>

<cfoutput>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <title>VE Crontask: Update Categories</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
        <link rel="icon" href="favicon.ico" type="image/x-icon"/>
        <link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>
        <style>
            h1, h2 {
                font-family: Courier;
                font-size: 1.2em;
            }

            p {
                font-family: Courier;
                font-size: 1em;
            }
        </style>
    </head>
    <body>
    <h1>Crontask: Update Categories - Started at: #timeformat(VARIABLES.time_started, "H:MM:SS TT")#
        , Completed at: #timeformat(now(), "H:MM:SS TT")#, Duration: #VARIABLES.task_tickinterval# Seconds</h1>
<h2>Results</h2>
<p>
    Truncated Categories table.<br/>
    Added: #VARIABLES.enabledCategoryCount# enabled categories <br/>
    Added: #VARIABLES.disabledCategoryCount# disabled categories <br/>
</p>
</body>
</html>
</cfoutput>