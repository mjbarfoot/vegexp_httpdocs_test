<!---global vars--->
<cfscript>

// Sage Line 200 ColdFusion DSN
VARIABLES.Sage200_dsn="veSageDb";
VARIABLES.veappdate_dsn = "veappdata";
VARIABLES.FavDB_dsn = "veFavDB";
// Favourites DB
//VARIABLES.FavDB_dsn="veFavDb";
//line break 
VARIABLES.linebreak = "#chr(13)##chr(10)#";
// dev of prod mode?
VARIABLES.isProduction = isProductionServer();

//email params
if (VARIABLES.isProduction) {
	VARIABLES.email_notification_to = "webmaster@vegetarianexpress.co.uk";
	VARIABLES.email_notification_cc = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_from = "crontask@vegetarianexpress.co.uk";
} else {
	VARIABLES.email_notification_to = "matt.barfoot@clearview-webmedia.co.uk";
	VARIABLES.email_notification_cc = "";
	VARIABLES.email_notification_from = "dev-crontask@vegetarianexpress.co.uk";
}

//ftp params
VARIABLES.ftp_username = "vegexp";
VARIABLES.ftp_password = "V1e1G0e2X7p6";
VARIABLES.ftp_server = "ftp.vegetarianexpress.co.uk";
//ftp filename suffix - adds .test if in development mode
if (VARIABLES.isProduction) {
VARIABLES.ftp_filename_suffix = "";
} else {
VARIABLES.ftp_filename_suffix = ".test";
}

</cfscript>

<!--- *** UTILITY FUNCTIONS *** --->
<cffunction name="getLogger" returntype="logwriter" output="false" hint="retuns the appoprtiate logger">
<cfargument type="string" name="logName" required="true">

<cfset var mylogger="">

<cfloop collection="#VARIABLES.LOGGERS#" item="log">
	<cfif VARIABLES.LOGGERS["#log#"].NAME eq ARGUMENTS.logName>
		<cfset myLogger = VARIABLES.LOGGERS["#log#"].logger>
	</cfif>
</cfloop>

<cfreturn mylogger>

</cffunction>


<cffunction name="setStatusComplete" returntype="void" output="false" hint="updates the Cron Task Status">
<cfargument type="struct" name="Loggers" required="true" />
<cfargument type="string" name="crontaskname" required="true" />
<cfargument type="numeric" name="interval" required="true" />

<!--- do something --->


</cffunction>

<cffunction name="setupFileWriters" returntype="void">

<cfscript>
var suppressHeader = 0;
VARIABLES.logpath="e:\SageWebService\ColdFusion8\wwwroot\";					  
VARIABLES.logtype="file";
VARIABLES.showDebug=true;

</cfscript>


<cfloop collection="#VARIABLES.LOGGERS#" item="log">
	<cftry>
		<cffile action = "delete"  file = "#VARIABLES.logpath##VARIABLES.LOGGERS[LOG].name#">
		<cfcatch type="any"></cfcatch>
	</cftry>
	
	<cfscript>	
	if (findNoCase("xml", VARIABLES.LOGGERS[LOG].name) neq 0) {
		suppressHeader=1;
	} else {
		suppressHeader=0;
	}
	
	
		//create log files
	VARIABLES.LOGGERS["#LOG#"].logger = createObject("component", "logwriter").init(VARIABLES.logpath, VARIABLES.LOGGERS["#LOG#"].name, VARIABLES.logtype, suppressHeader);
	</cfscript>
	
</cfloop>


</cffunction>


<!---
<cffunction name="setUpFileWriters_deprecated" returntype="void">

