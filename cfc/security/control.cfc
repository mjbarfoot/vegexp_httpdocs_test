<!--- 
	Component: control.cfc
	File: /cfc/security/control.cfc
	Description: controls shop security related actions 
	Author: Matt Barfoot
	Date: 24/04/2006
	Revisions: 13/11/2006: Added contractcompany handler.
	--->
	
<cfcomponent name="control" displayname="control" output="false" hint="controls shop security related actions">

<!--- / Object declarations / --->
<cfscript>
secDO		=createObject("component", "cfc.security.do");
eml			=createObject("component", "cfc.shop.dispatchMsg");
delivery	=createObject("component", "cfc.departments.delivery");
sageWSGW	=createObject("component", "cfc.sagegw.sageWSGW");
</cfscript>


<cffunction name="setAuthorisation" returntype="void" access="public">
<cfscript>
SESSION.Auth = structnew();
SESSION.Auth.isLoggedIn 		= false;
SESSION.Auth.firstname 			= "";
SESSION.Auth.lastname 			= "";
SESSION.Auth.DiscountRate		= 0;
SESSION.Auth.Company 			= "";
SESSION.Auth.EmailAddress		= "";
SESSION.Auth.UserID				= "";
SESSION.Auth.AccountID			= "";
SESSION.Auth.viewFC				= false;
SESSION.Auth.viewFCBypass		= false;
SESSION.Auth.Postcode			= "";
SESSION.Auth.MOV                = 0;
SESSION.Auth.DelDay				= "";
SESSION.Auth.DelDayExpiry		= 0;
SESSION.Auth.NextDayDel			= false;
SESSION.Auth.NextDayDelExpiry	= 0;
SESSION.Auth.AllowedList 		= "";
SESSION.Auth.AllowedListType    = "";
SESSION.Auth.PriceBand			= "Standard";
SESSION.Auth.IsCookieOK		    = "";
SESSION.Auth.customerPOrequired = false;
SESSION.Auth.viewPrices         = false;

if (isdefined("CLIENT.Auth") AND CLIENT.Auth neq "") {
    SESSION.Auth  = APPLICATION.shop.util.wddx2cfml(CLIENT.Auth);
    SESSION.Auth.viewPrices         = true;
    SESSION.Auth.isLoggedIn			= false;
    SESSION.Auth.DelDay				= delivery.getDelDay(AccountID=SESSION.Auth.AccountID);
    SESSION.Auth.DelDayExpiry		= DateAdd("n", 5, now());
    SESSION.Auth.NextDayDel			= delivery.isValidNextDay(AccountID=SESSION.Auth.AccountID);
    SESSION.Auth.NextDayDelExpiry	= DateAdd("n", 5, now());


	If (NOT isdefined("SESSION.AUTH.IsCookieOK")) {
		SESSION.Auth.IsCookieOK		    = "";
	}
}
</cfscript>
</cffunction>

<cffunction name="forceLogin" returntype="void" access="public">
<cfscript>
var loginCheck=false;
var qryUserDetails="";

if (NOT SESSION.Auth.isLoggedIn) {
	// has the login form been submitted
	if (isdefined("FORM.userLogin")) {
		
		// check login
		qryUserDetails = loginChk();
		
		// if an AccountID is in the returned query
		if (isdefined("qryUserDetails.AccountID")) {	
			// passed login check
			loginUser(qryUserDetails);
		
		} else {
			// login failed
			request.login.feedback="Sorry, we could not log you in. Perhaps you mistyped your AccountID or password";		
			application.shop.util.include("/login.cfm");
            application.shop.util.abort();
		}
	
	// login form not submitted
	} else {
		//session.lastRequest = cgi.QUERY_STRING;
        application.shop.util.include("/login.cfm");
        application.shop.util.abort();
	}

}
</cfscript>	
</cffunction>

<cffunction name="loginChk" access="private" returntype="Any">
<cfscript>
var isValidLogin=false;
var qryUserDetails="";

//check the password length
if (len(FORM.userPass) gte 6) {
	// get the user details
	qryUserDetails = secDO.getUserDetails(FORM.userLogin, FORM.userPass);
	
	// if a query was returned than it is a valid login
	if (isdefined("qryUserDetails.AccountID")) {
		isValidLogin=true;
	}
} 
	

if (NOT isValidLogin) {
	// bad login
	return isValidLogin;
}  else {
	// good login return the user query
	return qryUserDetails;
	
}
</cfscript>
</cffunction>

