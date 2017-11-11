<cfcomponent displayname="productTest" hint="Test the Product Component" extends="mxunit.framework.TestCase" output="false">


        <!--- this will run once after initialization and before setUp() --->
	<cffunction name="beforeTests" returntype="void" access="public" hint="put things here that you want to run before all tests">
		<cfscript>
		   TestProductID = 5491;
		   ProductDO = createObject("component","cfc.departments.do");		
		   ProductQuery = VARIABLES.ProductDO.getItemDetails(TestProductID);
		   discountRate = 0;
	 	   TestProduct = createObject("component","cfc.model.product.product").init(productQuery, discountRate);
		</cfscript>

	</cffunction>
	
	<cffunction name="isEmpty" returntype="void" access="public">
		<cfscript>
			TestProduct = createObject("component","cfc.model.product.product");
			AssertEquals(true, TestProduct.isEmpty(), "Non use of INIT method returns empty product");
		
		</cfscript>
	</cffunction>

	<cffunction name="setStockQuantity" returntype="void" access="public">
	<cfscript>
			TestProduct.setStockQuantity(4);
			AssertEquals(4, TestProduct.getStockQuantity(), "The Quantity in Stock must equal 4");
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>
	</cffunction>
	
	<cffunction name="getProductID" returntype="void" access="public">
	<cfscript>
		Assert(TestProduct.getProductID() eq 5491, "getProductID should return 5491");
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>	
	
	</cffunction>
	
	<cffunction name="getDescription" returntype="void" access="public">
	<cfscript>
		Assert(TestProduct.getDescription() eq "Tofu (ORG) (CHILLED)(Vegan)", "Product Description Test");
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>
	</cffunction>
	
	
	<cffunction name="getPackSize" returntype="void" access="public">
	<cfscript>
		Assert(TestProduct.getPackSize() eq "3kg", "Packsize Test");	
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>
	
	</cffunction>
	
		
	<cffunction name="getSalePrice" returntype="void" access="public">
	<cfscript>
		AssertEquals("19.23", TestProduct.getSalePrice(), "Salesprice Test");		
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>	
	</cffunction>

	<cffunction name="getPortionCost" returntype="void" access="public">
	<cfscript>
		   TestProductID2 = 5915;
		   ProductQuery2 = VARIABLES.ProductDO.getItemDetails(TestProductID2);
	 	   TestProduct2 = createObject("component","cfc.model.product.product").init(productQuery2, discountRate);
		AssertEquals("4.83", TestProduct2.getPortionCost(), "PortionCost Test");		
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>	
	</cffunction>


	<cffunction name="getTaxCode" returntype="void" access="public">
	<cfscript>
		AssertEquals(0, TestProduct.getTaxCode(), "Taxcode Test");
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>	
	</cffunction>
	
	
	<cffunction name="getTaxRate" returntype="void" access="public">
	<cfscript>
		AssertEquals(0, TestProduct.getTaxRate(), "TaxRate Test");	
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>	
	</cffunction>
	
	<cffunction name="getTaxAmount" returntype="void" access="public">
	<cfscript>
			AssertEquals(0, TestProduct.getTaxAmount(), "Tax Amount Test");
		//AssertEquals(foo, bar, "foo must be bar");
	</cfscript>	
	</cffunction>

</cfcomponent>