<cfscript>
/***********************************************************
			LOGGING INITIALISATION
***********************************************************/
//default
VARIABLES.logtype="file";


		
//server specific log configuration
switch (lcase(cgi.SERVER_NAME)) {
//development
case "clearview": case "vegexp.clearview.local":
				  VARIABLES.AppMode="development";
				  VARIABLES.logpath="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";					  
				  VARIABLES.logtype="file";
				  VARIABLES.showDebug=true;
				  ;
				  break;
// decomissioned 17/12/12 				  
//case "dbserver": VARIABLES.AppMode="development";
//				  VARIABLES.logpath="e:/ColdFusion8/wwwroot/";					  
//				  VARIABLES.logtype="file";
//				  VARIABLES.showDebug=true;
//				  ;
//				  break;
// production on VEWATFORDSERVER				  
case "sage": VARIABLES.AppMode="development";
				  VARIABLES.logpath="e:/SageWebService/ColdFusion8/wwwroot/";					  
				  VARIABLES.logtype="file";
				  VARIABLES.showDebug=true;
				  ;
				  break;				  
				  
// default don't write logs! will fail is used, servers need to explicity defined above
default: 	      VARIABLES.AppMode="production";
				  VARIABLES.logpath="";
   				  VARIABLES.logtype="file";
				  VARIABLES.showDebug=false;
				  ;				  	
				
}

</cfscript>

<cfif isdefined("variables.logFileName") and variables.logFileName neq "">
<!---delete existing files--->
	<cftry>
		<cffile action = "delete"  file = "#variables.logpath##variables.logFileName#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>


<cfif isdefined("variables.xmlout") and variables.xmlout neq "">
<!---delete existing files--->
	<cftry>
		<cffile action = "delete"  file = "#variables.logpath##variables.xmlout#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<cfif isdefined("variables.xmlout2") and variables.xmlout2 neq "">
	<cftry>
		<cffile action = "delete"  file = "#variables.logpath##variables.xmlout2#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>


<cfif isdefined("variables.datelog")>
	<cftry>
		<cffile action = "delete"  file = "#variables.logpath#datelog.log">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<cfscript>		
//create log files
VARIABLES.logger = createObject("component", "logwriter").init(VARIABLES.logpath, VARIABLES.logFileName, VARIABLES.logtype);

if (isdefined("VARIABLES.xmlOut") AND VARIABLES.xmlOut neq "") {
VARIABLES.xmlOutWriter = createObject("component", "logwriter").init(VARIABLES.logpath, VARIABLES.xmlOut, VARIABLES.logtype);
}


if (isdefined("VARIABLES.xmlOut2") AND VARIABLES.xmlOut2 neq "") {
VARIABLES.xmlOut2Writer = createObject("component", "logwriter").init(VARIABLES.logpath, VARIABLES.xmlOut2, VARIABLES.logtype);
}

if (VARIABLES.logger eq "favourites") {
VARIABLES.dateLog 		= createObject("component", "logwriter").init(VARIABLES.logpath, "dateLog.log", VARIABLES.logtype, true);
}

VARIABLES.isSuccessful=true;


job_tickBegin=getTickCount();
job_tickEnd=0;
job_tickinterval=0;
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# CRONJOB: " & VARIABLES.crontaskName & " started");
VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# Description: "  & VARIABLES.crontaskdesc;
</cfscript>

</cffunction>
--->

<cffunction name="getWDDXfromFilename" output="false" returntype="any" hint="imports a wddx file and returns a query">
<cfargument name="filepath" type="string" reuired="tue" hint="the path to the file">
<cfargument name="filename" type="string" required="true" hint="the name of the file containing the wddx" />
<cfargument name="logger" type="cfc.lopwriter.logwriter" required="true" hint="a logwriter object to write details/errors to">
<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var wddxFile = "";
var ret=false; 
</cfscript>

<!--- read the file --->
<cftry>
	<cffile action="read" charset="utf-8" file="#ARGUMENTS.filepath##ARGUMENTS.filename#" variable="wddxfile" />
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	ARGUMENTS.logger.write("#timeformat(now(), 'H:MM:SS')# Success: getWDDXfromFilename - Read #ARGUMENTS.FILENAME# from #ARGUMENTS.filepath# (#tickinterval# s)");
	ret=true;
	</cfscript>
	
<cfcatch type="any">
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	ARGUMENTS.logger.write("Error: getWDDXfromFilename - Failed to open #ARGUMENTS.FILENAME# from #ARGUMENTS.filepath# (#tickinterval# s)");
	ret=false;
	</cfscript>
	
</cfcatch>
</cftry>