<cffunction name="loginUser" access="private" returntype="void">
<cfargument name="qryUserDetails" type="query" required="true" />	
<cfscript>
// get the Favourites Data Object
var fav_do=createObject("component", "cfc.shopper.fav_do").init();
var allowedList = SecDO.getAllowedList(qryUserDetails.AccountID);


//AccountID, Firstname, Lastname, viewFC, AuthLevel, CreditAccountAuth 
SESSION.Auth.isLoggedIn 		= true;
SESSION.Auth.firstname 			= qryUserDetails.Firstname;
SESSION.Auth.lastname 			= qryUserDetails.Lastname;
SESSION.Auth.Telnum				= qryUserDetails.Telnum;
SESSION.Auth.Company			= qryUserDetails.Company;
SESSION.Auth.DiscountRate		= qryUserDetails.discountRate;
SESSION.Auth.EmailAddress		= qryUserDetails.EmailAddress;
SESSION.Auth.UserID				= qryUserDetails.UserID;
SESSION.Auth.AccountID			= qryUserDetails.AccountID;
SESSION.Auth.viewFC				= delivery.isAbleToViewFC(AccountID=SESSION.Auth.AccountID);
SESSION.Auth.Postcode			= qryUserDetails.Postcode;
SESSION.Auth.MOV                = delivery.getMinimumOrderValue(AccountID=SESSION.Auth.AccountID);
SESSION.Auth.DelDay				= delivery.getDelDay(AccountID=SESSION.Auth.AccountID);
SESSION.Auth.DelDayExpiry		= DateAdd("n", 5, now());
SESSION.Auth.NextDayDel			= delivery.isValidNextDay(AccountID=SESSION.Auth.AccountID);
SESSION.Auth.NextDayDelExpiry	= DateAdd("n", 5, now());
SESSION.Auth.AllowedList 		= allowedList.listName;
SESSION.Auth.AllowedListType 	= allowedList.listType;
SESSION.Auth.PriceBand			= qryUserDetails.PriceBand;
SESSION.Auth.IsCookieOK			= qryUserDetails.IsCookieOK;
SESSION.Auth.customerPOrequired = iscustomerPOrequired(allowedList.listName);

//set client variables
if (SESSION.Auth.IsCookieOK eq 1) {
CLIENT.Auth = AuthToWDDX();
}


//update favourites list
fav_do.maintainFavourites();


//add user id to list of logged in users.
if  (NOT structKeyExists(APPLICATION.loggedInUsers, SESSION.Auth.UserID)) {
StructInsert(APPLICATION.loggedInUsers, SESSION.Auth.UserID, 1);
}
</cfscript>
</cffunction>

<cffunction name="AuthToWDDX" access="private" returnType="string" output="false">
 	<cfwddx action = "cfml2wddx" input = "#SESSION.Auth#" output = "wddxText">
	<cfreturn wddxText /> 
</cffunction>	

<cffunction name="getAccountDetails" returntype="query" access="public">
<cfscript>
return secDO.getAccountQuery();
</cfscript>
</cffunction>

<cffunction name="isCreditAuthorised" returntype="boolean" access="public">
<cfscript>
return secDO.isCreditAuthorised();	
</cfscript>
</cffunction>

<cffunction name="isCustomerPOrequired" returntype="boolean" access="private">
<cfargument name="allowedList" required="true" type="string" hint="the managed list code">
<cfscript>
	var porequiredlist =  APPLICATION.var_DO.getVar("porequiredlist");
	if (listcontains(porequiredlist, ARGUMENTS.allowedList) neq 0) {
		return true;
	} else {
		return false;
	}
	
</cfscript>
</cffunction>


<cffunction name="isAccountOnHold" returntype="boolean" access="public">
<cfscript>
return secDO.isAccountOnHold();	
</cfscript>
</cffunction>



<cffunction name="activate" access="public" returntype="boolean" hint="attempts to activate an account from a passed encrypted URL query string">
<cfargument name="encryptedURL" required="true" type="string" hint="the encrypted url">

<cfscript>
var ret = false;

if (ARGUMENTS.encryptedURL neq "") {
	urlDecrypt("vegexp",ARGUMENTS.encryptedURL);
	
	// did we successfully uncrypt the accountid
	if (isdefined("url.AccountID") and len(URL.AccountID) gte 2) {
		
		q = SecDO.getUserDetailsFromAccountID(URL.AccountID);
		
		// did we get back a user record
		if (isQuery(q)) {
			loginUser(q); //log them in
			ret=true;
		} else {
			ret=false;
		}
		
	} else {
		ret = false;
	}

}

