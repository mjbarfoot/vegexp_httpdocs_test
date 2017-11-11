<!--- 
	Retrieves product information to the shopper. Added to support 
	managed lists and price bands
	
	Author:  Matt Barfoot- Clearview Webmedia Limited
	Purpose:     Maintains favourtites in the database
	Date: 		 07/07/2006
	History:
--->

<cfcomponent output="false" name="productsDO" displayname="productsDO" hint="Retrieves product lists">

<cffunction name="init" returntype="cfc.departments.productsDO" access="public" hint="returns an instance of this class" output="false">
<cfset VARIABLES.cacheTime =createDateTime(year(now()), month(now()), day(now()), 6, 0, 0) / >
<cfif isdefined("URL.resetQueryCache")>
	<cfset VARIABLES.cacheTime = createDateTime(year(now()), month(now()), day(now())+1, 6, 0, 0) / >
</cfif>

<cfreturn THIS/>
</cffunction>

<cffunction name="get" output="false" returntype="query" access="public" hint="Retrieves product list data, compiling price band and managed list data">
<cfargument name="AllowedListCode" 			required="false" type="string" hint="Alphanumeric code referenced to the managed list" default="">
<cfargument name="AllowedListType" 			required="false" type="string" hint="1 or 0 to denote allowed or disallowed" default="1">
<cfargument name="priceband" 				required="false" type="string" hint="The priceband code for the customer" default="Standard">
<cfargument name="DepartmentID" 			required="false" type="numeric" default=0 hint="limits the returned query to a specific department">
<cfargument name="CategoryID" 				required="false" type="numeric" default=0 hint="limits the returned query to a specific category">
<cfargument name="Description" 				required="false" type="string" default="" hint="does like search on description">
<cfargument name="ingredientClassColumn" 	required="false" type="string" default="" hint="ingredient class i.e. org, vegan or glutenfree">
<cfargument name="freeTextSearch" 			required="false" type="string" default="" hint="a free text search on stockcode or description">

<cfif ARGUMENTS.AllowedListCode neq "">
    <cfif ARGUMENTS.AllowedListType eq 1>
		<cfset q = getAllowedListProducts(ARGUMENTS.AllowedListCode, ARGUMENTS.AllowedListType, ARGUMENTS.priceband, ARGUMENTS.DepartmentID, ARGUMENTS.CategoryID, ARGUMENTS.Description, ARGUMENTS.ingredientClassColumn, ARGUMENTS.freeTextSearch) />
    <cfelse>
        <cfset q = getDisallowedListProducts(ARGUMENTS.AllowedListCode, ARGUMENTS.AllowedListType, ARGUMENTS.priceband, ARGUMENTS.DepartmentID, ARGUMENTS.CategoryID, ARGUMENTS.Description, ARGUMENTS.ingredientClassColumn, ARGUMENTS.freeTextSearch) />
    </cfif>
<cfelse>
		<cfset q = getStandardListProducts(ARGUMENTS.priceband, ARGUMENTS.DepartmentID, ARGUMENTS.CategoryID, ARGUMENTS.Description, ARGUMENTS.ingredientClassColumn, ARGUMENTS.freeTextSearch) />
</cfif>

<cfreturn q />

</cffunction>

<cffunction name="getAllowedListProducts" output="false" returntype="any" access="public" hint="Retrieves product list data, compiling price band and managed list data">
<cfargument name="AllowedListCode" required="true" type="string" hint="Alphanumeric code referenced to the managed list">
<cfargument name="AllowedListType" 			required="false" type="string" hint="1 or 0 to denote allowed or disallowed" default="1">
<cfargument name="priceband" required="true" type="string" hint="The priceband code for the customer">
<cfargument name="DepartmentID" required="true" type="numeric">
<cfargument name="CategoryID" 	required="false" type="numeric" default=0 hint="limits the returned query to a specific category">
<cfargument name="Description" 	required="false" type="string" default="" hint="does like search on description">
<cfargument name="ingredientClassColumn" 	required="false" type="string" default="" hint="ingredient class i.e. org, vegan or glutenfree">
<cfargument name="freeTextSearch" 			required="false" type="string" default="" hint="a free text search on stockcode or description">

<cfscript> 
var i = 1;
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
</cfscript>

