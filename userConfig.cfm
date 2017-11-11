<cffunction name="isRequestSecure" access="public" output="false" returnType="boolean">
 
    <cfset var secure = false>
 
    <cfif cgi.https EQ "on">
        <cfset secure = true>
    </cfif>
 
    <cfreturn secure>
</cffunction>

<cfif NOT isRequestSecure() AND ucase(APPLICATION.appmode) eq "PRODCUCTION">
	<cflocation url="https://orders.vegetarianexpress.co.uk" addtoken="no" />
</cfif>


<cfif structKeyExists(url, "cookiejs")>
<cfoutput>Checking browser configuration...</cfoutput>

	<!---run cookie test--->
	<cfif structKeyExists(cookie, "tmtCookieTest")>
	  	
<!--- 	  	<cfoutput>structKeyExists(cookie, "tmtCookieTest") #structKeyExists(cookie, "tmtCookieTest")# #session.lastRequest# #SESSION.UserAgent.CookieAndJSenabled#</cfoutput>
	  	<cfoutput><br/>structKeyExists(session, "sessionStartFired"): #structKeyExists(session, "sessionStartFired")#</cfoutput> --->
	  	<!---do javascript test--->
		<script language="JavaScript">
		<!-- Begin script
		window.location.href = "userConfig.cfm?jsEnabled";
		// End script --> </script>
		<html>
		<head>
		<META HTTP-EQUIV=REFRESH CONTENT="0.05;URL=userConfig.cfm?jsDisabled">
		</head>
		</html>

	
	
	<cfelseif NOT structKeyExists(url, "tmtCookieSend")>
		<!--- First time the user visit the page, set the cookie --->
	   <cfcookie name="tmtCookieTest" value="Accepts cookies">
	   
	   <cflocation url="userConfig.cfm?cookiejs=1&tmtCookieSend=true"  addtoken="no" />
	   <!--- The cookie was send, redirect and set the tmtCookieSend flag as an url variable--->
	   <cfset getPageContext().forward("userConfig.cfm?cookiejs=1&tmtCookieSend=true")> 
		
	<cfelse>
		<!--- We tried sending the cookie, no way, cookies are disabled, get out of here --->
	   <cflocation url="/notSupported.cfm?cookiesDisabled=1"  addtoken="no" />
	</cfif>

<cfelseif structKeyExists(url, "jsEnabled")>

<cfset SESSION.UserAgent.CookieAndJSenabled=true />

<!--- <cfoutput>SESSION.UserAgent.CookieAndJSenabled=true: #SESSION.UserAgent.CookieAndJSenabled# </cfoutput> --->
<cflocation url="#session.lastRequest#"  addtoken="no" />


<cfelseif structKeyExists(url, "jsDisabled")>


<cflocation url="/notSupported.cfm?jsDisabled=1"  addtoken="no" />

</cfif>