return ret;
</cfscript>

</cffunction>

<cffunction name="doAccountValidationChecks" access="public" returntype="struct" hint="tests whether an account matches required preconditions for online shopping">
<cfargument name="AccountID" type="string" required="true" hint="the AccountID for the customer">
<cfset var res = structnew() />
<cfset var q=""/>
<cfset res.status = false/>
<cfset res.reason = ""/>

<!--- get a  query object which should always return one row --->
<cfset q = SecDo.getAccountValidationDetails(ARGUMENTS.AccountID)>

<cfif isQuery(q)>

<!---check if there is an email address --->
	<cfif reFind("[a-z0-9!##$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!##$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", q.emailAddress) neq 0>
		<cfset res.status=true/>
	<cfelse>
		<cfset res.reason="The email address held on our records does not appear to valid. Please call us to amend it, thanks" />
		<cfset res.status=false/>
	</cfif>	

<!--- check if customer has valid address details--->
	
	<cfif res.status AND reFind("^([A-PR-UWYZ0-9][A-HK-Y0-9][AEHMNPRTVXY0-9]?[ABEHMNPRVWXY0-9]? {1,2}[0-9][ABD-HJLN-UW-Z]{2}|GIR 0AA)$", trim(ucase(q.postcode))) neq 0>
		<cfset res.status=true/>
	<cfelseif res.STATUS>
		<cfset res.reason="The postcode held on our records does not appear to valid. Please call us to amend it, thanks" />
		<cfset res.status=false/>
	</cfif>	


<!--- check if delivery schedule is setup --->
	<cfif res.STATUS and q.day neq "" AND q.day neq "null">
		<cfset res.status=true/>
	<cfelseif res.STATUS>
		<cfset res.reason="You do not have any delivery schedule assigned to your account. Please call us to amend this, Thanks." />
		<cfset res.status=false/>
	</cfif>	

<!--- check if price band is valid --->
	<cfif res.STATUS and q.priceband neq "">
		<cfset res.status=true/>
	<cfelseif res.STATUS>
		<cfset res.reason="There is problem regarding pricing for items you may wish to order online. Please call us to amend this, Thanks." />
		<cfset res.status=false/>
	</cfif>	

<!--- check if managed list is valid 
** not required because account setup checks this and if it doesn't exist in tblAuthManagedList then it is set empty--->

<cfelse>

	<cfset res.reason="An unanticipated error occurred whilst validating your account to enable online shopping"/>

</cfif>



<cfreturn res/>

</cffunction>


<cffunction name="resetPassword" returntype="cfc.security.registrationBean" access="public" hint="attempts to reset a password">
<cfargument name="accountcode" type="string" required="true" hint="the account code for which the user is trying to register">
<cfargument name="emailaddress" type="string" required="true" hint="the email address for which the user is trying to register">

<cfreturn registerExistingUser(ARGUMENTS.accountcode, ARGUMENTS.emailaddress, true)/>
</cffunction>

<cffunction name="registerExistingUser" returntype="cfc.security.registrationBean" access="public" hint="attempts to register an existing user">
<cfargument name="accountcode" type="string" required="true" hint="the account code for which the user is trying to register">
<cfargument name="emailaddress" type="string" required="true" hint="the email address for which the user is trying to register">
<cfargument name="isPasswordReset" type="boolean" required="false" default="false" hint="whether triggering event is password reset">

<cfscript>
/*  ------------------/ RegistrationStatus /-------------  / 
0 = failed
1 = Account code not found
2 = email address does not match
3 = there is no email address on record
4 = complete
5 = incomplet account setup
------------------------------------------------------------ */
var accCode = trim(ARGUMENTS.accountcode);
var emailadd = trim(ARGUMENTS.emailAddress);
var regBean = createObject("component", "cfc.security.registrationBean").init();
var accountEmailAddress = "";
var q = "";
var msg = "";


