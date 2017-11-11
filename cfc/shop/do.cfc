<!--- 
	Filename: 	 /cfc/shop/do.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Sho/s data object (DO): CRUD operations for order relating info
	Date: 	     29/05/2006
	Revisions:
--->

<cfcomponent output="false" name="myObject" displayname="myObject" hint="">
	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//
// get the departments DO
VARIABLES.dep_do=createObject("component", "cfc.departments.do");

//return a copy of this object
return this;
</cfscript>
</cffunction> 

 <!--- *** SAVE METHOD *** --->
<cffunction name="saveOrder" access="public" returntype="boolean" output="false">
<cfargument name="formObj" required="true" type="struct" />



<cfif NOT isValid("string", FORMOBJ.delnotes)>
    <cfset FORMOBJ.delnotes = "" />
</cfif>

<!--- initialise var --->
<cfset var qryItemDetails="">
<cfset var qryShoppingBasket="">
	<!--- save order info --->
	<cfquery name="qryAddOrder" datasource="#APPLICATION.dsn#">
	INSERT INTO tblOrder
	(WebOrderID,WebOrderRef,AccountID,OrderTS,OrderDate,OrderTime,OrderStatus,OrderStatusDesc,OrderStatusError,Amount,
	delbuilding,delline1,delline2,delline3,deltown,delcounty,delpostcode,
	delnotes,poref
	<cfif isdefined("FORMOBJ.card_type")>
	,card_type,card_no,customer,start_date,expiry,issue,cv2
	billBuilding,billPostcode,billLine1,billLine2,billLine3,billTown,billCounty
	</cfif>
	) VALUES (
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.shopper.orderID#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.shopper.WebOrderRef#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.Auth.AccountID#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.shopper.orderTS#">,
	<!--- MSACCESS:	
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#LSDateFormat(now(), 'dd/mm/yyyy')#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#LSTimeFormat(now(), 'H:MM TT')#">,
	MSACCESS --->
	<!--- MYSQL --->
	<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
	<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
	<!--- MYSQL: EMD--->
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.shopper.orderStatus#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.orderStatusDesc#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.shopper.orderError#">,
	<cfqueryparam cfsqltype="cf_sql_decimal" value="#DecimalFormat(session.shopper.basket.getGrandTotal(true))#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delbuilding#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delline1#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delline2#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delline3#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.deltown#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delcounty#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delpostcode#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.delnotes#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.customerPO#">
	<!--- if paying by credit card --->
	<cfif isdefined("FORMOBJ.card_type")>
	   ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.card_type#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.card_no#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.customer#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.start_date#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.expiry#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#FORMOBJ.issue#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#FORMOBJ.cv2#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billBuilding#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billPostcode#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billLine1#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billLine2#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billLine3#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billTown#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORMOBJ.billCounty#">
	</cfif>
	)
	</cfquery>

	
	<cfset qryShoppingBasket=session.shopper.basket.list()>
	<!--- loop though the basket and add items to OrderItem table --->
	<cfloop query="qryShoppingBasket">
		<!--- get a stockcode, stockdesc, and price --->
		<cfset qryItemDetails=VARIABLES.dep_do.getItemDetails(ProductID)>	
		
		<!--- adnan --->
		<cfquery name="qryAddOrderItems" datasource="#APPLICATION.dsn#">
		INSERT INTO tblOrderItem
		(OrderID, StockCode, Description, Quantity, UnitOfSale, SalePrice)
		VALUES (
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.shopper.orderID#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryItemDetails.Stockcode#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryItemDetails.Description#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#qryShoppingBasket.Quantity#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryItemDetails.UnitOfSale#">,
		<cfqueryparam cfsqltype="cf_sql_double" value="#qryItemDetails.SalePrice#">
		)
		</cfquery>
	</cfloop>
	
<cfscript>
return true;
</cfscript>

</cffunction>

 <!--- *** Get Incomplete Orders *** --->
<cffunction name="getIncompleteOrders" access="public" returntype="query" output="false">

<cfquery name="qryGetIncompleteOrders" datasource="#APPLICATION.dsn#">
SELECT WebOrderID, AccountID, OrderDate, OrderTime, OrderStatus, OrderStatusDesc, Amount
FROM  tblOrder
WHERE UCASE(OrderStatus) <> 'COMPLETE'
</cfquery>

<cfreturn qryGetIncompleteOrders />
</cffunction>

</cfcomponent>