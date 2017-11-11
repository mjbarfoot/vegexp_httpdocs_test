<!--- 
	Filename: /cfc/departments/do.cfc 
	Created by:  Matt Barfoot on 15/04/2006 Clearview Webmedia Limited
	Purpose:  Department data object for CRUD operations
--->

<cfcomponent name="do" displayname="do"  output="false" hint="Department data object for CRUD operations">

<!--- / Object declarations / --->
<cfscript>
util 	= createObject("component", "cfc.shop.util");
</cfscript>

<cffunction name="getQryCategories" output="false" returntype="query" access="public">
<cfargument name="department" required="true"  type="string" />


<cfquery name="myQryCategories"  datasource="#APPLICATION.dsn#" cachedafter="#createDateTime(year(now()), month(now()), day(now()), 6, 0, 0)#">
SELECT replace(c.Category, "&" ,"&amp;") as Category, c.CategoryID, count(p.StockCategoryNumber) AS pCount
FROM veappdata.tblCategory AS c,
veappdata.tblProducts AS p
<cfif SESSION.AUTH.allowedlist neq "" AND SESSION.AUTH.AllowedListType eq 1>
,tblAuthManagedItem MI
</cfif>
WHERE UCASE(c.Department) = '#trim(UCASE(arguments.department))#'
AND c.CategoryID LIKE p.StockCategoryNumber
<cfif session.shopper.prod_filter neq "ALL">
AND p.#session.shopper.prod_filter# = true
</cfif>
AND c.DISABLED = 0
<cfif SESSION.AUTH.allowedlist neq "">
    <cfif SESSION.Auth.AllowedListType eq 1>
        AND MI.STOCKCODE = p.STOCKCODE
        AND MI.LIST = '#SESSION.AUTH.AllowedList#'
    <cfelse>
        AND NOT EXISTS (select 1 from tblAuthManagedItem where stockcode = p.stockcode and list = '#SESSION.AUTH.allowedlist#')
    </cfif>
</cfif>
GROUP BY CategoryID, Category
ORDER BY Category ASC;
</cfquery>

<cfreturn myQryCategories /> 
</cffunction>

<cffunction name="getQryCountStockByCategory" output="false" returntype="numeric" access="public">
<cfargument name="StockCategoryNumber" type="numeric" required="true" />

<cfquery name="myQryCategories"  datasource="#APPLICATION.dsn#">
SELECT count(StockCategoryNumber) AS pCount
FROM tblProducts
WHERE StockCategoryNumber = '#ARGUMENTS.StockCategoryNumber#'
</cfquery>

<cfreturn myQryCategories.pCount /> 

</cffunction>

<cffunction name="getCategoryName" output="false" returntype="string" access="public">
<cfargument name="Category_ID" required="true"  type="string" />

<cfif ARGUMENTS.Category_ID neq "ALL">
<cftry>	
	<cfquery name="myQryGetCategoryName"  datasource="#APPLICATION.dsn#">
	SELECT replace(Category, "&" ,"&amp;") as Category
	FROM tblCategory
	WHERE CategoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.Category_ID#" /> 
	</cfquery>
	<cfreturn myQryGetCategoryName.Category /> 
<cfcatch type="any">
	<cfreturn "Category Not Found">
</cfcatch>
</cftry>
<cfelse>
	<cfreturn "Showing All Products" />
</cfif>

</cffunction>

<cffunction name="getCategories" output="false" returntype="query" access="public">

	<cfquery name="myQryGetCategories"  datasource="#APPLICATION.dsn#">
	SELECT Department, CategoryID, replace(Category, "&" ,"and") as Category
	FROM tblCategory 
	WHERE DISABLED = 0
	order by Department asc, Category Asc
	</cfquery>
	<cfreturn myQryGetCategories /> 

</cffunction>

<cffunction name="getFilterCats" output="false" returntype="query" access="public">

	<cfquery name="myQrygetFilterCats"  datasource="#APPLICATION.dsn#">
	SELECT start, end
	FROM tblFilter
	WHERE FilterType = 'category'
	</cfquery>
	<cfreturn myQrygetFilterCats /> 

</cffunction>


