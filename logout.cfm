<cfprocessingdirective suppresswhitespace="true">
<cfscript>
SESSION.Auth.isLoggedIn 		= false;
SESSION.Auth.firstname 			= "";
SESSION.Auth.lastname 			= "";
SESSION.Auth.Company 			= "";
SESSION.Auth.UserID				= "";
SESSION.Auth.AccountID			= "";
SESSION.Auth.viewFC				= false;
SESSION.Auth.viewFCBypass		= false;
SESSION.Auth.Postcode			= "";
SESSION.Auth.DelDay				= "";
SESSION.Auth.DelDayExpiry		= 0;
</cfscript>
<cfsilent>
<cfxml variable="myContent">
			<div id="content" style="height:300px;padding-top:2em;">
			<h1 style="color:Red; font-size: 2em;">You are logged out</h1>
			</div>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cfsilent>
<cfinclude template="/views/default.cfm">
<cfscript>
StructDelete(SESSION, "Auth");
StructDelete(SESSION, "Shopper");
</cfscript>
</cfprocessingdirective>




