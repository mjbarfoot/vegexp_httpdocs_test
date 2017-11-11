<!--- 
	Component: do.cfc
	File: /cfc/security/do.cfc
	Description: security data object for access to persistent storage
	Author: Matt Barfoot
	Date: 24/04/20006
	Revisions:
	--->
	
<cfcomponent name="do" displayname="do" output="false" hint="security data object for access to persistent storage">

<cffunction name="addAccount" access="public" hint="Adds a registration account">
<cfargument name="formObj" required="true" type="struct" />

<cfset var qParams="" />

<!--- <cftry>  --->
	<cfquery name="qryAddAccount" datasource="#APPLICATION.dsn#" result="myResult">
	INSERT INTO tblUsers
	(AccountID, AccountOnHold, firstName, lastName, company,  telnum, emailAddress, contactPref, accPass, building, postcode, line1, line2, line3, town, county,
	viewFC, AllowEmailPost, creditAccount, CreditAccountAuth, AuthLevel, CreateDate, CreateTime)
	VALUES (
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.AccountID#">,
	<cfqueryparam cfsqltype="cf_sql_smallint" value="0">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.firstName#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.lastName#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.clientcompany#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.telnum#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.emailAddress#">,
	<!--- Has contact preference been provided --->
	<cfif isdefined("formObj.contactPref")>
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.contactPref#">,
	<cfelse>
		<cfqueryparam cfsqltype="cf_sql_varchar" value="None given">,
	</cfif>
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(formObj.accPass)#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.building#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.postcode#">,
	<cfif isdefined("formObj.line1")>
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.line1#">,
	<cfelse>
	'',
	</cfif>
	<cfif isdefined("formObj.line2")>
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.line2#">,
	<cfelse>
	'',
	</cfif>
	<cfif isdefined("formObj.line3")>
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.line3#">,
	<cfelse>
	'',
	</cfif>
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.town#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.county#">,
	<cfif formObj.viewFC>
	TRUE
	<cfelse>
	FALSE
	</cfif>,
	<!--- Allow email and post (checked is "NO") --->
	<cfif isdefined("formObj.PrivEmailPost")>
		FALSE,
	<cfelse>
		TRUE,
	</cfif>
	<!--- Apply for credit account --->
	<cfif isdefined("formObj.creditAccount")>
		TRUE,
	<cfelse>
		FALSE,
	</cfif>
	<!--- Credit account authorised: Always defaults to FALSE --->
	FALSE,
	<!--- Authorisation Level--->
	<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
	<!--- Record date and time created --->
	<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(now(), 'dd/mm/yyyy')#">,
	<cfqueryparam cfsqltype="cf_sql_time" value="#timeformat(now(), 'HH:MM TT')#">
	)
	
	</cfquery>

	<cfscript>
	//write details to log
	application.querylog.write("#timeformat(now(), 'H:MM:SS')#	SecDO:addAccount completed in #myResult.ExecutionTime# ms");
	querytxt="#timeformat(now(), 'H:MM:SS')# SQL: #myResult.sql# PARAMS: "; 
	 // loop from name/value pairs for cfqueryparam values
	for (i=1; i lte arraylen(myResult.sqlparameters); i=i+1) {
	querytxt = querytxt & "{#i#:#myResult.sqlparameters[i]#} ";
	}
	application.querylog.write(querytxt);
	</cfscript>
<cfreturn true />	
<!--- 
<cfcatch type="database">
	
	<cfscript>
	application.querylog.write("#timeformat(now(), 'H:MM:SS')#	SecDO:addAccount errored in #myResult.ExecutionTime# ms");
	querytxt="#timeformat(now(), 'H:MM:SS')# message: #cfcatch.message# detail:  #cfcatch.detail# 
	SQLState: #cfcatch.SQLState# Sql: #cfcatch.Sql# queryError: #cfcatch.queryError# query Parameters: ";
	// loop from name/value pairs for cfqueryparam values
	for (i=1; i lte arraylen(cfcatch.where); i=i+1) {
	querytxt = querytxt & "{#i#:#cfcatch.where[i]#} ";
	}
	application.querylog.write(querytxt);
	</cfscript>
	
	<cfreturn false />
</cfcatch>
</cftry>  --->
</cffunction>			