<cffunction name="getStockDesc" output="false" returntype="string" access="public">
<cfargument name="productID" required="true"  type="numeric" />

	<cfquery name="myQryGetStockDesc"  datasource="#APPLICATION.dsn#">
	SELECT Description
	FROM tblProducts
	WHERE StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.productID#" /> 
	</cfquery>

	<cfreturn myQryGetStockDesc.Description /> 

</cffunction>

<cffunction name="getPrice" output="false" returntype="string" access="public">
<cfargument name="productID" required="true"  type="numeric" />

	<cfquery name="myQryGetPrice"  datasource="#APPLICATION.dsn#">
	SELECT P.price SalePrice
	FROM tblProducts P, tblPrices PR
	WHERE 	P.STOCKCODE = PR.STOCKCODE
    AND		PR.BANDNAME = '#SESSION.AUTH.priceband#'
	WHERE P.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.productID#" />
	</cfquery>

	<cfreturn myQryGetPrice.SalePrice /> 

</cffunction>

<cffunction name="getItemDetails" output="false" returntype="query" access="public">
    <cfargument name="productID" required="true"  type="numeric" />

    <cfquery name="myQryGetItemDetails"  datasource="#APPLICATION.dsn#">
SELECT  P.StockID, P.StockCode, P.name, P.Description, P.UnitOfSale, PR.price SalePrice, P.StockQuantity
FROM tblProducts P, tblPrices PR
WHERE P.STOCKCODE = PR.STOCKCODE
AND	PR.BANDNAME = '#SESSION.AUTH.priceband#'
AND P.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.productID#" />
    </cfquery>

    <cfreturn myQryGetItemDetails />

</cffunction>

 <!--- New function which incorporates VAT Support
<cffunction name="getItemDetails" output="false" returntype="query" access="public">
<cfargument name="productID" required="true"  type="numeric" />

	<cfquery name="myQryGetItemDetails"  datasource="#APPLICATION.dsn#">
	SELECT StockID, StockCode, Description, UnitOfSale, SalePrice, StockQuantity, TaxCode, TaxRate, TaxAmount
	FROM tblProducts
	WHERE StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.productID#" /> 
	</cfquery>

	<cfreturn myQryGetItemDetails /> 

</cffunction>--->

<cffunction name="getStockCode" output="false" returntype="string" access="public">
<cfargument name="productID" required="true"  type="numeric" />

	<cfquery name="myQryGetStockCode"  datasource="#APPLICATION.dsn#">
	SELECT StockCode
	FROM tblProducts
	WHERE StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.productID#" /> 
	</cfquery>

	<cfreturn myQryGetStockCode.StockCode /> 

</cffunction>

<cffunction name="getVan" output="false" returntype="string" access="public" hint="gets the van numbers for a given account code">
<cfargument name="AccountID" type="string" required="true" hint="the account code for the user">

		<cfquery name="q"  datasource="#APPLICATION.dsn#">
		SELECT VAN FROM tblDeliverySchedule WHERE ACCOUNTID = '#ARGUMENTS.ACCOUNTID#'
		</cfquery>

		<cfreturn valuelist(q.van)>

</cffunction>

<cffunction name="getDeliveryDays" output="false" returntype="string" access="public" hint="gets a list of delivery days for a specified customer">
<cfargument name="AccountID" type="string" required="true" hint="the account code for the user">
	
	<!--- add one to dayofweek in VE monday is 1, but in coldfusion sunday is 1, monday 2 --->
	<cfquery name="q"  datasource="#APPLICATION.dsn#">
	SELECT CASE lcase(DAY)
	WHEN 'any day' THEN 0 
	WHEN 'monday' THEN 1
	WHEN 'tuesday' THEN 2
	WHEN 'wednesday' THEN 3
	WHEN 'thursday' THEN 4
	WHEN 'friday' THEN 5
	END
	AS DAYOFWEEK
	FROM tblDeliverySchedule WHERE ACCOUNTID = '#ARGUMENTS.ACCOUNTID#'
	</cfquery>
	
	<cfreturn valuelist(q.DAYOFWEEK)>

</cffunction>
<!---deprecated
<cffunction name="getDelProfileID" output="false" returntype="numeric" access="public">
<cfargument name="postcodesegment" required="false" default="" />