<!--- convert from wddx --->
<cfif wddxfile neq "">
<cftry>
	<cfscript>
	tickBegin=getTickCount();
	tickEnd=0;
	tickinterval=0;
	</cfscript>
	
	<cfwddx action="wddx2cfml" input="#wddxfile#" output="ret" />
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	ARGUMENTS.logger.write("#timeformat(now(), 'H:MM:SS')# Success: Converted #ARGUMENTS.FILENAME# to CFML (#tickinterval# s)");
	ret=true;
	</cfscript>
	
<cfcatch type="any">
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	ARGUMENTS.logger.write("Error: getWDDXfromFilename - Failed to covert #ARGUMENTS.FILENAME# to CFML (#tickinterval# s)");
	ret=false;
	</cfscript>

</cfcatch>
</cftry>
</cfif>


<cfreturn ret />
</cffunction>

<cffunction name="ftpToWebServer" output="false" returntype="boolean" hint="ftps a file to the specified server">
<cfargument name="filename" required="true" type="string" hint="the name of the file to send to the server">
<cfargument name="logger" required="true" type="logwriter" hint="an instance of a logwriter to write to">
<cfargument name="saveAsFilename" required="false" type="string" default="#ARGUMENTS.filename#" />
<cfscript> 
var ret = false;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
</cfscript>

<!--- <cftry> --->
	<cfftp action = "open" username = "#VARIABLES.ftp_username#" connection = "veWebServer" password = "#VARIABLES.ftp_password#" server = "#VARIABLES.ftp_server#" stopOnError = "Yes"  timeout="3600" />
	<cfftp connection = "veWebServer" action = "CHANGEDIR"   stopOnError = "Yes"  directory = "/web/xml_inbound/" />
	<cfftp connection = "veWebServer" action = "putFile" name = "uploadFile" transferMode = "ascii"  localFile = "#VARIABLES.logpath##ARGUMENTS.FILENAME#" remoteFile = "#lcase(ARGUMENTS.saveAsFilename)##VARIABLES.ftp_filename_suffix#" failIfExists="No" />
	<cfftp action = "close" connection = "veWebServer" stopOnError = "Yes">
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	logger.write("#timeformat(now(), 'H:MM:SS')# Success: ftpToWebServer - FTP: Uploaded #ARGUMENTS.FILENAME# to /web/xml_inbound/#lcase(ARGUMENTS.saveAsFilename)##VARIABLES.ftp_filename_suffix# (#tickinterval# s)");
	ret=true;
	</cfscript>
<!--- <cfcatch type="any">
	<cfrethrow />	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	logger.write("Error: ftpToWebServer - Failed to upload #ARGUMENTS.FILENAME# to /web/xml_inbound/#lcase(ARGUMENTS.saveAsFilename)##VARIABLES.ftp_filename_suffix# (#tickinterval# s)");
	ret=false;
	</cfscript>
</cfcatch>
</cftry>  --->
<cfreturn ret>

</cffunction>

<cffunction name="isProductionServer" output="false" returntype="boolean" hint="Checks if task should be set to execute in development mode or production mode">
<cfscript>
switch (cgi.SERVER_NAME) {
		case "clearview": case "vegexp.clearview.local": 
				  return false;
  							  ;
  				  		 break;
		
		default:   return true;
							  ;				  			
}
</cfscript>
</cffunction>

<cffunction name="returnFormattedQueryError" output="false" returntype="String" hint="returns a consistent error message from a database catch object">
<cfargument name="fn" type="string" required="true" hint="the name of the function that errored" />
<cfargument name="tbl" type="string" required="true" hint="the name of the database table on which the query was performed" />
<cfargument name="op" type="string" required="true" hint="the type of operation being performed">
<cfargument name="catchOb" type="Any" required="true" hint="the database catch object holding the error info" />
<cfargument name="customText" type="string" required="false" hint="anything else you want to add" default=""/>

<cfscript>
var error_text="";
var error_custom=ARGUMENTS.customText;
var error_values="";
error_text = "Error: #ARGUMENTS.fn# table:#ARGUMENTS.tbl#. #ARGUMENTS.op# Failed.";
if (len(error_custom)) {
	error_text = error_text & " #error_custom# .";
}
error_text = error_text &  " SQL error debug: ";
</cfscript>

