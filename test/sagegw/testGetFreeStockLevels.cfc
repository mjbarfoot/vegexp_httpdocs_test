<cfcomponent name="testGetFreeStockLevels" extends="mxunit.framework.TestCase" output="true">

    <cffunction name="beforeTests" returntype="void" access="public" hint="put things here that you want to run before each test">
			<cfquery name="q" datasource="#APPLICATION.dsn#">
				SELECT STOCKCODE FROM tblProducts
				WHERE STOCKCODE LIKE '%A'
			</cfquery>
    </cffunction>


	<cffunction name="setup"returntype="void" access="public" hint="put things here that you want to run before each test" output="true">

        <cfset sagegw = createObject("component","cfc.sagegw.sageWSGW").init() />
		<cfset result = sagegw.getFreeStockLevels(q) />
		<cfoutput>
			#result#
		</cfoutput> 		

    </cffunction>



	<!---<cffunction name="isEmpty" returntype="void" access="private">
 		<cfscript>
			TestProduct = createObject("component","cfc.model.product.product");
			AssertEquals(true, TestProduct.isEmpty(), "Non use of INIT method returns empty product");
		
		</cfscript>
	</cffunction> --->



</cfcomponent>