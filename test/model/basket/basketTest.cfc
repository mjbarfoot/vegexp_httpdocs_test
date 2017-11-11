<cfcomponent name="basketTest" extends="mxunit.framework.TestCase" output="false">


 <!--- this will run before every single test in this test case --->

    <cffunction name="setUp" returntype="void" access="public" hint="put things here that you want to run before each test">
		<cfscript>
		testBasket = createObject("component","cfc.model.basket.basket").init(stockDO=StockDO, discountRate=discountRate);
		</cfscript>
    </cffunction>

	<!--- this will run after every single test in this test case --->
	<cffunction name="tearDown" returntype="void" access="public" hint="put things here that you want to run after each test">

	</cffunction>

        <!--- this will run once after initialization and before setUp() --->
	<cffunction name="beforeTests" returntype="void" access="public" hint="put things here that you want to run before all tests">
		<cfscript>
		   stockDO = createObject("component","cfc.departments.do");	
		   discountRate = 0;
		   	
		</cfscript>

	</cffunction>

	<!--- this will run once after all tests have been run 
	<cffunction name="afterTests" returntype="void" access="public" hint="put things here that you want to run after all tests">

	</cffunction>--->
	
	<cffunction name="add" returntype="void" access="public">
	<cfscript>
		var testProduct = 6155;
		testBasket.add(testProduct);
		assertEquals(1, testBasket.getQuantity(testProduct), "Quantity of product in basket should be 1");
	</cfscript>
	</cffunction>
	
	<cffunction name="getProduct" returntype="void" access="public">
		<cfscript>
		var testProduct = 6012;
		var myProduct = "";
		testBasket.add(testProduct);
		myProduct = testBasket.getProduct(testProduct);
		assertEquals("Kidei Boats (Bamboo) 190mm SP7", myProduct.getDescription(), "Description test for ProductID 6012");
		</cfscript>
	
	</cffunction>
	
	
	
	<cffunction name="listAdd" returntype="void" access="public">
		<cfscript>
			var testProductList = "6012,5116,5631,5212,5286,5938,3163,5491,5412";
			testBasket.listAdd(testProductList);
			assertEquals(listSort(testProductList,"numeric"), testBasket.ListOfProductIDs(), "List of Product IDs");
		
		</cfscript>
	</cffunction>	
	
	
	<cffunction name="update" returntype="void" access="public">
		<cfscript>
			var testProduct = 6012;
			testBasket.add(testProduct);
			testBasket.update(testProduct, 2);
			assertEquals(2, testBasket.getQuantity(testProduct), "Quantity updated to 2");
			
			testBasket.add(testProduct);
			assertEquals(3, testBasket.getQuantity(testProduct), "Added another product, quantity should be 3");
			
			testBasket.update(testProduct, 1);
			assertEquals(1, testBasket.getQuantity(testProduct), "Updated basket to hold 1 of product ID 6012, quantity should be 1");	
			
		</cfscript>
	</cffunction>	
	
	<cffunction name="remove" returntype="void" access="public">
		<cfscript>
			var testProduct = 6012;
			testBasket.add(testProduct);
			assertEquals(1, testBasket.getQuantity(testProduct), "Quantity of Product 6012 should be 1");
			
			testBasket.remove(testProduct);
			assertEquals(0, testBasket.getItemCount(), "Product 6012 removed now basket is empty");
		</cfscript>
	</cffunction>
	
	<cffunction name="empty" returntype="void" access="public">
		<cfscript>
			var testProductList = "6012,5116,5631,5212,5286,5938,3163,5491,5412";
			testBasket.listAdd(testProductList);
			assertEquals(9, testBasket.getItemCount(), "Basket has 9 Items");
			
			testBasket.empty();
			assertEquals(0, testBasket.getItemCount(), "Basket is now empty");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="list" returntype="void" access="public">
		<cfscript>
			var q = "";
			var testProductList = "6012,5116,5631,5212,5286,5938,3163,5491,5412";
			testBasket.listAdd(testProductList);					
			q = testBasket.list();
			Assert(isQuery(q),"List method must return a query");
			AssertEquals(9,q.recordcount,"query contains 9 records");
			AssertEquals(6012, q["productid"][1], "First row is first product inserted into basket");
		</cfscript>
	</cffunction>
	
	
	
<!--- 		add;
		listAdd;
		update;
		remove;
		empty;
		list;
		listProductIDs;	 --->
	

	<!--- your test. Name it whatever you like... make it descriptive. --->
<!--- 	<cffunction name="xxx_should_xxxx_When_xxx" returntype="void" access="public">
		<!--- exercise your component under test --->
		<cfset var result = obj.doSomething()>

		<!--- if you want to "see" your data -- including complex variables, you can pass them to debug() and they will be available to you either in the HTML output or in the Eclipse plugin via rightclick- "Open TestCase results in browser" --->
		<cfset debug(result)>

		<!--- make some assertion based on the result of exercising the component --->
		<cfset assertEquals("SomeExpectedValue",result,"result should've been 'SomeExpectedValue' but was #result#")>

	</cffunction>

	<cffunction name="xxx_should_yyy_when_zzz" returntype="void">
    	<cfset var XX = "">
    	<cfset fail("xxx_should_yyy_when_zzz not yet implemented")>


    </cffunction> --->



	<!--- this won't get run b/c it's private --->
	<cffunction name="somePrivateFunction" access="private">
<!--- 		<cfset marc.getBankAccount().add("5 meeeeelion dollars")> --->
	</cffunction>





</cfcomponent>