<cfif isdefined("ARGUMENTS.catchOb.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
<cfif isdefined("ARGUMENTS.catchOb.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
<cfif isdefined("ARGUMENTS.catchOb.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	
<cfif isdefined("ARGUMENTS.catchOb.queryError")><cfset error_text = error_text &  " " & cfcatch.queryError /></cfif>

<!--- return error and replace any linefeeds, breaks --->
<cfreturn ReReplace(error_text, "\n|\r", " ", "ALL") />

</cffunction>

<cffunction name="abortTask" output="false" returntype="void" hint="writes error, emails log file and does a CFABORT">
<cfargument name="logger" type="logwriter" required="true">
<cfargument name="logfilename" type="string" required="true">	
<cfscript>
	ARGUMENTS.logger.write("#timeformat(now(), 'H:MM:SS')# Failed - Task Ended");
	emailLogFiles(isComplete=false, logFileName=ARGUMENTS.logFileName, crontaskName=VARIABLES.cronTaskName);
</cfscript>
<cfabort />

</cffunction>


<cffunction name="emailLogFiles" output="false" returntype="void" hint="sends a report to the designated email addresses at vegetarianexpress">

    <cfargument name="isComplete" type="Boolean" required="true" hint="true/false whether the task completed successfully or not">
    <cfargument name="logFileName" type="string" required="true" hint="the name of the log file to be emailed">
    <cfargument name="crontaskName" type="string" required="true" hint="the subject of the email">

    <cfset VARIABLES.email_notification_to="rogersechiari@vegexp.co.uk, philipcrawford@vegexp.co.uk"/>
    <cfset VARIABLES.email_notification_cc="matt.barfoot@clearview-webmedia.co.uk"/>

    <cfif VARIABLES.email_notify>
    <cfif ARGUMENTS.isComplete>
        <cfmail to="#VARIABLES.email_notification_to#" 
                cc="#VARIABLES.email_notification_cc#" 
                from="crontask@orders.vegetarianexpress.co.uk" 
                subject="VE #ARGUMENTS.crontaskName# Successful" 
                username = "AKIAIRWEPDJDQXQY56EA"
                password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
                port="587"
                useTLS="true"
                type="text">
        <cfmailparam file = "#VARIABLES.logpath##ARGUMENTS.logFileName#_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
        Crontask: #ARGUMENTS.crontaskName#  Successful. Attached is log file.
        </cfmail>
            
            
    <cfelse>
        <cfif VARIABLES.email_notification_cc neq "">
            <cfmail to="#VARIABLES.email_notification_to#" to="#VARIABLES.email_notification_to#" 
                cc="#VARIABLES.email_notification_cc#" 
                from="crontask@orders.vegetarianexpress.co.uk" 
                subject="ERROR: VE #ARGUMENTS.crontaskName# - see Attached CronLog"
                username = "AKIAIRWEPDJDQXQY56EA"
                password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
                port="587"
                useTLS="true"
                type="text"  type="text">
            <cfmailparam file = "#VARIABLES.logpath##ARGUMENTS.logFileName#_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
            Crontask: #ARGUMENTS.crontaskName#  Errored. Please read attached log file and take action if required.
            </cfmail>
        <cfelse>
                <cfmail to="#VARIABLES.email_notification_to#" to="#VARIABLES.email_notification_to#" 
                from="crontask@orders.vegetarianexpress.co.uk" 
                subject="ERROR: VE #ARGUMENTS.crontaskName# - see Attached CronLog"
                username = "AKIAIRWEPDJDQXQY56EA"
                password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
                port="587"
                useTLS="true"
                type="text"  type="text">
            <cfmailparam file = "#VARIABLES.logpath##ARGUMENTS.logFileName#_#dateformat(now(), 'yyyy-mm-dd')#.log" type="text/plain">
            Crontask: #ARGUMENTS.crontaskName#  Errored. Please read attached log file and take action if required.
            </cfmail>
        </cfif>	
    </cfif>
    </cfif>
</cffunction>