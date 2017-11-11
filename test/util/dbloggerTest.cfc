<cfcomponent displayname="dbloggerTest" hint="Test the Product Component" extends="mxunit.framework.TestCase" output="false">

	<cffunction name="beforeTests" returntype="void" access="public" >
		<cfset mydate = dateadd("d",-1,now()) />

		<cfquery name="myQry" datasource="vegexp_mysql">
		DELETE FROM tblLOG 
		WHERE TS > <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#mydate#" />
		AND MESSAGE LIKE 'This is a test%'
		</cfquery>  
		
		<cfscript>
	 	   
	 	   logService = createObject("component","cfc.util.logService").init("vegexp_mysql");
	 	   TestDBLogger = logService.get("dblogger");
	 	   logQuery = logService.get("logquery");
	 	   
		</cfscript>

	</cffunction>
	
	<cffunction name="infoTest" returntype="void" access="public">
		<cfscript>
			var logText = "This is a test Info log";
			TestDBLogger.info(logText);
			AssertEquals(logText, logQuery.match(days=1, logtype="INFO", logText="#logText#"), "Testing INFO log matches");
		</cfscript>
	</cffunction>

	<cffunction name="errorTest" returntype="void" access="public">
		<cfscript>
			var logText = "This is a test Error log";
			TestDBLogger.error(logText);
			AssertEquals(logText, logQuery.match(days=1, logtype="ERROR", logText="#logText#"), "Testing ERROR log matches");
		</cfscript>
	</cffunction>
	
		<cffunction name="debugTest" returntype="void" access="public">
		<cfscript>
			var logText = "This is a test Debug log";
			TestDBLogger.debug(logText);
			AssertEquals(logText, logQuery.match(days=1, logtype="DEBUG", logText="#logText#"), "Testing DEBUG log matches");
		</cfscript>
	</cffunction>
	
	
		<cffunction name="fatalTest" returntype="void" access="public">
		<cfscript>
			var logText = "This is a test Fatal log";
			TestDBLogger.fatal(logText);
			AssertEquals(logText, logQuery.match(days=1, logtype="FATAL", logText="#logText#"), "Testing FATAL log matches");
		</cfscript>
	</cffunction>
	
	
		<cffunction name="cronTest" returntype="void" access="public">
		<cfscript>
			var logText = "This is a test Cron log";
			TestDBLogger.cron("TestTask",logText);
			AssertEquals(logText, logQuery.match(days=1, logtype="TestTask", logText="#logText#"), "Testing CRON log matches");
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getTest" returntype="void" access="public">
		<cfscript>
			var logText1 = "This is a test that get method returns a multine line string part 1";
			var logText2 = "This is a test that get method returns a multine line string part 2";
			var returnedText = "";
			TestDBLogger.info(logText1);
			TestDBLogger.info(logText2);			
			returnedText = logQuery.get(days=1, logtype="INFO", logText="This is a test that get method returns a multine line string part");
			Assert(FindNoCase("This is a test that get method returns a multine line string part 1", returnedText), "Return two lines from the log file");
			Assert(FindNoCase("This is a test that get method returns a multine line string part 2", returnedText), "Return two lines from the log file");
		</cfscript>
	</cffunction>
	
	
	
	<cffunction name="tearDown" returntype="void" access="public">



	</cffunction> 
	
	
	
</cfcomponent>