if (accCode neq "" AND len(accCode) gte 2 AND emailadd neq "" AND len(emailadd) gte 5) {
	

	// check if supplied email matches one in database?
	q = secDO.qGetEmailByAccountID(accCode);
	
	
	//if we got a query then the account code matched	
	if (isQuery(q)) {
		
		
		isCustomerAccountValid=structnew();
		isCustomerAccountValid = doAccountValidationChecks(accCode);
		// check whether account fulfils requirements to user to shop online
		if (isCustomerAccountValid.status) {
		
		
				accountEmailAddress = q.emailAddress;
						
					//do the emai addresses match 
					if (emailAdd eq accountEmailAddress) {
							
							//send the activation email
							msg = structnew();
							msg.body = structnew();
							
							msg.body.link = "https://#cgi.Server_name#/activate.cfm?" & urlEncrypt("accountid=#accCode#","vegexp");
							
							if (ARGUMENTS.isPasswordReset) {
								msg.title = "Vegetarian Express Online Password Reset";
								eml.sendEmail(emailAdd,"support@orders.vegetarianexpress.co.uk","Vegetarian Express Online Password Reset",msg,"/views/emlCustPassReset.cfm");
							} else {
								msg.title = "Vegetarian Express Online Account Activation";
								eml.sendEmail(emailAdd,"support@orders.vegetarianexpress.co.uk","Vegetarian Express Online Account Activation",msg,"/views/emlCustActivation.cfm");
							}
							
							//set complete
							regBean.setStatus = 4;
							regBean.setIsComplete(true);
					
					} 
						// if it's blank
						else if (accountEmailAddress eq "") {
						regBean.setStatus(3);
						regBean.setMessage("Sorry, it would appear we don't currently have any email address in our records. Please call us and we will update your account.");
					} else {	
						// email address didn't match
						regBean.setStatus(2);	
						regBean.setMessage("Sorry, the email address you entered doesn't match the one on our records. Please re-enter your email carefully or call us if you think this is wrong");
					}
		
		} else {
			regBean.setStatus(5);
			regBean.setMessage(isCustomerAccountValid.reason);	
		}
		
			
	// query executed by passed account code returned empty string i.e. no account exists with account code	
	} else {
			regBean.setStatus(1);
			regBean.setMessage("Sorry, we can't find your Account Code. Perhaps you mistyped it, please try again.");
	}
	
	
// invalid or empty string passed as account code	
} else {
	regBean.setStatus(1);
	regBean.setMessage("Sorry we can't find your Account Code. Perhaps you mistyped it, please try again.");
}

return regBean;
</cfscript>
</cffunction>

<cffunction name="registerUser" returntype="any" access="public">
<cfargument name="formObj" required="true" type="struct" />
<cfscript>
/*  ------------------/ RegistrationStatus /-------------  / 
0 = started
1 = saved to DB
2 = posted to Sage
3 = complete
------------------------------------------------------------ */
var registrationStatus=0;

/*  ------------------/ AccountID generation /-------------  / 
	Use "0WEB" AND four digits (AccountID seed)
	This puts the newly generated accounts at the top of the account list 
------------------------------------------------------------ */
var newAccountSeed = secDO.getAccountSeed();
formObj.AccountID = "0WEB" & newAccountSeed;

// set whether the client can view frozen/chilled goods
formObj.viewFC	  = delivery.viewFC(trim(formObj.Postcode)); 


// ******** HANDLER for Contract Vs Independent Caterers *********//
// added: 13/11/2006
/* 2 fields exist clientcompany and contractcompany
if user is a working for an independent company then contract company field is hidden
if user is working for a contract company then the contractcompany field is routed to address line 1.
Currently Address line 1 is routed to Sage Address Line 2. Line1 is included in database insert. 
*/

//create the line1 address field
formObj.line1="";


if (formObj.companytype eq "contract" AND len(contractcompany) neq 0) {
		formObj.line1 = formObj.contractcompany;
		// prepend line 2 of the address with building
		formObj.line2andBuilding = formObj.building & " " & formObj.line2;
	} else {
		formObj.line1 = formObj.building;
		formObj.line2andBuilding = formObj.line2;
}

// ******** END HANDLER ********************************** //



//save account in database
if (secDO.addAccount(formObj)) {
//registration saved!
	registrationStatus = 1;
	
	// write application log
	application.applog.write(timeformat(now(), 'h:mm:ss tt') & " User Registration for #formObj.clientcompany# saved to database");
	
	//post account registration to sage
	if (APPLICATION.sageGWenabled) {
		if (sageWSGW.registerUser(formObj)) {
			 registrationStatus = 2;
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " User Registration for #formObj.clientcompany# posted to Sage WS");		 
		} else {
			application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Failed to post user registration for #formObj.clientcompany# to Sage WS");		 
		}			 	
	}


}

