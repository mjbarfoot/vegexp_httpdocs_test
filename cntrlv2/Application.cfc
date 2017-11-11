<!--- 
	Filename: Application.cfc ("The  controller")
	Created by:  Matt Barfoot on 05/01/2006 Clearview Webmedia Limited
	Purpose: Control Panel Application
--->
<cfcomponent output="false">
	
	<!---// *************** Constructor Starts *********************** // --->
	<cfscript>
				
		this.name 							= "VegExpMySQL_#hash(cgi.server_name)#_cntrl";
		this.applicationTimeout 			= createTimeSpan(0,0,30,0); //5 mins

		this.sessionManagement 				= true;
		this.sessionTimeout 				= createTimeSpan(0,0,30,0); //30 mins
		
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
		/* ------------------/ SESSION SCOPE  /--------------------------------------- */
		/*******************************************************************************/
		
		/* ------------------/ SKIN SETUP   /---------------------------------------- */
		
			//common
			session.skins.common.css="/css/import.css,/css/common.css";
			
			//default skin
			session.skins.default.path="/skin/default/";
			session.skins.default.css="/skin/default/layout.css";
  			
  			/*if Internet Explorer
  			if (SESSION.UserAgent.id eq "IE" AND SESSION.UserAgent.version gte 7) {
  				session.skins.default.css=session.skins.default.css & "," & "/skin/default/ie7fix.css";
  			}*/
  			
  			//organic skin
  			session.skins.organic.path="/skin/organic/";
  			session.skins.organic.css="/skin/organic/layout.css";
			
			/*
			// if Internet Explorer
			if (SESSION.UserAgent.id eq "IE" AND SESSION.UserAgent.version gte 7) {
  				session.skins.organic.css=session.skins.organic.css & "," & "/skin/organic/ie7fix.css";
  			}*/
		
		/* ------------------/ SHOP SETUP   /---------------------------------------- */
		
		// create our shop with some default properties
		if (not isdefined("session.shop")) {
			session.shop.skin.path = session.skins.default.path;
			session.shop.skin.css = session.skins.common.css & "," & session.skins.default.css;	
						


		}
		
		</cfscript>
	</cffunction>
	
		
	<cffunction name="onRequestStart" returntype="void" output="false">
		<cfparam name="URL.reqtype" default="">
		<cfparam name="URL.moduleid" default="home" />
		<cfparam name="URL.tabid" default="" />
		<cfparam name="URL.action" default="" />
		<cfparam name="URL.nodeID" default="" />
		<cfparam name="URL.nodeAction" default="replace" />
		
		<cfscript>
		/*******************************************************************************/
		/* ------------------/ REQUEST SCOPE  /--------------------------------------- */
		/*******************************************************************************/
		
		/* ------------------/ INITIAL VARS  /--------------------------------------- */
		REQUEST.css="";
		
		/***********************************************************
		App reload: Must be first handler in OnRequestStart
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
				
		/***********************************************************
		DEBUG MODE SWITCHER
		***********************************************************/
		if (StructKeyExists(URL, "SetDebugMode") AND URL.SetDebugMode eq "999") {
			APPLICATION.debugmode = true;
		}
				
		
		/***********************************************************
		REDIRECTOR (FOR ACTIONS WHICH RESULT IN A REDIRECT)
		***********************************************************/
		//redirect used to catch requests which need to be directed elsewhere
		REQUEST.redirect = false;
		REQUEST.redirectURL = "";

		/* ------------------/ EVENT HANDLER  /--------------------------------------- */
		APPLICATION.ev.action();
				
				
		/* ------------------/ TEMP /--------------------------------------- */		
		//copy xwtable into request cope
		request.xwtable = APPLICATION.widgets.xwtable;
		
		/* ------------------/ get the Page Content /--------------------------------------- */
		/* *** NOTE: consider making content a struct where each key corresponds to a
		div id in the page template. If the request is remote then the view factory 
		can bundle up all the elements appropriately. 
		
		returntype should be "ANY" for the get Method or alternatively extend viewFactory
		with a cfc that wraps up the calls or maybe use another cfc to loop through the struct and wrap up
		in taconite syntax. Probably use the first method. */
		
		REQUEST.view=APPLICATION.viewFactory.get();
		
		
		
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
			//Application DSN
			APPLICATION.dsn = "vegexp_mysql";
			
			//debug mode?
			if (findNoCase("localhost", CGI.SERVER_NAME)) {
			APPLICATION.debugmode=true;	
			}
			
			
						//setup  log mode
			/* servers:
			Development Server: localhost
			Staging Server: ?
			Production Server: ? */
			
			//default log type: file
			application.logtype="file";
			
			switch (cgi.SERVER_NAME) {
			case "localhost": case "clearview": application.AppMode="development";
  							  application.logpath="D:\JRun4\servers\vegexpMySQL\cfusion-war\logs\";
 	  						  application.payGWenabled=false;
	  						  application.sageGWenabled=true; 						  
  							  application.logtype="file";
  							  //application.logpath="";
  							  //application.logtype="db";
  							  application.showDebug=true;
  							  ;
  							  break;
			case "vegexp.clearview-webmedia.co.uk": application.AppMode="staging";
  							  						application.logpath="";
  							  						application.payGWenabled=false;
  							  						application.sageGWenabled=true;
  							  						application.showDebug=true;
  							  						;
  							  						break;						
			case "vpsserver": application.AppMode="staging";
  							  application.logpath="";
  							  application.payGWenabled=false;
	  						  application.sageGWenabled=false;
  							  application.showDebug=false;
  							  ;
  							  break;	
			default: 	      application.AppMode="production";
  							  application.logpath="";
							  application.payGWenabled=false;
	         				  application.sageGWenabled=true;
	         				  application.logtype="db";
							  application.showDebug=false;
							  ;				  	
				
			}
			
			
			//create log files
			application.applog 			= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "applog", application.logtype);
			application.querylog 		= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "querylog", application.logtype);
			application.sageWSlog		= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "sageWSlog", application.logtype);
			application.crontsklog	    = createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "crontsklog", application.logtype);
            application.shop.util = createObject("component", "cfc.shop.util");
			//write the application started
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Application: " & this.name & " started" );
			
			
			
			// load WIDGET controllers
			//APPLICATION.widgets = structnew();			
			//APPLICATION.widgets.xwtable  =createObject("component", "cfc.xwtable.xwtable").init();
			
			// load APPLICATION objects
			APPLICATION.ev			=createObject("component", "cfc.cntrl.eventv2").init();
			APPLICATION.viewFactory	=createObject("component", "cfc.cntrl.viewFactory").init();
			APPLICATION.widgets.xwtable  =createObject("component", "cfc.xwtable.xwtable").init();
			</cfscript>

	</cffunction>
	
	
	
</cfcomponent>	