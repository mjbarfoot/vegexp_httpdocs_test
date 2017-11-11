<!--- 
	Filename: 	 /cfc/shopper/fav_do.cfc 
	Created by:  Matt Barfoot- Clearview Webmedia Limited
	Purpose:     Maintains favourtites in the database
	Date: 		 07/07/2006
	Revisions:
--->

<cfcomponent output="false" name="fav_do" displayname="fav_do" hint="Data Object for maintaining shopper favourtites">
	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//
// get the ...
//VARIABLES.myObject=createObject("component", "cfc.myObject.myObject").init();
// get the ...
//VARIABLES.myObject=createObject("component", "cfc.myObject.myObject");

// get the departments data object
VARIABLES.view_do		=createObject("component", "cfc.departments.do");

//return a copy of this object
return this;
</cfscript>
</cffunction> 

<!--- check whether there are in favourites for the shopper --->
<cffunction name="doFavouritesExist" output="false" returntype="boolean" access="public">

	<cfquery name="QryGetFavourites"  datasource="#APPLICATION.dsn#">
	SELECT FavID FROM tblFavourite
	WHERE AccountID = '#SESSION.Auth.AccountID#'
	</cfquery>

	<cfif QryGetFavourites.RecordCount>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>
	
</cffunction>

<!--- maintainFavourites: removes items older that have not been ordered for 6 months --->
<cffunction name="maintainFavourites" output="false" returntype="void" access="public">

<cfset var isRemoved=false />

	<cfquery name="QryGetFavourites"  datasource="#APPLICATION.dsn#">
	SELECT FavID, FavLastModifiedDate
	FROM tblFavourite
	WHERE AccountID = '#SESSION.Auth.AccountID#'
	</cfquery>
	
	<!--- loop through and remove any older or equal to 6 months --->
	<cfloop query="QryGetFavourites">
	<cfif DateDiff("m", FavLastModifiedDate, now()) gte 6>
	<cfset isRemoved=removeFavourite(FavID)>
	</cfif>
	</cfloop>


</cffunction>

<!--- saveFavourites: called after checkout to update favourites --->
<cffunction name="saveFavourites" output="false" returntype="boolean" access="public">
<cfargument name="BasketList" type="query" required="true" />
	
<cfset var isSuccessful = false />
	
	<cfloop query="ARGUMENTS.BasketList">
	<cfset isSuccessful = addFavourite(StockCode, now())>
	</cfloop>
	
	<cfreturn true /> 

</cffunction>

<!--- getFavourites: called and used for XW Table--->
<cffunction name="getFavourites" output="false" returntype="query" access="public">

	<!---refresh if need anything has been deleted--->
	<cfif isdefined("SESSION.AUTH.refreshFavourites") AND SESSION.AUTH.refreshFavourites>
		<cfquery name="QryGetFavourites"  datasource="#APPLICATION.dsn#" cachedwithin="#CreateTimeSpan(0, 0, 0, 0)#">
			SELECT f.FavID, p.StockID, f.StockCode, p.description, p.unitofsale, f.OrderCount, p.OutOfStock, p.saleprice, f.LastOrderDate, f.LastOrderQuantity, f.FavLastModifiedDate
			FROM tblFavourite f, tblProducts p, tblCategory c
			WHERE  f.StockCode = p.StockCode
			AND p.StockCategoryNumber = c.CategoryID
			AND c.Disabled = 0
			AND f.AccountID = '#SESSION.AUTH.AccountID#'
			ORDER by p.description asc
		</cfquery>
	
	<cfelse>
	<!---cache for 3 hours, for repeated requests--->
		<cfquery name="QryGetFavourites"  datasource="#APPLICATION.dsn#" cachedwithin="#CreateTimeSpan(0, 3, 0, 0)#">
			SELECT f.FavID, p.StockID, f.StockCode, p.description, p.unitofsale, f.OrderCount, p.OutOfStock, p.saleprice, f.LastOrderDate, f.LastOrderQuantity, f.FavLastModifiedDate
			FROM tblFavourite f, tblProducts p, tblCategory c
			WHERE  f.StockCode = p.StockCode
			AND p.StockCategoryNumber = c.CategoryID
			AND c.Disabled = 0
			AND f.AccountID = '#SESSION.AUTH.AccountID#'
			ORDER by p.description asc
		</cfquery>
		<cfset SESSION.AUTH.refreshFavourites=false/>
	</cfif>
	
	<cfreturn QryGetFavourites /> 

</cffunction>



<cffunction name="getStockIDs" output="false" returntype="string" access="public">

	<cfquery name="QryGetStockIDs"  datasource="#APPLICATION.dsn#">
		SELECT p.StockID
		FROM tblFavourite f, tblProducts p
		WHERE  f.StockCode = p.StockCode
		AND f.AccountID = '#SESSION.AUTH.AccountID#'
	</cfquery>
	
	<cfreturn valuelist(QryGetStockIDs.StockID) /> 

