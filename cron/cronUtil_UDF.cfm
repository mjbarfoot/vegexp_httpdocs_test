
<!--- *** UTILITY FUNCTIONS *** --->
<cffunction name="getWDDXfromFilename" output="false" returntype="any" hint="imports a wddx file and returns a query">
<cfargument name="filepath" type="string" reuired="tue" hint="the path to the file">
<cfargument name="filename" type="string" required="true" hint="the name of the file containing the wddx" />
<cfargument name="logger" type="cfc.logwriter.logwriter" required="true" hint="a logwriter object to write details/errors to">
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
	ARGUMENTS.logger.write("Success: getWDDXfromFilename - Read #ARGUMENTS.FILENAME# from #ARGUMENTS.filepath# (#tickinterval# s)", "INFO");
	ret=true;
	</cfscript>
	
<cfcatch type="any">
	<cfrethrow/>
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	ARGUMENTS.logger.write("Error: getWDDXfromFilename - Failed to open #ARGUMENTS.FILENAME# from #ARGUMENTS.filepath# (#tickinterval# s)","ERROR");
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
	</cfscript>
	
<cfcatch type="any">
	<cfrethrow/>
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

<cffunction name="doSimpleQuery" output="false" returntype="any" hint="Performs simple queries with some helpful error trapping">
<cfargument name="sqlStmt" type="string" required="true" hint="the SQL to execute">	

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false; 
</cfscript>

<!--- combine order details with items ordered --->
<cftry>
	<cfquery name="q" datasource="#APPLICATION.DSN#" result="qRes">
	#ARGUMENTS.sqlStmt#
	</cfquery>
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & "Success: soSimpeQuery SQL: #ARGUMENTS.sqlStmt# - selected #q.recordcount# records.  (#tickinterval# s)");
	ret=q;
	</cfscript> 
	
<cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("doSimpleQuery", "#ARGUMENTS.sqlStmt#",  "", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	VARIABLES.logger.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


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

<cftry>
	<cfftp action = "open" username = "#VARIABLES.ftp_username#" connection = "veWebServer" password = "#VARIABLES.ftp_password#" server = "#VARIABLES.ftp_server#" stopOnError = "Yes"  timeout="3600" />
	<cfftp connection = "veWebServer" action = "CHANGEDIR"   stopOnError = "Yes"  directory = "/httpdocs/xml_inbound/" />
	<cfftp connection = "veWebServer" action = "putFile" name = "uploadFile" transferMode = "ascii"  localFile = "#VARIABLES.logpath##ARGUMENTS.FILENAME#" remoteFile = "#lcase(ARGUMENTS.saveAsFilename)##VARIABLES.ftp_filename_suffix#" failIfExists="No" />
	<cfftp action = "close" connection = "veWebServer" stopOnError = "Yes">
	
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	logger.write("#timeformat(now(), 'H:MM:SS')# Success: ftpToWebServer - FTP: Uploaded #ARGUMENTS.FILENAME# to /httpdocs/xml_inbound/#lcase(ARGUMENTS.saveAsFilename)##VARIABLES.ftp_filename_suffix# (#tickinterval# s)");
	ret=true;
	</cfscript>
<cfcatch type="any">
	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	logger.write("Error: ftpToWebServer - Failed to upload #ARGUMENTS.FILENAME# to /httpdocs/xml_inbound/#lcase(ARGUMENTS.saveAsFilename)##VARIABLES.ftp_filename_suffix# (#tickinterval# s)");
	ret=false;
	</cfscript>
</cfcatch>
</cftry> 
<cfreturn ret>

</cffunction>

<cffunction name="isProductionServer" output="false" returntype="boolean" hint="Checks if task should be set to execute in development mode or production mode">
<cfscript>
switch (cgi.SERVER_NAME) {
		case "clearview": case "dev.vegetarianexpress.co.uk": case "vegexp.clearview.local": 
				  return false;
  							  ;
  				  		 break;
		
		default:   return true;
							  ;				  			
}
</cfscript>
</cffunction>

<cffunction name="getXML" returntype="xml" access="public">
		<cfargument name="x" type="string" required="true" />
		<cfset var myXmlDoc = replace(ARGUMENTS.x,'<?xml version="1.0" encoding="utf-8"?>','')/>
		<cfset var r = ""/>
        <cfxml variable="r">
			<cfoutput>#myXmlDoc#</cfoutput>
		</cfxml>
		<cfreturn r/>
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

<cfif isdefined("ARGUMENTS.catchOb.Detail")><cfset error_text = error_text & cfcatch.Detail /></cfif>
<cfif isdefined("ARGUMENTS.catchOb.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
<cfif isdefined("ARGUMENTS.catchOb.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
<cfif isdefined("ARGUMENTS.catchOb.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>	


<!--- return error and replace any linefeeds, breaks --->
<cfreturn ReReplace(error_text, "\n|\r", " ", "ALL") />

</cffunction>

<cffunction name="abortTask" output="false" returntype="void" hint="writes error, emails log file and does a CFABORT">
<cfargument name="logger" type="cfc.logwriter.logwriter" required="true">
	
<cfscript>
	ARGUMENTS.logger.write("#timeformat(now(), 'H:MM:SS')# Failed - Task Ended");
	emailLogFiles(isComplete=false, logFileName=VARIABLES.logFileName, crontaskName=VARIABLES.cronTaskName);
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
        <cfmailparam file = "#APPLICATION.crontsklog.getFilepath()#" type="text/plain">
        Crontask: #ARGUMENTS.crontaskName#  Successful. Attached is log file.
        </cfmail>
            
            
    <cfelse>
        <cfif VARIABLES.email_notification_cc neq "">
            <cfmail to="#VARIABLES.email_notification_to#" 
                cc="#VARIABLES.email_notification_cc#" 
                from="crontask@orders.vegetarianexpress.co.uk" 
                subject="ERROR: VE #ARGUMENTS.crontaskName# - see Attached CronLog"
                username = "AKIAIRWEPDJDQXQY56EA"
                password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
                port="587"
                useTLS="true"
                type="text">
            <cfif fileExists(APPLICATION.crontsklog.getFilepath())>
		        <cfmailparam file = "#APPLICATION.crontsklog.getFilepath()#" type="text/plain">
		    </cfif>    
		        Crontask: #ARGUMENTS.crontaskName#  Errored. Please read attached log file and take action if required.
		        </cfmail>
        <cfelse>
                <cfmail to="#VARIABLES.email_notification_to#" 
                from="crontask@orders.vegetarianexpress.co.uk" 
                subject="ERROR: VE #ARGUMENTS.crontaskName# - see Attached CronLog"
                username = "AKIAIRWEPDJDQXQY56EA"
                password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
                port="587"
                useTLS="true"
                type="text">
           <cfif fileExists(APPLICATION.crontsklog.getFilepath())> 
           		<cfmailparam file ="#APPLICATION.crontsklog.getFilepath()#" type="text/plain">
           </cfif>
            Crontask: #ARGUMENTS.crontaskName#  Errored. Please read attached log file and take action if required.
            </cfmail>
        </cfif>	
    </cfif>
    </cfif>
</cffunction>


<cffunction name="rowCopy" returntype="struct" output="No">
    <cfargument name="q" required="Yes" type="query">
    <cfargument name="rowindex" required="Yes" type="numeric">
    <cfset var ret = structNew()>

    <!--- Loop over the columnlist and get the rowindex needed. --->
    <cfloop list="#q.columnlist#" index="column">
     <cfset ret[column] = q[column][rowindex]>
    </cfloop>

    <cfreturn ret>
</cffunction> 