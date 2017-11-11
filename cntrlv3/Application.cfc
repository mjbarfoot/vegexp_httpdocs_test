<!--- 
	Filename: Application.cfc ("The  controller")
	Created by:  Matt Barfoot on 05/01/2006 Clearview Webmedia Limited
	Purpose: Control Panel Application
--->
<cfcomponent output="false">
	
	<!---// *************** Constructor Starts *********************** // --->
	<cfscript>
				
		this.name 							= "QSApp_#hash(cgi.server_name)#";
		this.applicationTimeout 			= createTimeSpan(0,0,60,0); //60 mins

		this.sessionManagement 				= true;
		this.sessionTimeout 				= createTimeSpan(0,0,20,0); //20 mins
		
		this.clientManagement				= true;
	</cfscript>
	
	<!---// *************** Application Starts *********************** // --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">

		<cfscript>
			application.id					= createuuid();
			application.start				= now();
			// run the rest of the application setup			
			init();
					
			</cfscript>
		
		<cfreturn true>
	</cffunction>
	
	<!---// *************** Application Ends *********************** // --->
	<cffunction name="onApplicationEnd" returnType="void" output="false">
		<cfargument name="applicationScope" required="true">
		

	</cffunction>
	
	
	<cffunction name="onSessionStart" returntype="void" output="false">
		<cfscript>			
			/*******************************************************************************/
		/* ------------------/ Browser VARS  /---------------------------------------- /*
		/*******************************************************************************/
				
		SESSION.UserAgent 				= structnew();
		SESSION.UserAgent.id			="";
		SESSION.UserAgent.version		="";
		SESSION.UserAgent.CookieAndJSenabled=false; //0 untested or failed false, true
		SESSION.UserAgent.supported		=false;
		SESSION.UserAgent.AjaxSupport	=false;
		
		// Is it ColdFusion?
		if (FindNoCase('ColdFusion',CGI.HTTP_USER_AGENT) neq 0) {
			SESSION.UserAgent.id = "ColdFusion";	
			SESSION.UserAgent.version="7";
			SESSION.UserAgent.supported		=true;
			SESSION.UserAgent.AjaxSupport	=true;
			SESSION.UserAgent.CookieAndJSenabled=true;
				
		} else 		
		
		// Is it CFSCHEDULE? --i.e. cron task scheduler
		if (FindNoCase('CFSCHEDULE',CGI.HTTP_USER_AGENT) neq 0) {
			SESSION.UserAgent.id = "CFSCHEDULE";	
			SESSION.UserAgent.version="7";
			SESSION.UserAgent.supported		=true;
			SESSION.UserAgent.AjaxSupport	=true;
			SESSION.UserAgent.CookieAndJSenabled=true;
				
		} else 		
				
		// is it Internet Explorer? 6 above supported
		if (FindNoCase('MSIE',CGI.HTTP_USER_AGENT) neq 0) {
			SESSION.UserAgent.id = "IE";	
			SESSION.UserAgent.version=mid(CGI.HTTP_USER_AGENT, (FindNoCase('MSIE',CGI.HTTP_USER_AGENT)+5), 3);
			if (SESSION.UserAgent.version gte 6) {
				SESSION.UserAgent.supported		=true;
				SESSION.UserAgent.AjaxSupport	=true;
			}
		
		} else 
		// Is it Firefox
		if (FindNoCase('Firefox',CGI.HTTP_USER_AGENT) neq 0 AND FindNoCase('Gecko',CGI.HTTP_USER_AGENT) neq 0) {
			SESSION.UserAgent.id = "FF";	
			SESSION.UserAgent.version=mid(CGI.HTTP_USER_AGENT, (FindNoCase('Firefox/',CGI.HTTP_USER_AGENT)+8), 3);
			if (SESSION.UserAgent.version gt 1) {
				SESSION.UserAgent.supported		=true;
				SESSION.UserAgent.AjaxSupport	=true;
			}
					
		}
		
		 else {
		// unsupported browser or robot/crawler/spider
			SESSION.UserAgent.supported		= false;
		}
		
		
		/***********************************************************
		VIEW CONFIGURATION
		--COMMON (SKIN AGNOSTIC PARAMS)
		--SKIN (SKIN SPECIFIC PARAMS)
		***********************************************************/
		
		/* ------------------/ CSS /------------------------------- */
		session.view.css="";
		
		/* ------------------/ JAVSCRIPT  /---------------------------------------- */
		// APP INITIALISATION
		session.view.js="#APPLICATION.root#/js/cntrl.js";
		//TACONITE
		session.view.js=session.view.js & "," & "#APPLICATION.root#/js/lib/taconite-client.js,#APPLICATION.root#/js/lib/taconite-parser.js";
		//XWIDGET
		session.view.js=session.view.js & "," & "#APPLICATION.root#/js/xwtable.js,#APPLICATION.root#/js/xwform.js";
		
		/* ------------------/ SKIN (DEFAULT)  /---------------------------------------- */
		session.view.skins.default.path="#APPLICATION.root#/skin/default/";
		session.view.skins.default.css="#APPLICATION.root#/skin/default/layout.css,#APPLICATION.root#/css/xwform.css";
		session.view.skins.default.js="";
		
		
		
		/***********************************************************
		USER SECURITY
		***********************************************************/
		SESSION.Auth = structnew();
		SESSION.Auth.isAuthorised = false;
		SESSION.Auth.loginCount	= 0;
		SESSION.Auth.isBlocked = false;
		
		/***********************************************************
		DEBUG USER SETUP
		***********************************************************/
		if (APPLICATION.debugMode) {
			SESSION.Auth.isAuthorised = true;	
			SESSION.Auth.UserID = "Debug";
			SESSION.Auth.Firstname = "Debug";
			SESSION.Auth.Lastname = "User";
			SESSION.Auth.Email = "matt@barfoot.f2s.com";
			SESSION.Auth.Sec_level = 9;
			//add user id to list of logged in users.
			if  (NOT structKeyExists(APPLICATION.loggedInUsers, SESSION.Auth.UserID)) {
			StructInsert(APPLICATION.loggedInUsers, SESSION.Auth.UserID, 1);
			}
		}
		
		</cfscript>
	</cffunction>
	
		
	<cffunction name="onRequestStart" returntype="void" output="false">
		<cfparam name="URL.reqtype" default="">
		<cfparam name="URL.moduleid" default="Dashboard" />
		<cfparam name="URL.tabid" default="" />
		<cfparam name="URL.action" default="" />
		<cfparam name="URL.message" default="" />
		<cfparam name="URL.result" default="" />
		<cfparam name="URL.nodeID" default="" />
		<cfparam name="URL.nodeAction" default="replace" />
		
		<cfscript>
		/*******************************************************************************/
		/* ------------------/ REQUEST SCOPE  /--------------------------------------- */
		/*******************************************************************************/
		
		/***********************************************************
		APP RELOAD: MUST BE FIRST HANDLER IN ONREQUESTSTART
		***********************************************************/
		if (StructKeyExists(URL, "reloadApp") AND URL.reloadApp eq "777") {
			//delete application vars
			for (key in APPLICATION) {
			StructDelete(APPLICATION, Key);
			}
			StructClear(APPLICATION);
			
			//delete session vars
			for (key in SESSION) {
			StructDelete(SESSION, Key);
			}
			StructClear(SESSION);
			// reinitalise application and session
			onApplicationStart();
			onSessionStart();
		} 
		
		// Session Flush
		if (isdefined("url.SessionFlush")) {
		
			for (key in SESSION) {
				structDelete(SESSION, key);
			}
			
			onSessionStart();
		}
		
		
		/* ------------------/ BROWSER DETECTION /------------------------------------- */
		if (NOT SESSION.UserAgent.supported and FindNoCase("notSupported", CGI.SCRIPT_NAME) eq 0) {
			APPLICATION.ob.util.location("#APPLICATION.root#/notSupported.cfm?browser=1");
		} else  if (SESSION.UserAgent.CookieAndJSenabled eq false AND (FindNoCase("userConfig", CGI.SCRIPT_NAME) eq 0 AND FindNoCase("notSupported", CGI.SCRIPT_NAME) eq 0)) {
			APPLICATION.ob.util.location("#APPLICATION.root#/userConfig.cfm?cookiejs=test");					
		}
		
				
		/***********************************************************
		DEBUG MODE SWITCHER
		***********************************************************/
		if (StructKeyExists(URL, "SetDebugMode") AND URL.SetDebugMode eq "999") {
			APPLICATION.debugmode = true;
		} else if (StructKeyExists(URL, "SetDebugMode") AND URL.SetDebugMode eq "0") {
			APPLICATION.debugmode = false;	
		}
		
		/***********************************************************
		REDIRECTOR (FOR ACTIONS WHICH RESULT IN A REDIRECT)
		***********************************************************/
		//redirect used to catch requests which need to be directed elsewhere
		REQUEST.redirect = false;
		REQUEST.redirectURL = "";
		
		
		/***********************************************************
		CHECK FOR LOGIN
		***********************************************************/
		if (isdefined("form.q_username") AND isdefined("form.q_password")) {	
			//SESSION.Auth.isAuthorised = APPLICATION.ob.security.authorise();		
		}
		
		
		/***********************************************************/
		
		// if authorised user 
		if (SESSION.Auth.isAuthorised) {
		
				
				/***********************************************************
				EVENT HANDLER
				***********************************************************/
				APPLICATION.ob.ev.action();
				
				// if in debug mode copy REQUEST.ACTION struct into the SESSION.Variable
				if (APPLICATION.debugMode AND REQUEST.action.reqtype NEQ "debug") {
					SESSION.debuginfo = structnew();
					SESSION.debuginfo = REQUEST.action;
					SESSION.debuginfo.lastRequest = CGI.SCRIPT_NAME & "?" & CGI.QUERY_STRING;
				}
				
				
				/***********************************************************
				COPY SINGLETONS INTO REQUEST SCOPE
				***********************************************************/  		
				REQUEST.xwtable = APPLICATION.ob.widgets.xwtable;
				
				
				/***********************************************************
				RENDER VIEW
				***********************************************************/  
				
				/* ------------------/ get the Page Content /--------------------------------------- */
				/* *** NOTE: consider making content a struct where each key corresponds to a
				div id in the page template. If the request is remote then the view factory 
				can bundle up all the elements appropriately. 
				
				returntype should be "ANY" for the get Method or alternatively extend viewFactory
				with a cfc that wraps up the calls or maybe use another cfc to loop through the struct and wrap up
				in taconite syntax. Probably use the first method. */
				
				/* ------------------/ PAGE HEADER /--------------------------------------- */
				//moved to renderView
				
				/* ------------------/ PAGE CONTENT /--------------------------------------- */
				REQUEST.view=APPLICATION.ob.renderView.get();
		
		} else {
			
			//not authorised, send to login page 
			REQUEST.VIEW.title = "Welcome to the Control Panel"; 
			REQUEST.ACTION.reqType = "login";	
			
		}

		</cfscript>
	
	</cffunction>	
	
	<cffunction name="onRequestEnd" returnType="void" output="false">
	<cfscript>
		// copy the current contents of out (which is what cfmx will send to the browser at the end of processing)
		pageContent = getPageContext().getOut().getString();
		
		// now we have a copy, clear the out buffer
		getPageContext().getOut().clearBuffer();
		
		// tidy up
		pageContent = reReplace( pageContent, ">[[:space:]]+#chr( 13 )#<", "", "all" );
		
		//quick and dirty to remove pound signs
		//pageContent = reReplace( pageContent, "[&pound;]", "#XMLformat(&pound;)#", "all" );
		
		// send our cleaned content to the browser
		writeOutput( pageContent );
		getPageContext().getOut().flush();
		
		// job done!
		
	</cfscript>	
	</cffunction>
	
	
	<cffunction name="init" returnType="void" output="false" access="private">
		
			<cfscript>
			/***********************************************************
			APPLICATION DSN 
			***********************************************************/
			APPLICATION.dsn = "vegexp_mysql";
			APPLICATION.root = "/cntrlv3"; 
			
			/***********************************************************
			APPLICATION ROOT AND CFC PATHS 
			***********************************************************/
			//convert the root path to a cfc path
			if (APPLICATION.root neq "") {
				//replace all forward slashes after the first with a "."
				APPLICATION.cfcroot	= replace(right(APPLICATION.root, len(APPLICATION.root)-1), "/", ".", "ALL");		
				//check it terminates with a "."
				if (right(APPLICATION.root, len(APPLICATION.root)) neq ".") {
					APPLICATION.cfcroot = APPLICATION.cfcroot & ".";
				} 
			} else {
				APPLICATION.cfcroot = "";
			}
			
			/***********************************************************
			DEBUG MODE SWITCHER
			***********************************************************/
			if (findNoCase("localhost", CGI.SERVER_NAME) OR findNoCase("vegexp.clearview.local", CGI.SERVER_NAME)) {
			APPLICATION.debugmode=true;	
			} else {
			APPLICATION.debugmode=false;	
			}
			
			/***********************************************************
			LOGGING INITIALISATION
			***********************************************************/
			//default
			application.logtype="file";
			
			//server specific log configuration
			switch (cgi.SERVER_NAME) {
			case "localhost": case "clearview": case "vegexp.clearview.local":
							  APPLICATION.AppMode="development";
  							  APPLICATION.logpath="D:\_LOCAL_DATA\vegexp_httpdocs\cntrlv3\logs\";					  
  							  APPLICATION.logtype="file";
  							  APPLICATION.showDebug=true;
  							  APPLICATION.inbound_folderpath = "D:\_LOCAL_DATA\vegexp_httpdocs\xml_inbound\"; 
  							  APPLICATION.outbound_folderpath = "D:\_LOCAL_DATA\vegexp_httpdocs\xml_outbound\"; 
  							  ;
  							  break;
			default: 	      application.AppMode="production";
  							  application.logpath="";
	         				  application.logtype="db";
							  application.showDebug=false;
							  //APPLICATION.inbound_folderpath = "d:\qsaudit\xml_inbound\";
							  //APPLICATION.outbound_folderpath = "d:\qsaudit\xml_outbound\";
							  ;				  	
				
			}
			
			/***********************************************************
			OBJECT CREATION - LOAD SINGLETONS
			-- log files first to record any other failed events
			***********************************************************/
			//create log files
			application.applog 			= createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.logwriter").init(application.logpath, "applog", application.logtype);
			application.querylog 		= createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.logwriter").init(application.logpath, "querylog", application.logtype);
			application.crontsklog	    = createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.logwriter").init(application.logpath, "crontsklog", application.logtype);
			application.sageWSlog       = createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.logwriter").init(application.logpath, "sageWSlog", application.logtype);
			//write the application started
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Application: " & this.name & " started" );
			
			
			//create wddx log
			application.wddxlog	    = createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.logwriter").init(application.logpath, "wddxlog", application.logtype);
			
			// xWidget Path (referenced internally by xWidget Components)
			APPLICATION.xWidget.path = "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.xwidget";
			
			// load APPLICATION objects
			APPLICATION.loggedInUsers = structnew();	
			APPLICATION.ob.ev				=createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.event").init();
			APPLICATION.ob.util				=createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.util");
			APPLICATION.ob.renderView		=createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.renderView").init();
			APPLICATION.ob.widgets.xwtable  =createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.xwidget.xwtable").init();
			APPLICATION.ob.widgets.xwtableRemote  =createObject("component", "#APPLICATION.cfcroot#cfc.couk.clearview-webmedia.xwidget.xwCustomRemote");
			APPLICATION.ob.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();	
			</cfscript>

	</cffunction>
	
	
	
</cfcomponent>	