/*

switch (registrationStatus) {
// account saved just to db, not to sage
case 1: 			//warn staff of not being able to post to sage.
					msg = structnew();
					msg.body = structnew();
					msg.title = "User Registration could not be posted to Sage";
					msg.body = formObj;
					eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress")
									,"support@orders.vegetarianexpress.co.uk",
									"Warning! - User Registration could not be posted to Sage", 
									msg,
									 "/views/emlRegStaffDelayed.cfm");
				
					// send delayed confirmation to customer
					msg.title = "Thanks for registering";
					
					eml.sendEmail(formObj.emailAddress,
								  "support@orders.vegetarianexpress.co.uk",
								  "Vegetarian Express Registration Confirmation",
					 	           msg, 
					 			   "/views/emlRegUserDelayed.cfm");
					;
					break;
// account posted to Sage					
case 2: 			//send confirmation to customer
					msg = structnew();
					msg.body = structnew();
					msg.title = "Thanks for registering";
					msg.body = formObj;
					eml.sendEmail(formObj.emailAddress,"support@orders.vegetarianexpress.co.uk","Vegetarian Express Registration Confirmation", msg, "/views/emlRegUser.cfm");
				
					//send confirmation to staff
					msg.title = "New user registration";
					eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress"),
					              "support@orders.vegetarianexpress.co.uk",
					              "New Customer Registration", 
					              msg,
					              "/views/emlRegStaff.cfm");
					              
					//AccountID, Firstname, Lastname, viewFC, AuthLevel, CreditAccountAuth 
					SESSION.Auth.isLoggedIn 		= true;
					SESSION.Auth.firstname 			= formObj.Firstname;
					SESSION.Auth.lastname 			= formObj.Lastname;
					SESSION.Auth.Telnum				= formObj.telnum;
					SESSION.Auth.Company			= formObj.Company;
					SESSION.Auth.discountRate		= 0;
					SESSION.Auth.EmailAddress		= formObj.emailAddress;
					SESSION.Auth.AccountID			= formObj.AccountID;
					SESSION.Auth.viewFC				= formObj.viewFC;
					SESSION.Auth.Postcode			= formObj.Postcode;
					SESSION.Auth.DelDay				= delivery.getDelDay();
					SESSION.Auth.DelDayExpiry		= DateAdd("n", 5, now());
					SESSION.Auth.NextDayDel			= delivery.isValidNextDay();
					SESSION.Auth.NextDayDelExpiry	= DateAdd("n", 5, now());
					
					//set client variables
					CLIENT.Auth = AuthToWDDX();
					
					//add user id to list of logged in users.
					if  (NOT structKeyExists(APPLICATION.loggedInUsers, SESSION.Auth.UserID)) {
						StructInsert(APPLICATION.loggedInUsers, SESSION.Auth.UserID, 1);
					}
					
					
					; //end of case
				break;
// account not saved to db or sage						
default: 			//warn staff of not being able to post to sage.
					msg = structnew();
					msg.body = structnew();
					msg.title = "Serious Error with User Registration";
					msg.body = formObj;
					eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress")
									,"support@orders.vegetarianexpress.co.uk",
									"Error! - User Registration failed", 
									msg,
									 "/views/emlRegUserFailure.cfm");

					;	
}
	



*/	

	
// return the registration status code	
return registrationStatus;
</cfscript>
</cffunction>				

<cffunction name="changePass" returntype="cfc.security.registrationBean" access="public" hint="attempts to change an account password">
<cfargument name="argEncryptedURL" required="true" type="string" hint="the encrypted url">
<cfargument name="argAccountID" required="true" type="string" hint="the User's AccountID">
<cfargument name="argPassword" required="true" type="string" hint="the new password to set">

<cfscript>
var AccountID = trim(ARGUMENTS.argAccountID);
var password = trim(ARGUMENTS.argPassword);
var regBean = createObject("component", "cfc.security.registrationBean").init();	
//during the activation process we force the user to change password
//the encrypted URL is passed as part of the form to prevent external submission of the form and changing of account passwords 

//verify the 
urlDecrypt("vegexp", ARGUMENTS.argEncryptedURL);


if (URL.accountID eq AccountID) {
 	// update the password
 	if (secDO.setAccountPassword(AccountID,password)) {
		//dont worry about status just setIsComplete to true, false by default 	
 		regBean.setIsComplete(true);	
 	}
 }
