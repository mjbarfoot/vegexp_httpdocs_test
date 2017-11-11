<!--- 
	Filename: 	 /cfc/shop/secpay.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     SECPAY payment gateway
	Date: 		 29/05/2006	
	Revisions:
--->

<cfcomponent output="false" name="secpay" displayname="secpay" hint="debit and credit payments via secpay merchant service">
	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//

//return a copy of this object
return this;
</cfscript>
</cffunction> 

 <!--- *** DEBITS an amount from the credit card  *** --->
<cffunction name="debit" access="public" returntype="boolean" output="false">
<cfargument name="FORM" type="struct" required="true" />

<cfscript>
return true;
</cfscript>

</cffunction>

 <!--- *** CREDITS an amount to a credit/debit card  *** --->
<cffunction name="credit" access="public" returntype="boolean" output="false">
<cfargument name="FORM" type="struct" required="true" />
 
<cfscript>
return true;
</cfscript>

</cffunction>

</cfcomponent>