<cftry>

	<cfquery name="q" datasource="#APPLICATION.dsn#" blockfactor="100" result="res" cachedAfter="#VARIABLES.cacheTime#">
	SELECT 	P.STOCKID, MI.STOCKCODE, P.DESCRIPTION, PR.PRICE AS SALEPRICE, P.UNITOFSALE, P.UNITOFWEIGHT, P.OUTOFSTOCK, P.STOCKQUANTITY,
	(select count(1) from tblFavourite where accountid = '#SESSION.AUTH.AccountID#' and stockcode =  P.STOCKCODE) as IsFavourite
	FROM 	tblAuthManagedItem MI, tblProducts P, tblPrices PR, tblCategory CAT
	WHERE 	MI.STOCKCODE = P.STOCKCODE
	<cfif ARGUMENTS.allowedListType eq 1>
        AND 		MI.STOCKCODE = PR.STOCKCODE
    <cfelse>
        AND 		MI.STOCKCODE != PR.STOCKCODE
	</cfif>

	AND 		MI.LIST = '#ARGUMENTS.AllowedListCode#'
	AND 		UCASE(PR.BANDNAME) = '#ARGUMENTS.priceband#'
    AND     P.STOCKCATEGORYNUMBER = CAT.CategoryID
    AND     CAT.disabled = 0  
	<cfif ARGUMENTS.DepartmentID>
	AND 	P.DEPARTMENT = #ARGUMENTS.DepartmentID#
	</cfif>
	<cfif ARGUMENTS.CategoryID>
	AND 	P.STOCKCATEGORYNUMBER = #ARGUMENTS.CategoryID#
   
	</cfif>
	<cfif ARGUMENTS.Description neq "">
	AND DESCRIPTION LIKE '%#ARGUMENTS.DESCRIPTION#%'
	</cfif>
	<cfif ARGUMENTS.ingredientClassColumn neq "" AND ARGUMENTS.ingredientClassColumn neq "ALL">
	AND #ARGUMENTS.ingredientClassColumn# = 1
	</cfif>
	<cfif ARGUMENTS.freeTextSearch neq "">
	AND (P.STOCKCODE like '%#safeUrlParam(ARGUMENTS.freeTextSearch)#%' OR P.DESCRIPTION like '%#safeUrlParam(ARGUMENTS.freeTextSearch)#%')
	</cfif>
	ORDER BY P.DESCRIPTION ASC
	</cfquery>

    <cfscript>
        tickEnd=getTickCount();
        tickinterval=decimalformat((tickend-tickbegin)/1000);
        APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getManagedListProducts - fetched #q.recordcount# records in #tickinterval# ms");
        APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getManagedListProducts - #res.sql#");
        ret = q;
    </cfscript>

    <cfcatch type="any">
	<cfscript>
	formattedError=returnFormattedQueryError("getManagedListProducts", "TBLAUTHMANAGEDITEM,TBLPRODUCTS,TBLPRICES",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>

    <cfif APPLICATION.AppMode eq "development">
        <cfrethrow />
    </cfif>

</cfcatch>
</cftry>


<cfreturn ret />

</cffunction>

<cffunction name="getStandardListProducts" output="false" returntype="any" access="public" hint="Retrieves product list data, compiling price band and managed list data">
    <cfargument name="priceband" required="true" type="string" hint="The priceband code for the customer">
    <cfargument name="DepartmentID" required="true" type="numeric">
    <cfargument name="CategoryID" 	required="false" type="numeric" default=0 hint="limits the returned query to a specific category">
    <cfargument name="Description" 	required="false" type="string" default="" hint="does like search on description">
    <cfargument name="ingredientClassColumn" 	required="false" type="string" default="" hint="ingredient class i.e. org, vegan or glutenfree">
    <cfargument name="freeTextSearch" 			required="false" type="string" default="" hint="a free text search on stockcode or description">
    <cfscript>
    var tickBegin=getTickCount();
    var tickEnd=0;
    var tickinterval=0;
    var ret=false;
    </cfscript>

    <cftry>
        <cfquery name="q" datasource="#APPLICATION.dsn#" blockfactor="100" result="res" cachedAfter="#VARIABLES.cacheTime#">
        SELECT 	P.STOCKID,P.STOCKCODE, P.DESCRIPTION, PR.PRICE as SALEPRICE, P.UNITOFSALE, P.UNITOFWEIGHT, P.OUTOFSTOCK, P.STOCKQUANTITY,
        (select count(1) from tblFavourite where accountid = '#SESSION.AUTH.AccountID#' and stockcode =  P.STOCKCODE) as IsFavourite
        FROM 	tblProducts P, tblPrices PR, tblCategory CAT
        WHERE 	P.STOCKCODE = PR.STOCKCODE
        AND		PR.BANDNAME = '#ARGUMENTS.priceband#'
        AND     P.STOCKCATEGORYNUMBER = CAT.CategoryID
        AND     CAT.disabled = 0
        <cfif ARGUMENTS.DepartmentID>
        AND 	P.DEPARTMENT = #ARGUMENTS.DepartmentID#
        </cfif>
        <cfif ARGUMENTS.CategoryID>
        AND     P.STOCKCATEGORYNUMBER = #ARGUMENTS.CategoryID#
        </cfif>
        <cfif ARGUMENTS.Description neq "">
        AND DESCRIPTION LIKE '%#ARGUMENTS.DESCRIPTION#%'
        </cfif>
        <cfif ARGUMENTS.ingredientClassColumn neq "" AND ARGUMENTS.ingredientClassColumn neq "ALL">
        AND #ARGUMENTS.ingredientClassColumn# = 1
        </cfif>
        <cfif ARGUMENTS.freeTextSearch neq "">
        AND (P.STOCKCODE like '%#safeUrlParam(ARGUMENTS.freeTextSearch)#%' OR P.DESCRIPTION like '%#safeUrlParam(ARGUMENTS.freeTextSearch)#%')
        </cfif>
        ORDER BY P.DESCRIPTION ASC
        </cfquery>


        <cfscript>
        tickEnd=getTickCount();
        tickinterval=decimalformat((tickend-tickbegin)/1000);
        APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getStandardListProducts - fetched #q.recordcount# records in #tickinterval# ms");
        APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getStandardListProducts - #res.sql#");
        ret = q;
        </cfscript>

    <cfcatch type="any">
        <cfrethrow />
        <cfscript>
        formattedError=returnFormattedQueryError("getStandardListProducts", "TBLPRODUCTS,TBLPRICES",  "SELECT", cfcatch);
        tickEnd=getTickCount();
        tickinterval=decimalformat((tickend-tickbegin)/1000);
        APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
        </cfscript>
    </cfcatch>
    </cftry>


<cfreturn ret />


</cffunction>

<cffunction name="getDisallowedListProducts" output="false" returntype="any" access="public" hint="Retrieves product list data, compiling price band and managed list data">
    <cfargument name="AllowedListCode" required="true" type="string" hint="Alphanumeric code referenced to the managed list">
    <cfargument name="AllowedListType" 			required="false" type="string" hint="1 or 0 to denote allowed or disallowed" default="1">
    <cfargument name="priceband" required="true" type="string" hint="The priceband code for the customer">
    <cfargument name="DepartmentID" required="true" type="numeric">
    <cfargument name="CategoryID" 	required="false" type="numeric" default=0 hint="limits the returned query to a specific category">
    <cfargument name="Description" 	required="false" type="string" default="" hint="does like search on description">
    <cfargument name="ingredientClassColumn" 	required="false" type="string" default="" hint="ingredient class i.e. org, vegan or glutenfree">
    <cfargument name="freeTextSearch" 			required="false" type="string" default="" hint="a free text search on stockcode or description">
    <cfscript>
        var tickBegin=getTickCount();
        var tickEnd=0;
        var tickinterval=0;
        var ret=false;
    </cfscript>

    <cftry>
        <cfquery name="q" datasource="#APPLICATION.dsn#" blockfactor="100" result="res" cachedAfter="#VARIABLES.cacheTime#">
	SELECT 	P.STOCKID,P.STOCKCODE, P.DESCRIPTION, PR.PRICE as SALEPRICE, P.UNITOFSALE, P.UNITOFWEIGHT, P.OUTOFSTOCK, P.STOCKQUANTITY,
	(select count(1) from tblFavourite where accountid = '#SESSION.AUTH.AccountID#' and stockcode =  P.STOCKCODE) as IsFavourite
	FROM 	tblProducts P, tblPrices PR, tblCategory CAT
	WHERE 	P.STOCKCODE = PR.STOCKCODE
	AND		PR.BANDNAME = '#ARGUMENTS.priceband#'
    AND     P.STOCKCATEGORYNUMBER = CAT.CategoryID
    AND     NOT EXISTS (SELECT * FROM tblAuthManagedItem where stockcode = P.STOCKCODE and list = '#ARGUMENTS.AllowedListCode#')
    AND     CAT.disabled = 0
	<cfif ARGUMENTS.DepartmentID>
            AND 	P.DEPARTMENT = #ARGUMENTS.DepartmentID#
        </cfif>
            <cfif ARGUMENTS.CategoryID>
                AND     P.STOCKCATEGORYNUMBER = #ARGUMENTS.CategoryID#
            </cfif>
            <cfif ARGUMENTS.Description neq "">
                AND DESCRIPTION LIKE '%#ARGUMENTS.DESCRIPTION#%'
            </cfif>
            <cfif ARGUMENTS.ingredientClassColumn neq "" AND ARGUMENTS.ingredientClassColumn neq "ALL">
                AND #ARGUMENTS.ingredientClassColumn# = 1
            </cfif>
            <cfif ARGUMENTS.freeTextSearch neq "">
                AND (P.STOCKCODE like '%#safeUrlParam(ARGUMENTS.freeTextSearch)#%' OR P.DESCRIPTION like '%#safeUrlParam(ARGUMENTS.freeTextSearch)#%')
            </cfif>
            ORDER BY P.DESCRIPTION ASC
        </cfquery>


        <cfscript>
            tickEnd=getTickCount();
            tickinterval=decimalformat((tickend-tickbegin)/1000);
            APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getDisallowedListProducts - fetched #q.recordcount# records in #tickinterval# ms");
            APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getDisallowedListProducts - #res.sql#");
            ret = q;
        </cfscript>

        <cfcatch type="any">

            <cfscript>
                formattedError=returnFormattedQueryError("getStandardListProducts", "TBLPRODUCTS,TBLPRICES",  "SELECT", cfcatch);
                tickEnd=getTickCount();
                tickinterval=decimalformat((tickend-tickbegin)/1000);
                APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
            </cfscript>
            <cfrethrow />
           <cfif APPLICATION.Appmode eq "development">
               <cfrethrow />
           </cfif>
        </cfcatch>
    </cftry>

    <cfreturn ret />
 </cffunction>


<cffunction name="getLowStockLevels" returntype="query" access="public" hint="returns a query of stockcodes">
<cfargument name="stocklevel" type="numeric" required="true" />
	
			<cfquery name="q" datasource="#APPLICATION.dsn#">
				SELECT STOCKCODE FROM tblProducts
				WHERE STOCKQUANTITY <= #ARGUMENTS.STOCKLEVEL#
			</cfquery>
			
			<cfreturn q />
</cffunction>


<cffunction name="setStockLevel" returntype="boolean" access="public" hint="updates stock levels based upon an array passed in">
<cfargument name="a" type="array" required="true">	

<cfloop from="1" to="#arraylen(ARGUMENTS.a)#" index="i">
	<cfquery name="q" datasource="#APPLICATION.dsn#">
			UPDATE tblProducts
			SET STOCKQUANTITY = <cfqueryparam cfsqltype="CF_SQL_FLOAT" value="#ARGUMENTS.a[i][2]#">,
			<cfif ARGUMENTS.a[i][2] eq 0>
				OUTOFSTOCK = 1
			<cfelse>
				OUTOFSTOCK = 0
			</cfif>
			WHERE STOCKCODE = '#ARGUMENTS.a[i][1]#'
	</cfquery>	
</cfloop>

<cfreturn true/>

</cffunction>


<cffunction name="getFavourites" output="false" returntype="query" access="public" hint="Retrieves product list data, compiling price band and managed list data">
<cfargument name="AccountID" 					required="true" type="string" hint="ID of the user" />
<cfargument name="AllowedListCode" 			required="false" type="string" hint="Alphanumeric code referenced to the managed list" default="" />
<cfargument name="AllowedListType" 			required="false" type="string" hint="0 or 1 if allowed or disallowed list type" default="1" />
<cfargument name="priceband" 				required="false" type="string" hint="The priceband code for the customer" default="Standard" />

<cfscript> 
var tickBegin=getTickCount();
var tickEnd=0;
var tickinterval=0;
var ret=false;
var cacheSpan=0;

if (isdefined("SESSION.AUTH.refreshFavourites") AND SESSION.AUTH.refreshFavourites) {
cacheSpan=createDateTime(year(now()), month(now()), day(now()), hour(now()), minute(now()), (second(now())));
} else {
cacheSpan=createDateTime(year(now()), month(now()), day(now()), 6, 0, 0);
}
</cfscript>

<cftry>
	<cfquery name="q" datasource="#APPLICATION.dsn#" blockfactor="100" result="res" cachedAfter="#cacheSpan#">
	SELECT 	F.FAVID,
			P.STOCKID, 
			P.DESCRIPTION, 
			P.UNITOFSALE, 
			F.ORDERCOUNT, 
			P.OUTOFSTOCK, 
			PR.PRICE as SALEPRICE, 
			P.UNITOFWEIGHT, 
			F.LASTORDERDATE, 
			F.LASTORDERQUANTITY, 
			F.FAVLASTMODIFIEDDATE,
			P.STOCKQUANTITY,
	<!---if customer can only select from auth allowed list --->
	<cfif ARGUMENTS.AllowedListCode neq  "" and ARGUMENTS.AllowedListType EQ 1>
	MI.STOCKCODE
	FROM 	tblProducts P, tblPrices PR, tblFavourite F, tblCategory C, tblAuthManagedItem MI
	WHERE	MI.STOCKCODE = P.STOCKCODE
    AND 		MI.STOCKCODE = PR.STOCKCODE
	AND 		MI.LIST = '#ARGUMENTS.AllowedListCode#'
	AND  	F.STOCKCODE = P.STOCKCODE
    <!---if customer can only select from auth disallowed list --->
    <cfelseif ARGUMENTS.AllowedListCode neq  "" and ARGUMENTS.AllowedListType EQ 0>
    F.STOCKCODE
    FROM 	tblProducts P, tblPrices PR, tblFavourite F, tblCategory C
    WHERE 	P.STOCKCODE = PR.STOCKCODE
    AND  	F.STOCKCODE = P.STOCKCODE
    AND     NOT EXISTS (SELECT * FROM tblAuthManagedItem where stockcode = P.stockcode and list = '#ARGUMENTS.AllowedListCode#')
	<!---customer can use standard stock list--->
	<cfelse>
	F.STOCKCODE
	FROM 	tblProducts P, tblPrices PR, tblFavourite F, tblCategory C
	WHERE 	P.STOCKCODE = PR.STOCKCODE 
	AND  	F.STOCKCODE = P.STOCKCODE
	</cfif>
	AND 	P.STOCKCATEGORYNUMBER = C.CATEGORYID
	AND  	C.DISABLED = 0
	AND		F.STOCKCODE = P.STOCKCODE
	AND		PR.BANDNAME = '#ARGUMENTS.priceband#'
	AND 	F.ACCOUNTID = '#ARGUMENTS.AccountID#'
	ORDER BY P.DESCRIPTION ASC
	</cfquery>


	<cfscript>
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getFavourites - fetched #q.recordcount# records in #tickinterval# ms");
	APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# Success: getFavourites - #res.sql#");
	ret = q;
	</cfscript>

<cfcatch type="any">
	<cfrethrow />
	<cfscript>
	formattedError=returnFormattedQueryError("getStandardListProducts", "TBLPRODUCTS,TBLPRICES",  "SELECT", cfcatch);
	tickEnd=getTickCount();
	tickinterval=decimalformat((tickend-tickbegin)/1000);
	APPLICATION.QUERYLOG.write("#timeformat(now(), 'H:MM:SS')# " & formattedError);
	</cfscript>	
</cfcatch>
</cftry>


<cfreturn ret />


</cffunction>


<cffunction name="returnFormattedQueryError" output="false" access="private" returntype="String" hint="returns a consistent error message from a database catch object">
<cfargument name="fn" type="string" required="true" hint="the name of the function that errored" />
<cfargument name="tbl" type="string" required="true" hint="the name of the database table on which the query was performed" />
<cfargument name="op" type="string" required="true" hint="the type of operation being performed">
<cfargument name="catchOb" type="Any" required="true" hint="the database catch object holding the error info" />
<cfargument name="customText" type="string" required="false" hint="anything else you want to add" default=""/>

<cfscript>
var error_text="";
var error_custom=ARGUMENTS.customText;
var error_values="";
error_text = "Error: #ARGUMENTS.fn# table:#ARGUMENTS.tbl#. #ARGUMENTS.op# Failed.";
if (len(error_custom)) {
	error_text = error_text & " #error_custom# .";
}
error_text = error_text &  " SQL error debug: ";
</cfscript>

    <cfif isdefined("ARGUMENTS.catchOb.Detail")><cfset error_text = error_text & cfcatch.Detail /></cfif>
    <cfif isdefined("ARGUMENTS.catchOb.NativeErrorCode")><cfset error_text = error_text & cfcatch.NativeErrorCode /></cfif>
    <cfif isdefined("ARGUMENTS.catchOb.SQLState")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>
    <cfif isdefined("ARGUMENTS.catchOb.sql")><cfset error_text = error_text &  " " & cfcatch.SQLState /></cfif>

<!--- return error and replace any linefeeds, breaks --->
<cfreturn ReReplace(error_text, "\n|\r", " ", "ALL") />

</cffunction>

<cffunction name="safeUrlParam" output="false" returntype="string" access="public">
<cfargument name="paramValue" required="true" type="string" />

<cfreturn ReplaceList(ARGUMENTS.paramValue, "^,[,<,>,`,~,!,/,@,\,##,},$,%,:,;,),(,_,^,{,&,*,=,|,',+,],+,$", " , , , , , , , , , , , , , , , , , , , , ,")>

</cffunction>

</cfcomponent>