return regBean;
</cfscript>
</cffunction>


<cffunction name="myAccountUpdate" returntype="boolean" access="public">
<cfargument name="formObj" required="true" type="struct" />
<cfscript>
if (secDO.updateAccount(formObj)) {             
	
	//update relevenat session.auth vars
	SESSION.Auth.firstname 			= formObj.Firstname;
	SESSION.Auth.lastname 			= formObj.Lastname;
	if (SESSION.Auth.IsCookieOK eq 1) {
		CLIENT.Auth = AuthToWDDX();
		} else {
			structDelete(CLIENT, "Basket");
			structDelete(CLIENT, "Auth");	
	}
	return true;
} else {
	return false;
}
</cfscript>
</cffunction>


<cffunction name="setCookieAcceptRemote" access="remote" returntype="any" description="Sets whether client cookies can be used" hint="used to set cookie preference">
<cfargument name="IsCookieOK" required="true" type="boolean">
<cfscript>
if (secDO.updateCookiePreference(SESSION.Auth.AccountID, ARGUMENTS.IsCookieOK)) {
	SESSION.AUTH.isCookieOK = ARGUMENTS.isCookieOK;
}
</cfscript>
<cfcontent type="text/xml" />
<cfoutput>
<taconite-root xml:space="preserve">
</taconite-root>
</cfoutput>
</cffunction>

<cfscript>

/**
 * Add security by encrypting and decrypting URL variables. See URLEncrypt.
 * Mod by David Heard - added decode
 * 
 * @param nKey 	 The encryption key to use. (Required)
 * @param QueryString 	 Defaults to CGI.Query_String (Optional)
 * @return Writes to the URL scope. 
 * @author Timothy Heald (theald@schoollink.net) 
 * @version 3, October 9, 2002 
 */
function urlDecrypt(key, queryString){
	var scope = "url";
	var stuff = "";
	var oldcheck = "";
	var newcheck = "";
	var i = 0;
	var thisPair = "";
	var thisName = "";
	var thisValue = "";
	
	// see if a scope is provided if it is set it otherwise set it to url
	if(arrayLen(arguments) gt 2){
		scope = arguments[3];
	}

	if ((right(queryString,3) neq "htm") or (findNoCase("&",queryString) neq 0) or (findNoCase("=",queryString) neq 0)){
		stuff = '<FONT color="red">not encrypted, or corrupted url: querystring: #queryString#</FONT>';
	} else {
	
		// remove /index.htm
		querystring = replace(queryString, right(queryString,10),'');
		
		// remove the leading slash
		querystring = replace(queryString, left(queryString,1),'');
		
		// grab the old checksum
           if (len(querystring) GT 2) {
               oldcheck = right(querystring, 2);
               querystring = rereplace(querystring, "(.*)..", "\1");
           } 
           
           // check the checksum
           newcheck = left(hash(querystring & key),2);
           if (newcheck NEQ oldcheck) {
               return querystring;
           }
           
           //decrypt the passed value
		queryString = cfusion_decrypt(queryString, key);
		
			// set the variables
			for(i = 0; i lt listLen(queryString, '&'); i = i + 1){
				
				// Break up the list into seprate name=value pairs
				thisPair = listGetAt(queryString, i + 1, '&');
				
				// Get the name
				thisName = listGetAt(thisPair, 1, '=');
				
				// Get the value
				thisValue = listGetAt(thisPair, 2, '=');
				
				// Set the name with the scope
				thisName = scope & '.' & thisName;
				
				// Set the variable
				setVariable(thisName, thisValue);
			}
		
	}
	
	return queryString;
}

/**
 * Add security by encrypting and decrypting URL variables.
 * 
 * @param cQueryString 	 Query string to encrypt. (Required)
 * @param nKey 	 Key to use for encryption. (Required)
 * @return Returns an encrypted query string. 
 * @author Timothy Heald (theald@schoollink.net) 
 * @version 2, February 19, 2003 
 */
function urlEncrypt(queryString, key){
	// encode the string
	var uue = cfusion_encrypt(queryString, key);
        
	// make a checksum of the endoed string
	var checksum = left(hash(uue & key),2);
        
	// assemble the URL
	queryString = "/" & uue & checksum &"/index.htm";
		
	return queryString;
}
</cfscript>

</cfcomponent>	