</cffunction>

<!--- removeFavourite: removes a favourites at the shopper's request --->
<cffunction name="removeFavourite" output="false" returntype="boolean" access="public">
<cfargument name="FavID" type="numeric" required="true" />
	<cfquery name="QryRemoveFavourite"  datasource="#APPLICATION.dsn#">
	DELETE FROM tblFavourite
	WHERE FavID = #ARGUMENTS.FavID#
	</cfquery>
	
	<cfset SESSION.AUTH.refreshFavourites=true/>
	<cfreturn true /> 

</cffunction>

<!--- addFavourite: removes a favourites at the shopper's request --->
<cffunction name="addFavourite" output="false" returntype="boolean" access="public">
<cfargument name="StockCode" type="string" required="true" />
<cfargument name="LastOrderDate" type="date" required="false" />
<cfargument name="LastOrderQuantity" type="numeric" required="false" />

    <cfscript>APPLICATION.applog.write("#timeformat(now(), 'H:MM:SS')# In add Favourites");</cfscript>

	<!--- does it exist? --->
	<cfquery name="QryCheckFavourite"  datasource="#APPLICATION.dsn#" result="r">
	SELECT FavID  FROM tblFavourite
	WHERE  AccountID  = '#SESSION.Auth.AccountID#'
	AND StockCode  = '#ARGUMENTS.StockCode#'
	</cfquery>


        <cfscript>APPLICATION.applog.write("#timeformat(now(), 'H:MM:SS')# QryCheckFavourite.recordcount is  " & r.sql);</cfscript>
        <cfscript>APPLICATION.applog.write("#timeformat(now(), 'H:MM:SS')# QryCheckFavourite.recordcount is  " & QryCheckFavourite.recordcount);</cfscript>
	<!--- Favourite Does Not Exist, add to favourites --->
	<cfif QryCheckFavourite.recordCount eq 0>
		
		
		<cfquery name="QryAddFavourite"  datasource="#APPLICATION.dsn#">
		INSERT INTO tblFavourite
		(AccountID, 
		 StockCode, 
		<cfif isdefined("ARGUMENTS.LastOrderDate")>LastOrderDate,</cfif>
		<cfif isdefined("ARGUMENTS.LastOrderQuantity")>LastOrderQuantity,</cfif>
		FavLastModifiedDate)
		VALUES (
		'#SESSION.Auth.AccountID#', 
		'#ARGUMENTS.StockCode#',  
		<cfif isdefined("ARGUMENTS.LastOrderDate")>
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#ARGUMENTS.LastOrderDate#" />,
		</cfif>
		<cfif isdefined("ARGUMENTS.LastOrderQuantity")>
			<cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.LastOrderQuantity#" />,
		</cfif>
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
		)
		</cfquery>
	
	<!--- Favourite Exists, either because item has been order before or shopper clicked
	'add to favourites' when item already exists --->
	<cfelseif QryCheckFavourite.recordCount eq 1>
		
		<cfquery name="QryUpdateFavourite"  datasource="#APPLICATION.dsn#">
		UPDATE tblFavourite
		SET FavLastModifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
		<cfif isdefined("ARGUMENTS.LastOrderDate")>
			,LastOrderDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ARGUMENTS.LastOrderDate#" />
		</cfif>
		<cfif isdefined("ARGUMENTS.LastOrderQuantity")>
			,LastOrderQuantity = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.LastOrderQuantity#" />
		</cfif>
		WHERE FavID = #QryCheckFavourite.FavID#
		</cfquery>
	
	</cfif>
	
	<cfset SESSION.AUTH.refreshFavourites=true/>
	<cfreturn true /> 

</cffunction>

<!--- listAddFavourite: updates the favourites list from a list of StockIDs--->
<cffunction name="listAddFavourite" access="public" returnType="void" output="false" 
              hint="Adds items from a list to the shopping cart">
    
	<cfargument name="StockIDList" type="string" required="Yes">
	<cfargument name="QuantityList" type="string" required="Yes">
	
	<!--- iterate through list of Stock IDs adding each to the basket--->
	<cfscript>
	for (x=1; x lte listlen(StockIDList); x=x+1) {
			addFavourite(VARIABLES.view_do.getStockCode(ListGetAt(StockIDList, x)), now(), ListGetAt(QuantityList, x));
	}
	
	</cfscript>
  <cfset SESSION.AUTH.refreshFavourites=true/>
</cffunction> 

<!--- loadFavourites: runs a cron job to load favourites from Sage for a particular Account --->
<cffunction name="loadFavourites" output="false" returntype="query" access="public">


</cffunction>


</cfcomponent>