<cffunction name="updateAccount" access="public">
<cfargument name="formObj" required="true" type="struct" />
	<cfquery name="qryUpdateAccount" datasource="#APPLICATION.dsn#">
	UPDATE tblUsers
	SET firstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.firstName#">, 
		lastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.lastName#">, 
		telnum = <cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.telnum#">, 
		emailAddress = <cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.emailAddress#">, 
		contactPref = <!--- Has contact preference been provided --->
					 <cfif isdefined("formObj.contactPref")>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#formObj.contactPref#">
					 <cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="None given">
					 </cfif>, 
		<!--- ************** PASSWORD CHECK NEEDS TO BE MORE SECURE --->
		<cfif formObj.accPassNew neq "">
		accPass =    <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(formObj.accPassNew)#">,
		</cfif>			
		AllowEmailPost = <!--- Allow email and post (checked is "NO") --->
						<cfif isdefined("formObj.PrivEmailPost")>
							FALSE
						<cfelse>
							TRUE
						</cfif>, 
		<cfif isdefined("FORMOBJ.ISCOOKIEOK")>
			IsCookieOK = <cfqueryparam cfsqltype="cf_sql_varchar" value="1">,	
		<cfelse>
			IsCookieOK = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">,	
		</cfif>			
		LastUpdatedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 
		LastUpdatedTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
   		LastUpdatedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.Auth.Firstname# #SESSION.Auth.Lastname#">
	WHERE AccountID = 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.Auth.AccountID#">
	AND UserID = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.Auth.UseriD#">			
	</cfquery>

<cfscript>
//AccountID, Firstname, Lastname, viewFC, AuthLevel, CreditAccountAuth 
SESSION.Auth.firstname 			= formObj.Firstname;
SESSION.Auth.lastname 			= formObj.Lastname;
SESSION.Auth.Telnum				= formObj.Telnum;
SESSION.Auth.EmailAddress		= formObj.EmailAddress;
if (not isdefined("FORMOBJ.ISCOOKIEOK")) {
	SESSION.Auth.IsCookieOK	=0;
	structDelete(CLIENT, "Basket");
	structDelete(CLIENT, "Auth");	
}
</cfscript>

<cfreturn true />

</cffunction>


<cffunction name="updateCookiePreference" access="public" hint="Updates cookie preference" returntype="any">
<cfargument name="AccountID" required="true" type="string" />
<cfargument name="IsCookieOK" required="true" type="boolean">
<cfset var ret = false />	
	
<cftry>
	<cfquery name="q" datasource="#APPLICATION.dsn#">
	UPDATE tblUsers
	SET IsCookieOK = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.IsCookieOK#">
	WHERE AccountID = '#ARGUMENTS.ACCOUNTID#'
	</cfquery>

	<cfset ret = true/>
	
<cfcatch type="database">
	<cfset ret = false/>
</cfcatch>

</cftry>	

<cfreturn ret/>

</cffunction>



<cffunction name="getUserDetails" access="public" hint="Adds a registration account" returntype="any">
<cfargument name="userLogin" required="true" type="string" />
<cfargument name="userPass" required="true" type="string" />

<!--- <cfthrow detail="ARGUMENTS.userLogin: #ARGUMENTS.userLogin# ARGUMENTS.userPass: #ARGUMENTS.userPass#"> --->

	<cfquery name="qryGetUserDetails" datasource="#APPLICATION.dsn#">
	SELECT UserID, AccountID, Firstname, Lastname, Telnum, Company, discountRate, EmailAddress, viewFC, AuthLevel, CreditAccountAuth, Postcode, PriceBand, isCookieOK
	FROM tblUsers
	WHERE AccountID = '#ARGUMENTS.userLogin#' 
	AND  accPass = '#HASH(ARGUMENTS.userPass)#'
	</cfquery>
	
<cfif qryGetUserDetails.recordCount eq 1>
	<cfreturn qryGetUserDetails />
<cfelse>
	<cfreturn "failed" />
</cfif>
</cffunction>

<cffunction name="setAccountPassword" access="public" returntype="boolean" hint="updates an account password">
<cfargument name="AccountID" required="true" type="string" />
<cfargument name="password" required="true" type="string" />

<cfset var ret = false />	
	
<cftry>
	<cfquery name="q" datasource="#APPLICATION.dsn#">
	UPDATE tblUsers
	SET accPass = '#HASH(ARGUMENTS.password)#'
	WHERE AccountID = '#ARGUMENTS.ACCOUNTID#'
	</cfquery>

	<cfset ret = true/>
	
<cfcatch type="database">
	<cfset ret = false/>
</cfcatch>

</cftry>	

<cfreturn ret/>

</cffunction>
	

<cffunction name="getUserDetailsFromAccountID" access="public" hint="Adds a registration account" returntype="any">
<cfargument name="AccountID" required="true" type="string" />

	<cfquery name="q" datasource="#APPLICATION.dsn#">
	SELECT UserID, AccountID, Firstname, Lastname, Telnum, Company, discountRate, EmailAddress, viewFC, AuthLevel, CreditAccountAuth, Postcode, PriceBand, IsCookieOK
	FROM tblUsers
	WHERE AccountID = '#ARGUMENTS.AccountID#' 
	</cfquery>
	
<cfif q.recordCount eq 1>
	<cfreturn q />
<cfelse>
	<cfreturn "failed" />
</cfif>
</cffunction>

<cffunction name="getAccountValidationDetails" access="public" hint="Adds a registration account" returntype="any">
<cfargument name="AccountID" required="true" type="string" />



