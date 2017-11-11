<cfcomponent displayname="orderTest" hint="orderTest" output="false">

<!---

createOrder
getOrderID
getBasket
getOrderStatus
setOrderStatus
save

--->
	<cffunction name="beforeTests" returntype="void" access="public">

		<cfscript>
		testBasket = createObject("component","cfc.model.basket.basket").init(stockDO=StockDO, discountRate=discountRate);
		testProduct = 6155;
		testBasket.add(testProduct);
		
			 	   
		logService = createObject("component","cfc.util.logService").init("vegexp_mysql");
	 	Logger = logService.get("dblogger");
		testOrderDO = createObject("component","cfc.data.order.orderDO").init("vegexp_mysql");	
		testOrder = createObject("component","cfc.model.order.order").init(OrderDO=testOrderDO, logger=Logger);	
		</cfscript>


	</cffunction>

	<cffunction name="createOrderTest" returntype="void" access="public">
		<cfscript>
			var ret = testOrder.createOrder(testBasket);
			Assert(ret eq true,  "Order returns true if order has been created successfully");
		</cfscript>
	</cffunction>
	
	<cffunction name="getOrderID" returntype="void" access="public">
		<cfscript>
			orderID = testOrder.getOrderID();
			Assert(isValid("String", orderID) ,  "Checks the returned OrderID is a string");
		</cfscript>
	</cffunction>

<!---
	<cffunction name="" returntype="void" access="public">
		<cfscript>
			Test = createObject("component","cfc.blah");
			Assert(something=something,  "Test");
		</cfscript>
	</cffunction>
--->	



	<cffunction name="tearDown" returntype="void" access="public">



	</cffunction> 
	
	

</cfcomponent>