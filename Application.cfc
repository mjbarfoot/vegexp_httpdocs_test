<!---
	Filename: application.cfc ("The application controller")
	Created by:  Matt Barfoot on 25/03/2006 Clearview Webmedia Limited
	Purpose:  Initiates and controlls Vegetarian Express Online Shop
--->
<cfcomponent output="false">

	<!---// *************** Constructor Starts *********************** // --->
	<cfscript>

		this.name 							= "VegExpMySQL_#hash(cgi.server_name)#";
		this.applicationTimeout 			= createTimeSpan(0,0,5,0); //5 mins

		this.sessionManagement 				= true;
		this.sessionTimeout 				= createTimeSpan(0,0,30,0); //30 mins

		this.clientManagement				= true;




	</cfscript>
	<!---// *************** Application Starts *********************** // --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">

		<cfscript>
			//init();
			var appLog="";

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

			<cfscript>
			//Arguments.ApplicationScope.applog.write(timeformat(now(), 'h:mm:ss tt') & " Application: " & this.name & " ended");
			</cfscript>

	</cffunction>

	 <cffunction name="onError" returntype="void" output="true">
		 <cfargument name="Except" required=true/>
		 <cfargument type="String" name = "EventName" required=true/>


		<cfif StructKeyExists(ARGUMENTS.Except, "Rootcause") AND StructKeyExists(ARGUMENTS.Except.RootCause, "type") AND ARGUMENTS.Except.rootcause.type eq "vegexp.custom.friendly">
			<cfsavecontent variable="userError">
			<style>
			* {font-family: "MS Trebuchet", Arial;}
			h1 {margin-left: 1em;}
			p {margin-left: 2em; width: 60%;}
			</style>
			<cfoutput>
			<h1>#ARGUMENTS.Except.RootCause.detail#</h1>
			<p>#ARGUMENTS.Except.RootCause.message#</p>
			</cfoutput>
			<p>Please feel free to <a href="mailto:webmaster@vegetarianexpress.co.uk">send the webmaster an email</a></p>
			<p><img src="/skin/default/vegexp_logo_269x70.gif" alt="Vegetarian Express" /></p>
			</p>

			</cfsavecontent>


		<cfelse>

			<cfsavecontent variable="userError">
			<style>
			* {font-family: "MS Trebuchet", Arial;}
			h1 {margin-left: 1em;}
			p {margin-left: 2em; width: 60%;}
			</style>
			<h1>We are very sorry but something went wrong!</h1>
			<p>Very occasionally these things happen although this site is built and run by the finest technical staff.
			Naturally we get very upset and so we've already sent our webmaster a lengthly email explaining exactly what went wrong.
			The problem should then be fixed as soon as we possibly can.</p>
			<p>Please feel free to <a href="mailto:webmaster@vegetarianexpress.co.uk">send the webmaster an email</a></p>
			<p>Thanks for your patience.</p>
			<p><img src="/skin/default/vegexp_logo_269x70.gif" alt="Vegetarian Express" /></p>
			</p>

			</cfsavecontent>

		</cfif>

      <!--- Watch out for "coldfusion.runtime.AbortException" errors that result from <cfabort> and <cflocation> tags --->
      <cfif StructKeyExists(ARGUMENTS.Except, "Rootcause") AND StructKeyExists(ARGUMENTS.Except.RootCause, "type") AND ARGUMENTS.Except.rootcause.type neq "coldfusion.runtime.AbortException">
		<cfsavecontent variable="debugError">
		<cfoutput>
		<style>
		* {font-family: "MS Trebuchet", Arial;}
		p {border-bottom: 1px solid ##ccc;}
		h1 {font-size: 1.2em;}
		h2 {font-size: 1.1em;}
		h3 {color: blue;}
		</style>
		<h1>Function: #ARGUMENTS.EventName# Message: #ARGUMENTS.Except.RootCause.message#</h1>
		<h2>TYPE</h2>
		<p>#ARGUMENTS.Except.RootCause.type#</p>
		<h2>ERRORCODE</h2>
		<p>Errorcode: #ARGUMENTS.Except.RootCause.errorcode#</p>
		<h2>DETAIL</h2>
		<p>Details: #ARGUMENTS.Except.RootCause.detail#</p>
		<h2>TAGCONTEXT</h2>
		<p><cfdump var="#ARGUMENTS.Except.RootCause.tagContext#"></p>
		<cfif ARGUMENTS.Except.RootCause.type eq "database">
			<h2>DATABASE Specific Error Information</h2>
			<h3>DATASOURCE</h3>
			<cfif StructKeyExists(ARGUMENTS.Except.RootCause, "DataSource")><p>#ARGUMENTS.Except.RootCause.DataSource#</p></cfif>
		<h3>NATIVEERRORCODE</h3>
			<cfif StructKeyExists(ARGUMENTS.Except.RootCause, "NativeErrorCode")><p>#ARGUMENTS.Except.RootCause.NativeErrorCode#</p></cfif>
		<h3>SQLSTATE</h3>
			<cfif StructKeyExists(ARGUMENTS.Except.RootCause, "SQLState")><p>#ARGUMENTS.Except.RootCause.SQLState#</p></cfif>
		<h3>SQL</h3>
			<cfif StructKeyExists(ARGUMENTS.Except.RootCause, "Sql")><p>#ARGUMENTS.Except.RootCause.Sql#</p></cfif>
		<h3>QUERYERROR</h3>
			<cfif StructKeyExists(ARGUMENTS.Except.RootCause, "queryError")><p>#ARGUMENTS.Except.RootCause.queryError#</p></cfif>
		<h3>WHERE</h3>
			<cfif StructKeyExists(ARGUMENTS.Except.RootCause, "where")><p>#ARGUMENTS.Except.RootCause.where#</p></cfif>
		<cfelseif StructKeyExists(ARGUMENTS.Except.RootCause, "type") AND ARGUMENTS.Except.RootCause.type eq  "expression">
		<h2>EXPRESSION Specific Error Information</h2>
		<h3>ErrNumber</h3>
			<p>#ARGUMENTS.Except.RootCause.ErrNumber#</p>
		<cfelseif ARGUMENTS.Except.RootCause.type eq  "missingInclude">
		<h2>MISSINGINCLUDE Specific Error Information</h2>
		<h3>MissingFileName</h3>
			<p>#ARGUMENTS.Except.RootCause.MissingFileName#</p>
		<cfelseif ARGUMENTS.Except.RootCause.type eq  "lock">
		<h2>LOCK Specific Error Information</h2>
		<h3>LockName</h3>
			<p>#ARGUMENTS.Except.RootCause.LockName#</p>
		<h3>LockOperation</h3>
			<p>#ARGUMENTS.Except.RootCause.LockOperation#</p>
		<cfelseif StructKeyExists(ARGUMENTS.Except.RootCause, "type") AND ARGUMENTS.Except.RootCause.type eq  "custom">
		<h2>CUSTOM Specific Error Information</h2>
		<h3>ErrorCode</h3>
			<p>#ARGUMENTS.Except.RootCause.ErrorCode#</p>
		<h3>ExtendedInfo</h3>
			<p>#ARGUMENTS.Except.RootCause.ExtendedInfo#</p>
		<cfelseif StructKeyExists(ARGUMENTS.Except.RootCause, "type") AND ARGUMENTS.Except.RootCause.type eq  "application">
		<h2>APPLICATION Specific Error Information</h2>
		<h3>ExtendedInfo</h3>
			<p>#ARGUMENTS.Except.RootCause.ExtendedInfo#</p>
		</cfif>

		<CFIF isdefined("SESSION")>
		<h1>SESSION INFO</h1>
		<cfdump var="#session#" />
		</cfif>
		</cfoutput>
		</cfsavecontent>

		<cfif isdefined("APPLICATION.showDebug") AND APPLICATION.showDebug>
			<cfoutput>#debugError#</cfoutput>
		<cfelse>
			<cfif isdefined("ARGUMENTS.Except.rootcause.type") AND ARGUMENTS.Except.rootcause.type eq "vegexp.custom.friendly">
				<cfoutput>#userError#</cfoutput>
			<cfelse>
				<cfoutput>#userError#</cfoutput>
				<cfmail to="matt.barfoot@clearview-webmedia.co.uk" from="debug@orders.vegetarianexpress.co.uk"
                        server = "email-smtp.eu-west-1.amazonaws.com"
                        username = "AKIAIRWEPDJDQXQY56EA"
                        password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
                        port="587"
                        useTLS="true"
                        subject="VE Website Error" type="html">
				<cfif isdefined("ARGUMENTS")>
						<cfdump var="#ARGUMENTS#" />
				</cfif>
				<cfif isdefined("SESSION")>
				<cfdump var="#SESSION#" />
				</cfif>
				</cfmail>
			</cfif>

		</cfif>

	<cfelse>

		<cfif ARGUMENTS.EXCEPT.TYPE EQ "vegexp.custom.friendly">
			<cfoutput>
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
			 <head>
			  <title>Vegetarian Express - #ARGUMENTS.Except.detail#</title>
				<style>
				* {font-family: "MS Trebuchet", Arial;}
				</style>
				</head>
			<body>
				<div style="margin-left:auto;margin-right:auto;margin-top:4em; width: 700px;">
					<h1>#ARGUMENTS.Except.detail#</h1>
					<p>#ARGUMENTS.Except.message#</p>
					<p style="margin-bottom:4em;">Please continue using the website by <a href="/index.cfm">clicking here</a>
					<hr />
					<p>Please feel free to <a href="mailto:webmaster@vegetarianexpress.co.uk">send the webmaster an email</a></p>
					<p><img src="/skin/default/vegexp_logo_269x70.gif" alt="Vegetarian Express" /></p>
				</div>
			</body>
			</html>
			</cfoutput>


		<cfelse>
				<cfdump var="#ARGUMENTS.EXCEPT#" />
		</cfif>
	</cfif>


	</cffunction>

	<cffunction name="onSessionStart" returntype="void" output="false">
		<cfscript>
		/*******************************************************************************/
		/* ------------------/ SESSION SCOPE  /--------------------------------------- */
		/*******************************************************************************/

		/*******************************************************************************/
		/* ------------------/ Browser VARS  /---------------------------------------- /*
		/*******************************************************************************/



		SESSION.UserAgent 				= structnew();
		SESSION.UserAgent.id			="Mozilla 5.0";
		SESSION.UserAgent.version		="Any";
		SESSION.UserAgent.CookieAndJSenabled=true; //0 untested or failed false, true
		SESSION.UserAgent.supported		=true;
		SESSION.UserAgent.AjaxSupport	=true;





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

        /* ------------------/ SHOPPER SECURITY   /---------------------------------------- */
        if (NOT isdefined("SESSION.Auth")) {
            APPLICATION.seccontrol.setAuthorisation();
        }


        /* ------------------/ SHOP SETUP   /---------------------------------------- */

		// create our shop with some default properties
		if (not isdefined("session.shop")) {
			session.shop.skin.path = session.skins.default.path;
			session.shop.skin.css = session.skins.common.css & "," & session.skins.default.css;
			session.shop.whereClauseHandler = createObject("component", "cfc.departments.whereClauseHandler").init();
		}

		/* ------------------/ SHOP SETUP   /---------------------------------------- */
		SESSION.comments = createObject("component", "cfc.shopper.comments").init();

		/* ------------------/ SHOPPER SETUP   /---------------------------------------- */
         if (NOT isdefined("SESSION.shopper")) {
            initShopper();
        }

		</cfscript>
	</cffunction>

	<cffunction name="initShopper" returntype="void" output="false">
        <Cfscript>
        //Create our shopper and assign them some default properties and give them some stuff to help them
        if (not isdefined("session.shopper")) {

					// if a basket is defined then our shopper left one behind and didn't finish their shopping
					/*if (isdefined("cookie.VEBasket")) {

						//deserialise basket (stored as string)into Struct and store as my Old Basket
						try {
                            oldBasketContents = deserializeJSON(cookie.VEbasket);
                            // setup the abandoned shopping basket
                            session.shopper.OldBasket = createObject("component", "cfc.model.basket.basket").init(oldBasketContents=oldBasketContents, stockDO=APPLICATION.stockDO,discountRate=SESSION.auth.discountRate);
                        } catch (Any e) {
                           Application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Error converting client basket: " & e.detail);
                        }

                    }*/

                    // give our shopper a new shopping basket and store basket view controller in session scope.
                    session.shopper.basket = createObject("component", "cfc.model.basket.basket").init(stockDO=APPLICATION.stockDO,discountRate=SESSION.auth.discountRate);
                    session.basketContents = createObject("component", "cfc.shopper.basketContents").init();

                    /* ------------------/ filter SETUP   /---------------------------------------- */
					SESSION.shopper.prod_filter="ALL";
					SESSION.shopper.prod_filter_updated=false;


					// give them a shop filter display which tells them which filter they have selected and
					// lets them change it
					session.shopper.shopfilter=createObject("component", "cfc.shopper.shopfilter").init();

					//get some breadcrumbs for our shopper to drop as they move around the shop
					session.shopper.breadcrumb=createObject("component", "cfc.shopper.breadcrumb").init();
        }
        </Cfscript>

    </cffunction>

	<cffunction name="CFonRequestStart" returntype="void" output="false">
	 	<cfif not structKeyExists(session, "userAgent")>
			<cfset onSessionStart()>
		</cfif>
		<cfscript>
		/*******************************************************************************/
		/* ------------------/ REQUEST SCOPE  /--------------------------------------- */
		/*******************************************************************************/

		/* ------------------/ INITIAL VARS  /--------------------------------------- */
		var updateLastRequest=true;

		//redirect used to catch requests which need to be directed elsewhere
		request.redirect = false;
		request.redirectURL = "";

        APPLICATION.maintenancemode=0;

        /* -------------------/ Maintenance Mode ---- */
        if (isdefined("url.bypassMaintenance") AND url.bypassMaintenance eq "1") {
            SESSION.bypassMaintenance = 1;
        }

        if (APPLICATION.maintenancemode and not isdefined("SESSION.bypassMaintenance")) {
            application.shop.util.location("/maintenance.html");
        }


		/* ------------------/ FLUSH   /---------------------------------------------- */
		//Application reload
		if (isdefined("url.reloadApp") AND url.reloadApp eq "0461") {
			for (key in SESSION) {
				structDelete(SESSION, key);
			}
			for (key in APPLICATION) {
				structDelete(APPLICATION, key);
			}
			onApplicationStart();
			onSessionStart();

		}



	    if (isdefined("URL.dump")) {
			dump(URL.dump);
		}


		// for development, include the means to flush the session.
		if (isdefined("url.flush")) {

			for (key in SESSION) {
				structDelete(SESSION, key);
			}

			onSessionStart();

			structDelete(CLIENT, "Basket");
			structDelete(CLIENT, "Auth");
		}


		// Session Flush
		if (isdefined("url.SessionFlush")) {

			for (key in SESSION) {
				structDelete(SESSION, key);
			}

			onSessionStart();
		}


        /* ------------------/ If user has logged out then need to setup default Auth Values.   /---------------------------------------- */
        if (NOT isdefined("SESSION.Auth")) {
            APPLICATION.seccontrol.setAuthorisation();
        }



/* -------------------/ CHECK FOR SHOPPER EXISTENCE - DESTOYED ON LOGOUT THOUGH OTHER SESSION VARIABLES WILL EXIST ---- */
        if (NOT isdefined("SESSION.shopper")) {
            initShopper();
        }

			/* ------------------/ BROWSER DETECTION /------------------------------------- */
				if (NOT SESSION.UserAgent.supported and FindNoCase("notSupported", CGI.SCRIPT_NAME) eq 0) {
					application.shop.util.location("/notSupported.cfm?browser=1");
				} else




				/* ------------------/ LAST REQUEST   /---------------------------------------- */
				//Store the last requested template if it is not basket.cfm so our shopper
				//can click continue shopping" and go the page they came from
				if (NOT isdefined("session.lastRequest")) {
				session.lastRequest="/index.cfm";
				}



				request.nonLastRequestList="basket.cfm,cfc,register.cfm,login.cfm,favourites.cfm,userConfig.cfm";

				for(i=1; i lte listlen(request.nonLastRequestList); i=i+1) {
					if (FindNoCase(ListGetAt(request.nonLastRequestList, i), CGI.SCRIPT_NAME) neq 0) {
						updateLastRequest=false;
						break;
					}
				}

				if (updateLastRequest) session.lastRequest = cgi.SCRIPT_NAME & "?" & cgi.QUERY_STRING;


				// SESSION.Auth is defined and now user is logging in afer clicking "login"
				/* ------------------/ CATCH MANUAL LOGIN  /---------------------------------------- */
                if (isdefined("FORM.userLogin") AND isdefined("FORM.userPass")) {
					APPLICATION.seccontrol.forceLogin();
				}


                /* ------------------/ See if Delivery Day needs refreshing (every 5 mins) /--------- */
				if (SESSION.Auth.DelDay neq "") {
					if (DateDiff("n", LStimeformat(now()), LStimeformat(SESSION.Auth.DelDayExpiry)) lte 0) {
						// invoke delivery component
						delivery=createObject("component", "cfc.departments.delivery");
						// set delivery day and expiry time
						SESSION.Auth.DelDay				= delivery.getDelDay(SESSION.Auth.AccountID);
						SESSION.Auth.DelDayExpiry		= DateAdd("n", 5, now());
					}
				}

				/* ------------------/ See if NextDayDelivery needs refreshing (every 5 mins) /--------- */
				if (SESSION.Auth.NextDayDel neq false) {
					if (DateDiff("n", LStimeformat(now()), LStimeformat(SESSION.Auth.NextDayDelExpiry)) lte 0) {
						// invoke delivery component
						delivery=createObject("component", "cfc.departments.delivery");
						// set delivery day and expiry time
						SESSION.Auth.NextDayDel				= delivery.isValidNextDay(SESSION.Auth.AccountID);
						SESSION.Auth.NextDayDelExpiry		= DateAdd("n", 5, now());
					}
				}

				/* ------------------/ SHOPPER SETUP   /---------------------------------------- */

                if (isdefined("SESSION.shopper.OldBasket")) {
                    if (DateDiff("d", session.shopper.OldBasket.getDateCreated(), DateFormat(now())) lte 7) {
                        if (FindNoCase("oldbasket", CGI.SCRIPT_NAME) eq 0) {
                            request.redirect=true;
                            request.redirectURL="/oldbasket.cfm";
                        }
                    }
                }


				/* ------------------/ PRODUCT FILTER (ALL, ORGANIC Etc.)   /---------------------------------------- */

				//if the shopper wants to view products by classification i.e. vegan, organic etc then apply the product filter
				if (isdefined("url.fldProdFilter")) {
					//  SPECIAL NOTE: session.shopper.prod_filter MAPS DIRECTLY to database column in tblProducts i.e. there is a column called Organic
					//  this direct relationship is used in whereClauseHandler.cfc


					if (url.fldProdFilter neq SESSION.shopper.prod_filter) {
						SESSION.shopper.prod_filter_updated=true;
					}

					switch (url.fldProdFilter) {
					case "Organic": session.shopper.prod_filter="Organic";
								    session.shop.skin.path = session.skins.organic.path;
								    session.shop.skin.css = session.skins.common.css & "," & session.skins.organic.css;
								    ;
								    break;
					case "Vegan": 	session.shopper.prod_filter="Vegan";
								    ;
								    break;
					case "GlutenFree":
								    session.shopper.prod_filter="GlutenFree";
								    ;
								    break;
					default:    	session.shopper.prod_filter="All";
						   			session.shop.skin.path = session.skins.default.path;
						   			session.shop.skin.css = session.skins.common.css & "," & session.skins.default.css;
						   			;
					}
				} else {
					// *************** HOME PAGE FILTER RESET ********* (MB 15/12/2006)
					// check if the user has gone back to the home page
					// reset filters
					if (FindNoCase("index.cfm", CGI.SCRIPT_NAME) OR FindNoCase("favourites.cfm", CGI.SCRIPT_NAME)) {
						session.shopper.prod_filter="All";
						session.shop.skin.path = session.skins.default.path;
						session.shop.skin.css = session.skins.common.css & "," & session.skins.default.css;
					}
				}



				/* ------------------/ CSS Setup:  / ------------------------------------------------ */
				//initialise the tab selected variable, this is overwritten by the template, used
				//instead of CFPARAM
				request.tabSelected="";

				/* ------------------/ CSS Setup:  / ------------------------------------------------ */
				//request variables: defaults for as long as the page request persists
				request.css=session.shop.skin.path & "basket.css";


				/* ------------------/ HANDLER: Switch between Category view and Product List /------ */
				request.show="categories";

				if (isdefined("url.pQ") OR isdefined("url.showProducts")) {
					request.show="products";
				}


				/* ------------------/ HANDLER: Basket Events /------------------------------------- */
				//basket Event handler
				if (isdefined("url.ev") and url.ev eq "basket") {
				    session.shopper.basket.doAction();
				}



				/* ------------------/ REDIRECT ACTION /---------------------------------------- */

				if (request.redirect) {
					application.shop.util.location(request.redirectURL);
				}

			</cfscript>

	</cffunction>

	<cffunction name="XHRonRequestStart" returntype="void" output="false">


	</cffunction>



	<cffunction name="onRequestStart" returntype="void" output="false">
		<cfscript>
			/* ------------------/ FLUSH   /---------------------------------------------- */
			//Application reload
			if (isdefined("url.reloadApp") AND url.reloadApp eq "0461") {
				for (key in SESSION) {
					structDelete(SESSION, key);
				}
				for (key in APPLICATION) {
					structDelete(APPLICATION, key);
				}
				onApplicationStart();
				onSessionStart();

			}
		</cfscript>

		<cfif structKeyExists(getHttpRequestData().headers, "X-Requested-With")>
			<cfif getHttpRequestData().headers["X-Requested-With"] eq "XMLHttpRequest">
				<cfscript>XHRonRequestStart();</cfscript>
			<cfelse>
				<cfscript>CFonRequestStart();</cfscript>
			</cfif>
		<cfelse>
			<cfscript>CFonRequestStart();</cfscript>
		</cfif>
	</cffunction>

	<!---<cffunction name="onRequestEnd" returnType="void" output="false">
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
	</cffunction>--->


	<cffunction name="init" returnType="void" output="false" access="private">

			<cfscript>
			//Application DSN
			APPLICATION.dsn = "vegexp_mysql";

			//Application VARS component
			APPLICATION.var_DO 			= 			createObject("component", "cfc.global.var_do").init();

			//default log type: file
			application.logtype="file";

			switch (cgi.SERVER_NAME) {
			case "orders-test.vegetarianexpress.co.uk":
							  APPLICATION.dsn = "vegexp_mysql_test";
							  application.AppMode="test";
							  application.logpath="/var/www/orders-test.vegetarianexpress.co.uk/web/logs/";
							  application.payGWenabled=false;
	         				  application.sageGWenabled=true;
	         				  application.sageWSendpoint="http://176.35.167.119:90/accountswstest/sage200.asmx";
							  application.sageWSendpointPort="80";
	         				  application.logtype="file";
							  application.showDebug=true;
							  application.orderdebug=false;
							  ;
							  break;
			case "localhost": case "clearview": case "dev.vegetarianexpress.co.uk":
							  application.AppMode="development";
  							  application.logpath="/Users/mbarfoot/VHOSTS/vegexp_httpdocs/logs/";
 	  						  application.payGWenabled=false;
	  						  application.sageGWenabled=true;
	  						  application.sageWSendpoint="http://185.34.81.148/accountsws/sage200.asmx";
	  						  application.sageWSendpointPort="80";
  							  application.logtype="file";
  							  //application.logpath="";
  							  //application.logtype="db";
  							  application.showDebug=true;
  							  application.orderdebug=false;
  							  ;
  							  break;
                // use productionlog to ensure logs are written and orders are placed
                default: 	  application.AppMode="productionlog";
  							  application.logpath="/var/www/orders.vegetarianexpress.co.uk/web/logs/";
							  application.payGWenabled=false;
	         				  application.sageGWenabled=true;
	         				  application.sageWSendpoint="http://176.35.167.119/accountswstest/sage200.asmx";
							  application.sageWSendpointPort="80";
	         				  application.logtype="file";
							  application.showDebug=true;
							  application.orderdebug=false;
							  ;

			}


			//create log files
			APPLICATION.applog 			= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "applog", application.logtype);
			APPLICATION.querylog 		= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "querylog", application.logtype);
			APPLICATION.sageWSlog		= createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "sageWSlog", application.logtype);
			APPLICATION.crontsklog	    = createObject("component", "cfc.logwriter.logwriter").init(application.logpath, "crontsklog", "db");

			//singletons
			APPLICATION.stockDO		= createObject("component", "cfc.departments.do");
			APPLICATION.productsDO		= createObject("component", "cfc.departments.productsDO").init();
			APPLICATION.departments.view=createObject("component", "cfc.departments.view");
			APPLICATION.xwtable = createObject("component", "cfc.xwtable.xwtable").init();
			APPLICATION.secControl = createObject("component", "cfc.security.control");
            APPLICATION.shop.util = createObject("component", "cfc.shop.util");

			//write the application started
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Application: " & this.name & " started" );

			//create a structure to hold logged in users
			application.loggedInUsers = structnew();

			</cfscript>

	</cffunction>

	<cffunction name="dump" access="private" output="true" returntype="void" hint="dumps the specified var">
	<cfargument name="varToDump" required="true" type="string" hint="the name of the var to dump">
			<cfdump var="#evaluate(ARGUMENTS.varToDump)#" />
		<cfabort />
	</cffunction>

</cfcomponent>