<cfscript>
var myPostcode="";

/* if no postcode segment was passed then check session.auth as call to method
was when a user is logging back in */
if (ARGUMENTS.postcodesegment eq "") {

	// 6 char postcode
	if (len(session.Auth.Postcode) eq 6) {
		myPostcode = left(session.Auth.Postcode, 3);	
	}
	// 7 char postcode
	else if (len(session.Auth.Postcode eq 7)) {
		myPostcode = left(session.Auth.Postcode, 4);	
	}

} 
// postcode passed to method as part of account registration process
else {
	myPostcode = ARGUMENTS.postcodesegment;	
}
</cfscript>

	<cfquery name="qryGetDelPofileID"  datasource="#APPLICATION.dsn#">
	SELECT DelProfileID
	FROM tblDelPostcode
	WHERE postcode = '#myPostcode#'
	</cfquery>

	<cfif qryGetDelPofileID.recordcount eq 1>
		<cfreturn qryGetDelPofileID.DelProfileID>
	<cfelse>
		<cfreturn 0>
	</cfif>	

</cffunction>
--->

<cffunction name="getOrdByTime" output="false" returntype="string" access="public">


	<cfquery name="myQryGetOrdByTime"  datasource="#APPLICATION.dsn#">
	SELECT OrdByTime
	FROM tblDelProfile
	WHERE DelProfileID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.Auth.DelProfileID#" /> 
	</cfquery>

	<cfreturn myQryGetOrdByTime.OrdByTime /> 

</cffunction>

<cffunction name="getOrderStartTime" output="false" returntype="date" access="public">


	<cfquery name="mygetOrderStartTime"  datasource="#APPLICATION.dsn#">
	SELECT OrdHoursStart
	FROM tblDelProfile
	WHERE DelProfileID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.Auth.DelProfileID#" /> 
	</cfquery>

	<cfreturn mygetOrderStartTime.OrdHoursStart /> 

</cffunction>

<cffunction name="getDelSlots" output="false" returntype="query" access="public">

	<cfquery name="qryGetDelSlots"  datasource="#APPLICATION.dsn#">
	SELECT DelSlotDate, DelSlotTime
	FROM tblDelSlot
	WHERE DelProfileID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.Auth.DelProfileID#" /> 
	</cfquery>

	<cfreturn qryGetDelSlots /> 

</cffunction>

<cffunction name="isAllowedViewFC" output="false" returntype="boolean" access="public">
<cfargument name="DelProfileID" required="true" type="numeric" />

	<cfquery name="qryIsAllowedViewFC"  datasource="#APPLICATION.dsn#">
	SELECT Frozen, Chilled
	FROM tblDelProfile
	WHERE DelProfileID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.DelProfileID#" /> 
	</cfquery>

	<cfif qryIsAllowedViewFC.Frozen eq 1 AND qryIsAllowedViewFC.Chilled eq 1>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>

</cffunction>

<cffunction name="getDelAddress" output="false" returntype="query" access="public">

	<cfquery name="qryGetDelAddress"  datasource="#APPLICATION.dsn#">
	SELECT building, postcode, line1, line2, line3, town, county
	FROM tblUsers
	WHERE AccountID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.Auth.AccountID#" /> 
	</cfquery>

	<cfreturn qryGetDelAddress /> 

</cffunction>

<cffunction name="getDelNotes" output="false" returntype="query" access="public">

	<cfquery name="qrygetDelNotes"  datasource="#APPLICATION.dsn#">
	SELECT delline1, delline2, delline3, delline4, delPostcode
	FROM tblUsers
	WHERE AccountID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.Auth.AccountID#" /> 
	</cfquery>

	<cfreturn qrygetDelNotes /> 

</cffunction>

<cffunction name="getDeliveryContact" output="false" returntype="string" access="public">

	<cfquery name="qryGetDeliveryContact"  datasource="#APPLICATION.dsn#">
	SELECT delContactName
	FROM tblUsers
	WHERE AccountID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.Auth.AccountID#" /> 
	</cfquery>

	<cfreturn qryGetDeliveryContact.delContactName /> 

</cffunction>