<cfquery name="q" datasource="#APPLICATION.dsn#">
	SELECT u.accountid, u.DiscountRate, u.EmailAddress, u.Postcode, u.PriceBand, a.managed_list, m.code, d.day, p.bandname
	FROM tblUsers u
	LEFT JOIN tblAuthCustomerList a
	ON u.accountid = a.account_ref
	LEFT JOIN tblAuthManagedList  m
	ON a.managed_list = m.code
	LEFT JOIN tblDeliverySchedule d
	ON u.accountid = d.accountid
	LEFT JOIN tblPrices p
	ON u.priceband = p.bandname
	WHERE u.AccountID = '#ARGUMENTS.AccountID#'
	GROUP BY u.accountid
	</cfquery>
	
<cfif q.recordCount eq 1>
	<cfreturn q />
<cfelse>
	<cfreturn "failed" />
</cfif>
</cffunction>



<cffunction name="isCreditAuthorised" access="public" hint="Checks whether user has a credit account" returntype="boolean">

	<cfquery name="qryIsCreditAuthorised" datasource="#APPLICATION.dsn#">
	SELECT CreditAccountAuth
	FROM tblUsers
	WHERE UserID = #SESSION.Auth.UserID#
	AND AccountID = '#SESSION.Auth.AccountID#' 
	</cfquery>

<cfreturn qryIsCreditAuthorised.CreditAccountAuth>	
</cffunction>

<cffunction name="isAccountOnHold" access="public" hint="Checks whether user has a credit account" returntype="boolean">

	<cfquery name="qryIsCreditAuthorised" datasource="#APPLICATION.dsn#">
	SELECT AccountOnHold
	FROM tblUsers
	WHERE UserID = #SESSION.Auth.UserID#
	AND AccountID = '#SESSION.Auth.AccountID#' 
	</cfquery>

<cfreturn qryIsCreditAuthorised.AccountOnHold>	
</cffunction>


<cffunction name="getAccountQuery" access="public" returntype="query">

<cfquery name="qryGetUserDetails" datasource="#APPLICATION.dsn#">
	SELECT 			AccountID, 
					Firstname, 
					Lastname, 
					Company,
					discountRate,
					Telnum,
					emailAddress,
					contactPref,
					building,
					postcode,
					line1,
					line2,
					line3,
					town,
					county,
					AllowEmailPost,
					AccPass,
					IsCookieOK					 			
	FROM tblUsers
	WHERE UserID = #SESSION.Auth.UserID#
	AND AccountID = '#SESSION.Auth.AccountID#'
</cfquery>

<cfreturn qryGetUserDetails />

</cffunction>

<cffunction name="qGetEmailByAccountID" access="public" output="false" returntype="any" hint="returns an email address for a specified account">
<cfargument name="AccountID" require="true" hint="">
<cfquery name="q" datasource="#APPLICATION.dsn#">
	SELECT EmailAddress  			
	FROM tblUsers
	WHERE AccountID = '#ARGUMENTS.AccountID#'
</cfquery>


<cfif q.recordcount eq 1>
	<cfreturn q/>
<cfelse>
	<cfreturn "" />
</cfif>

</cffunction>

<cffunction name="getAccountSeed" access="public" returntype="string">

<!--- get current seed--->
<cfquery name="qryGetAccountSeed" datasource="#APPLICATION.dsn#">
	SELECT 	SeedID
	FROM tblSeed
	WHERE SeedName = 'AccountID'
</cfquery>

<!---update the seed--->
<cfquery name="qryUpdateAccountSeed" datasource="#APPLICATION.dsn#">
	UPDATE tblSeed
	<cfif qryGetAccountSeed.SeedID eq 9999>
	SET SeedID = 1
	<cfelse>
	SET SeedID = (#qryGetAccountSeed.SeedID#+1)
	</cfif>
	WHERE SeedName = 'AccountID'
</cfquery>


<cfreturn (qryGetAccountSeed.SeedID+1) />

</cffunction>

<cffunction name="getAllowedList" access="public" returntype="struct" hint="looks up managed list code from account id">
<cfargument name="AccountID" type="string" required="true" hint="AccountID / code of the user">

<cfscript>
    var ret = {};
    ret.listname="";
    ret.listtype="";
</cfscript>



<cfquery name="q" datasource="#APPLICATION.dsn#">
SELECT CL.ANALYSISCODE9 as ALLOWEDLIST, ML.LISTTYPE FROM tblAuthCustomerList CL, tblAuthManagedList ML
WHERE CL.ANALYSISCODE9 = ML.CODE
AND CL.ACCOUNT_REF = '#ARGUMENTS.AccountID#'
</cfquery>


<cfif q.recordcount eq 1>
	<cfset ret.listname = q.ALLOWEDLIST />
    <cfset ret.listtype =  q.LISTTYPE />
</cfif>

<cfreturn ret />

</cffunction>




</cfcomponent>	