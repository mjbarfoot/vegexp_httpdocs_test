<cfif structKeyExists(url, "cookiejs")>
<cfoutput>Checking browser configuration...</cfoutput>

	<!---run cookie test--->
	<cfif structKeyExists(cookie, "tmtCookieTest")>
	  	
	  	<!---do javascript test--->
		<script language="JavaScript">
		<!-- Begin script
		window.location.replace("userConfig.cfm?jsEnabled");
		// End script --> </script>
		<html>
		<head>
		<META HTTP-EQUIV=REFRESH CONTENT="0;URL=userConfig.cfm?jsDisabled">
		</head>
		</html>	  
	
	
	
	<cfelseif NOT structKeyExists(url, "tmtCookieSend")>
		<!--- First time the user visit the page, set the cookie --->
	   <cfcookie name="tmtCookieTest" value="Accepts cookies">
	   
	   <cflocation url="userConfig.cfm?cookiejs=1&tmtCookieSend=true"  addtoken="no" />
	   <!--- The cookie was send, redirect and set the tmtCookieSend flag as an url variable
	   <cfset getPageContext().forward("userConfig.cfm?cookiejs=1&tmtCookieSend=true")> --->
		
	<cfelse>
		<!--- We tried sending the cookie, no way, cookies are disabled, get out of here --->
	   <cflocation url="#APPLICATION.root#/notSupported.cfm?cookiesDisabled=1"  addtoken="no" />
	</cfif>

<cfelseif structKeyExists(url, "jsEnabled")>

<cfset SESSION.UserAgent.CookieAndJSenabled=true />
<cflocation url="#APPLICATION.root#/index.cfm"  addtoken="no" />


<cfelseif structKeyExists(url, "jsDisabled")>


<cflocation url="#APPLICATION.root#/notSupported.cfm?jsDisabled=1"  addtoken="no" />

</cfif>