<cffunction name="getDelVan" output="false" returntype="string" access="public">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />
	<cfquery name="qryGetDelVan"  datasource="#APPLICATION.dsn#">
	SELECT Van
	FROM tblDeliverySchedule
	WHERE AccountID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.AccountID#" /> 
	</cfquery>

	<cfreturn qryGetDelVan.van /> 

</cffunction>

<cffunction name="getDelDrop" output="false" returntype="string" access="public">
<cfargument name="AccountID" type="string" required="true"  hint="the AccountID of the user" />
	<cfquery name="qryGetDelDrop"  datasource="#APPLICATION.dsn#">
	SELECT DeliveryDrop
	FROM tblDeliverySchedule
	WHERE AccountID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.AccountID#" /> 
	</cfquery>

	<cfreturn qryGetDelDrop.DeliveryDrop /> 

</cffunction>


<cffunction name="getDeliveryDaysByPostcode" output="false" returntype="string" access="public" hint="returns a list of delivery days using first segment of postcode">
<cfargument name="PostCodeSeg" type="string" required="true" hint="the first part of a postcode">

	<cfquery name="q"  datasource="#APPLICATION.dsn#">
	SELECT DISTINCT DS.DAYOFWEEK, 
	CASE WHEN DAYOFWEEK = 0 THEN 'Everday' 
	WHEN DAYOFWEEK = 1 THEN 'Monday'
	WHEN DAYOFWEEK = 2 THEN 'Tuesday'
	WHEN DAYOFWEEK = 3 THEN 'Wednesday'
	WHEN DAYOFWEEK = 4 THEN 'Thursday' 
	WHEN DAYOFWEEK = 5 THEN 'Friday'
	ELSE '' END AS DAY
	FROM tblDeliverySchedule DS, tblUsers U
	WHERE DS.ACCOUNTID = U.ACCOUNTID
	AND DS.DAYOFWEEK != 7
	AND DS.VAN != 9
	AND U.POSTCODE LIKE '#ARGUMENTS.POSTCODESEG#%'
	ORDER BY DAYOFWEEK ASC
	</cfquery>

	<cfif q.recordcount gte 1>
	<cfreturn valuelist(q.day) />
	<cfelse>
	<cfreturn "" />
	</cfif>
</cffunction>

<!---/*******************************************************************************/
	 / ------------------/ PRODUCT INFO /------------------------------------------- /
     /*******************************************************************************/--->

<cffunction name="isProdInfo" output="false" returntype="boolean" access="public">
<cfargument name="StockID" type="numeric" required="true" />
	
	<cfquery name="qryIsProdInfo"  datasource="#APPLICATION.dsn#">
	SELECT 1
	FROM tblProdInfo
	WHERE StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.StockID#" /> 
	</cfquery>

<cfif qryIsProdInfo.recordcount eq 1>
	<cfreturn true />
<cfelse>
	<cfreturn false />
</cfif>
	
</cffunction>

<cffunction name="getProdInfo" output="false" returntype="any" access="public">
<cfargument name="StockID" type="numeric" required="true" />
	
	<cfquery name="qryGetProdInfo"  datasource="#APPLICATION.dsn#">
	SELECT tblProducts.Description as "ShortDesc", tblProdInfo.Description, tblProdInfo.ImageSrc, tblProdInfo.ImageAlt
	FROM tblProdInfo, tblProducts
	WHERE tblProdInfo.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.StockID#" /> 
	AND tblProdInfo.StockID = tblProducts.StockID
	</cfquery>

<cfif qryGetProdInfo.recordcount eq 1>
	<cfreturn qryGetProdInfo />
<cfelse>
	<cfreturn "" />
</cfif>
	
</cffunction>

<!---/*******************************************************************************/
	 / ------------------/ RECIPE /------------------------------------------------- /
     /*******************************************************************************/--->

<cffunction name="isRecipeInfo" output="false" returntype="boolean" access="public">
<cfargument name="StockID" type="numeric" required="true" />
	
	<cfquery name="qryIsRecipeInfo"  datasource="#APPLICATION.dsn#">
	SELECT 1 
	FROM tblRecipeItems, tblProducts
	WHERE tblProducts.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.StockID#" /> 
	AND tblProducts.StockCode = tblRecipeItems.StockCode
	</cfquery>

