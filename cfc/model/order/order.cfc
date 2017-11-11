<cfcomponent  name="order" displayname="order" hint="order" output="false">

 <!--- Initialize the basket contents --->
  <cfset VARIABLES.order.basket = ""/>
  <cfset VARIABLES.dateCreated = dateformat(now())>   
  <cfset VARIABLES.orderID="" />
  <cfset VARIABLES.orderDO = ""/>	
  <cfset VARIABLES.orderStatus = "" />
  <cfset VARIABLES.logger = "" />
  

  <!--- *** INIT Method *** --->
  <cffunction name="init" access="public" returnType="any" output="false">
	<cfargument name="orderdo" required="true" type="cfc.data.order.orderdo" />
	<cfargument name="logger" required="true" type="cfc.util.abstractLogger" />
	
	<cfset VARIABLES.logger = ARGUMENTS.logger />
	<cfset VARIABLES.orderDO = ARGUMENTS.orderDO />
    
    <cfreturn this />  
  </cffunction> 	


	<cffunction name="createOrder" access="public" returntype="boolean" output="false" hint="poulates an empty order object from a shopping basket">
		<cfargument name="basket" type="cfc.model.basket.basket" required="true" />
		<cfscript>
			// checks order object is empty, not allowed to overwrite. need to create new order. 
			if (VARIABLES.orderID = "") {
			
				//generate order seed 
				var orderseed = APPLICATION.var_DO.getVar("orderseed");
				VARIABLES.orderID = InputBaseN(orderseed, 16);
				APPLICATION.var_DO.setVar("orderseed", "#orderseed#+1");
				
				//add basket
				VARIABLES.order.basket = ARGUMENTS.basket;
			
			
				VARIABLES.orderStatus = "NEW";
				
				return true;
			} else {
			return false;
			}
			
		</cfscript>
				
	</cffunction>

	<cffunction name="getOrderID" access="public" returntype="string" output="false" hint="returns the Order ID">
		<cfreturn VARIABLES.orderID />
	</cffunction>
	
	<cffunction name="getBasket" access="public" returntype="cfc.model.basket.basket" hint="gets the basket contents">	
		<cfreturn VARIABLES.order.basket />
	</cffunction>
	
	<cffunction name="getOrderStatus" access="public" returntype="string" hint="gets the order status">
		<cfreturn VARIABLES.orderStatus />
	</cffunction>
	
	
	<cffunction name="setOrderStatus" access="public" returntype="boolean" hint="sets the order status">
		<cfargument name="orderStatus" type="string" required="true" />
		<cfif listFind(StatusList, ARGUMENTS.orderStatus) neq 0>
			<cfset VARIABLES.orderStatus = ARGUMENTS.orderStatus />
			
			<cfreturn true/>
		<cfelse>
			<cfscript>
				VARIABLES.logger.error("Invalid Status: #ARGUMENTS.orderstatus#");
			</cfscript>
			<cfreturn false/>
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="save" access="public" returntype="boolean" hint="saves the order to the database">
	
	
	</cffunction>
	
</cfcomponent>