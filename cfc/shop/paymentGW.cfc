<!--- 
	Filename: 	 /cfc/shop/paymentGW.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Payment interface to different gateways
	Date: 		 29/05/2006
	Revisions:
--->

<cfcomponent output="false" name="paymentGW" displayname="paymentGW" hint="interface to debit/credt card payment gateways">
	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//

// use SECPAY.co.uy for payment gateway
VARIABLES.secpay=createObject("component", "cfc.shop.secpay").init();


//return a copy of this object
return this;
</cfscript>
</cffunction> 

 <!--- *** DEBITS an amount from the credit card  *** --->
<cffunction name="debit" access="public" returntype="boolean" output="false">
<cfargument name="FORM" type="struct" required="true" />

<cfscript>
return VARIABLES.secpay.debit(ARGUMENTS.FORM);
</cfscript>

</cffunction>

 <!--- *** CREDITS an amount to a credit/debit card  *** --->
<cffunction name="credit" access="public" returntype="boolean" output="false">
<cfargument name="FORM" type="struct" required="true" />
 
<cfscript>
return VARIABLES.secpay.credit(ARGUMENTS.FORM);
</cfscript>

</cffunction>


</cfcomponent>