<cfif qryIsRecipeInfo.recordcount neq 0>
	<cfreturn true />
<cfelse>
	<cfreturn false />
</cfif>
	
</cffunction>

<cffunction name="countRecipe" output="false" returntype="string" access="public">
<cfargument name="ProductID" type="numeric" required="true" />
	
	<cfquery name="qryCountRecipe"  datasource="#APPLICATION.dsn#">
	SELECT 1 
	FROM tblRecipeItems, tblProducts
	WHERE tblProducts.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.ProductID#" /> 
	AND tblProducts.StockCode = tblRecipeItems.StockCode
	</cfquery>

<cfif qryCountRecipe.recordcount neq 0>
	<cfreturn qryCountRecipe.recordcount />
<cfelse>
	<cfreturn 0 />
</cfif>
</cffunction>

<cffunction name="getSingleRecipeInfo" output="false" returntype="any" access="public">
<cfargument name="RecipeID" type="numeric" required="true" />
<cfargument name="ProductID" type="numeric" required="true" />	
	
	<!---if a ProductID has passed as an argument, determine the RecipeID --->
	<cfif ARGUMENTS.RecipeID EQ 0 AND ARGUMENTS.ProductID NEQ 0>
		<cfquery name="qryGetRecipeID"  datasource="#APPLICATION.dsn#">
		SELECT tblRecipeItems.RecipeID 
		FROM tblRecipeItems, tblProducts
		WHERE tblProducts.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.ProductID#" /> 
		AND tblProducts.StockCode = tblRecipeItems.StockCode
		</cfquery>
		
		<!--- set Recipe ID --->
		<cfset ARGUMENTS.RecipeID = qryGetRecipeID.RecipeID>
	</cfif>
	

	<!---update view count--->
	<cfquery name="qryUpdateRecipeViews"  datasource="#APPLICATION.dsn#">
	UPDATE tblRecipe
	SET VIEWS = (VIEWS + 1)
	WHERE recipeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.RecipeID#" />
	</cfquery>

	<cfquery name="qryRecipeInfo"  datasource="#APPLICATION.dsn#">
	SELECT RecipeID, Yield, PrepTime, CookTime, Title, Description, Footer, ImageSrc, ImageAlt 
	FROM tblRecipeInfo
	WHERE recipeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.RecipeID#" />
	</cfquery>

<cfif qryRecipeInfo.recordcount eq 1>
	<cfreturn qryRecipeInfo />
<cfelse>
	<cfreturn "" />
</cfif>

</cffunction>

<cffunction name="getSingleRecipeShort" output="false" returntype="any" access="public">
<cfargument name="RecipeID" type="numeric" required="true" />
	
	<cfquery name="qryRecipeInfo"  datasource="#APPLICATION.dsn#">
	SELECT RecipeID, Yield, PrepTime, CookTime, Title, Description, ThumbSrc, ImageAlt 
	FROM tblRecipeInfo
	WHERE recipeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.RecipeID#" />
	</cfquery>

<cfif qryRecipeInfo.recordcount eq 1>
	<cfreturn qryRecipeInfo />
<cfelse>
	<cfreturn "" />
</cfif>

</cffunction>

<cffunction name="getRecipeInfo" output="false" returntype="any" access="public">
<cfargument name="StockID" type="numeric" required="true" />

	
	
	
	<cfquery name="qryRecipeInfo"  datasource="#APPLICATION.dsn#">
	SELECT tblRecipeItems.recipeID, tblRecipeInfo.Title, tblRecipeInfo.Description, tblRecipeInfo.Footer, tblRecipeInfo.ThumbSrc, tblRecipeInfo.ImageAlt 
	FROM tblRecipeItems, tblRecipeInfo
	WHERE tblRecipeItems.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.StockID#" />
	AND  tblRecipeItems.recipeID = tblRecipeInfo.recipeID
	</cfquery>

<cfif qryRecipeInfo.recordcount neq 0>
	<cfreturn qryRecipeInfo />
<cfelse>
	<cfreturn "" />
</cfif>

</cffunction>

<cffunction name="getRecipeTitles" output="false" returntype="query" access="public">
<cfargument name="ExcludedRecipeID" type="numeric" required="true" />

	<cfquery name="qryPopRecipes"  datasource="#APPLICATION.dsn#">
	SELECT tblRecipeInfo.recipeID, tblRecipeInfo.Title
	FROM tblRecipe, tblRecipeInfo
	WHERE  tblRecipe.recipeID = tblRecipeInfo.recipeID
	AND tblRecipe.recipeID <> #ARGUMENTS.ExcludedRecipeID#
	ORDER By tblRecipe.Views desc
	</cfquery>

<cfreturn qryPopRecipes>

</cffunction>

<cffunction name="getRecipeShorts" output="false" returntype="query" access="public">
<cfargument name="RecipeCatID" type="numeric" required="true" />

	<cfquery name="qryRecipesShorts"  datasource="#APPLICATION.dsn#">
	SELECT r.RecipeID, r.Title, r.Yield, r.PrepTime, r.CookTime
	FROM  tblRecipeInfo r, tblRecipe c
	WHERE r.RecipeID = c.RecipeID
	AND c.RecipeCatID = #ARGUMENTS.RecipeCatID#
	ORDER BY c.RecipeID asc
	</cfquery>

<cfreturn qryRecipesShorts>

</cffunction>

<cffunction name="getRecipesByProductID" output="false" returntype="query" access="public">
<cfargument name="ProductID" type="numeric" required="false" default="0" />

	<cfquery name="qryGetRecipesByProductID"  datasource="#APPLICATION.dsn#">
	SELECT tblRecipeItems.RecipeID, tblProducts.Description
	FROM tblRecipeItems, tblProducts
	WHERE tblProducts.StockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.ProductID#" /> 
	AND tblProducts.StockCode = tblRecipeItems.StockCode
	</cfquery>

<cfreturn qryGetRecipesByProductID>

</cffunction>

<cffunction name="getRecipeCatInfo" output="false" returntype="query" access="public">

	<cfquery name="qryRecipeCatInfo"  datasource="#APPLICATION.dsn#">
	SELECT distinct c.RecipeCatID, r.Title, r.Description, r.Footer, r.Thumbsrc, r.ImageAlt
	FROM  tblRecipeInfo r, tblRecipe c
	WHERE c.RecipeCatID = r.RecipeID
	ORDER BY r.Title asc
	</cfquery>

<cfreturn qryRecipeCatInfo>

</cffunction>

<!---/*******************************************************************************/
	 / ------------------/ SPECIAL OFFERS /---------------------------------------- /
     /*******************************************************************************/--->


<cffunction name="getOfferCatInfo" output="false" returntype="any" access="public">

	<cfquery name="qryGetOfferCatInfo"  datasource="#APPLICATION.dsn#" result="qryResult">
	SELECT OfferID, Description, Discount, Expiry
	FROM tblOfferCat
	WHERE START <= #NOW()#<!--- <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LSDateFormat(now(), 'dd/mm/yyyy')#" /> ---> 
	AND EXPIRY >= #NOW()# <!--- <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LSDateFormat(now(), 'dd/mm/yyyy')#" /> --->  
	</cfquery>


<!---  <cfthrow detail="#qryResult.sql#  #qryGetOfferCatInfo.recordcount#" /> --->

<cfreturn qryGetOfferCatInfo>


</cffunction>

<cffunction name="getOfferShorts" output="false" returntype="any" access="public">
<cfargument name="OfferID" type="numeric" required="true" />

	<cfquery name="qryGetOfferShorts"  datasource="#APPLICATION.dsn#">
	SELECT o.StockCode, p.description as "itemdesc", o.Description, 
	o.ImageSrc, o.ImageAlt, o.ThumbSrc, p.UnitOfSale, p.SalePrice, p.StockID
	FROM  tblOfferInfo o, tblOffer t, tblProducts p
	WHERE o.StockCode = t.Stockcode
	AND   p.Stockcode = t.Stockcode
	AND   t.OfferID = #ARGUMENTS.OfferID#
	ORDER BY o.OrderInfoID asc
	</cfquery>

<cfreturn qryGetOfferShorts>

</cffunction>

</cfcomponent>