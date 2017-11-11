<!--- 
 Filename: /cfc/shopper/basket.cfc
 Created by: Nate Weiss (NMW) and adapted by Matt Barfoot (Clearview Webmedia)
 Purpose: A shopping basket for customers to collect products 
--->

<cfcomponent output="false" name="basket" displayname="basket" hint="A shopping basket for customers to collect products">
  <!--- Initialize the cart’s contents --->
  <cfset VARIABLES.Basket = StructNew()>
  <cfset VARIABLES.Basket.dateCreated = dateformat(now())>   	

  <cfset CLIENT.Basket="">	  

  <!--- create the departements view object --->
  <cfset VARIABLES.Basket_do=createObject("component", "cfc.departments.do")>
  

  <!--- *** INIT Method *** --->
  <cffunction name="init" access="public" returnType="any" output="false">
  <cfargument name="oldBasketContents" type="struct" required="false" /> 

  <!--- if a old basket has been passed replace VARIABLES.Basket with this one --->
  <cfif isdefined("ARGUMENTS.oldBasketContents")>
	<cfset VARIABLES.Basket = ARGUMENTS.oldBasketContents>
  </cfif>		
	
	<!---set whether shopping basket should show Expanded or not--->
    <cfset THIS.ExpandMode=false>
    
    <cfreturn this>  
  </cffunction> 	
	
  <!--- *** doAction Method *** --->
  <cffunction name="doAction" access="public" returnType="void" output="false">
  
  <cfscript>
  	switch (url.action) {
			case "Add": 	add(url.ProductID, 1);
							;
						    break;	
			case "Remove": 	Remove(url.ProductID);
						    ;
						    break;	
			case "Update": 	Update(url.ProductID, url.Quantity);
						    ;
						    break;
			case "Empty": 	
						    EmptyB();
						    ;
						    break;	
			}
  </cfscript> 
   
  </cffunction>
   
  <!--- *** ADD Method *** --->
  <cffunction name="Add" access="public" returnType="void" output="false" 
              hint="Adds an item to the shopping cart">
    <!--- Two Arguments: productID and Quantity --->
    <cfargument name="productID" type="numeric" required="Yes">
    <cfargument name="quantity" type="numeric" required="no" default="1">
	
	 <cfset var q = StructNew()>
	 <cfset var d = StructNew()>
	 
	 <cfif getItemDetails(ProductID).recordcount neq 0>
	    <!--- Is this item in the cart already? --->
	    <cfif structKeyExists(VARIABLES.Basket, arguments.productID)>
	      <cfset VARIABLES.Basket[arguments.productID].q = 
	             VARIABLES.Basket[arguments.productID].q + arguments.quantity>
		   	<cfset VARIABLES.Basket[arguments.productID].d = getTickCount()>
	   <cfelse>
	    <!---   <cfset VARIABLES.Basket[arguments.productID] = arguments.productID> --->
		  <cfset temp=StructInsert(VARIABLES.Basket, arguments.productID, structnew())>
	      <cfset VARIABLES.Basket[arguments.productID].q = arguments.quantity>
	   	  <cfset VARIABLES.Basket[arguments.productID].d = getTickCount()>
	    </cfif>

		<cfset CLIENT.Basket = BasketToWDDX()>
	</cfif>
  </cffunction> 
 
  <!--- *** ListADD Method *** --->
  <cffunction name="ListAdd" access="public" returnType="void" output="false" 
              hint="Adds items from a list to the shopping cart">
    
	<cfargument name="ProductIDList" type="string" required="Yes">

	<!--- iterate through list of Stock IDs adding each to the basket--->
	<cfloop list="#ARGUMENTS.ProductIDList#" index="listEl">
	<cfscript>add(listEl, 1);</cfscript>	
	</cfloop>
  
  </cffunction> 

  <!--- *** UPDATE Method *** --->
  <cffunction name="Update" access="public" returnType="void" output="false"
              hint="Updates an item’s quantity in the shopping cart">
    <!--- Two Arguments: productID and Quantity --->
    <cfargument name="productID" type="numeric" required="Yes">
    <cfargument name="quantity" type="any" required="Yes">

    
	<cfif isNumeric(Arguments.quantity) or Arguments.quantity eq "">
	
	<cfif Arguments.quantity eq "">
		<cfset Arguments.quantity=0/>
	</cfif>
	
	<!--- If the new quantity is greater than zero ---> 
    <cfif arguments.quantity gt 0>
      <cfset VARIABLES.Basket[arguments.productID].q = arguments.quantity>    
      <!--- If new quantity is zero, remove the item from cart --->
    <cfelse>
      <cfset remove(arguments.productID)>
    </cfif>
	<cfset CLIENT.Basket = BasketToWDDX()>
	
	</cfif>    
   </cffunction> 

  <!--- *** REMOVE Method *** --->
  <cffunction name="Remove" access="public" returnType="void" output="false"
              hint="Removes an item from the shopping cart">
    <!--- One Argument: productID --->
    <cfargument name="productID" type="numeric" required="Yes">

    <cfset structDelete(VARIABLES.Basket, arguments.productID)>
	<cfset CLIENT.Basket = BasketToWDDX()>   
	</cffunction> 
 
  <!--- *** EMPTY Method *** --->
  <cffunction name="Empty" access="public" returnType="void" output="false"
              hint="Removes all items from the shopping cart">
 
    <!--- Empty the cart by clearing the This.CartArray array --->
    <cfset structClear(VARIABLES.Basket) />
	<cfset CLIENT.Basket="" />
	<cfset VARIABLES.Basket.dateCreated = dateformat(now())>   
</cffunction>
 
  <!--- *** LIST Method *** --->
  <cffunction name="List" access="public" returnType="query" output="false"
              hint="Returns a query object containing all items in shopping 
              cart. The query object has two columns: productID and Quantity.">

    <!--- Create a query, to return to calling process --->
    <cfset var q = queryNew("productID,Quantity,ts")>
    <cfset var key = "">
   	
<!---    	<cfset VARIABLES.Basket = StructSort(VARIABLES.Basket)>
   	<cfthrow detail="#ArrayToList(VARIABLES.Basket)#"> --->

  
    <!--- For each item in cart, add row to query --->
    <cfloop collection="#VARIABLES.Basket#" item="key">
    <cfif key neq "dateCreated">
	  <cfset queryAddRow(q)>
      <cfset querySetCell(q, "productID", key)>
      <cfset querySetCell(q, "Quantity", VARIABLES.Basket[key].q)>
      <cfset querySetCell(q, "ts", VARIABLES.Basket[key].d)>	
    </cfif>
	</cfloop>

    <!--- Return completed query ---> 
   	<cfquery dbtype="query" name="qSorted">
	SELECT * FROM Q
	ORDER BY TS ASC   
   	</cfquery>
   	
    <cfreturn qSorted> 
  </cffunction> 
 
  <!--- return a list of all ProductIDs in the basket --->	 
  <cffunction name="ListOfProductIDs" access="public" returnType="string" output="false">
   
  <cfset var ProductIDList="" />
      <!--- For each item in cart, add row to query --->
    <cfloop collection="#VARIABLES.Basket#" item="key">
    <cfif key neq "dateCreated">
		<cfif ProductIDList eq "">
			<cfset ProductIDList = key>
		<cfelse>	
			<cfset ProductIDList = ProductIDList & "," & key />
		</cfif>	
    </cfif>
	</cfloop>
  <cfreturn ProductIDList>
  
	</cffunction> 

  <!--- return a list of all Quantities in the basket --->	 
  <cffunction name="ListOfQuantities" access="public" returnType="string" output="false">
   
  <cfset var QuantityList="" />
      <!--- For each item in cart, add row to query --->
    <cfloop collection="#VARIABLES.Basket#" item="key">
    <cfif key neq "dateCreated">
		<cfif QuantityList eq "">
			<cfset QuantityList =  VARIABLES.Basket[key].q>
		<cfelse>	
			<cfset QuantityList = QuantityList & "," &  VARIABLES.Basket[key].q />
		</cfif>	
    </cfif>
	</cfloop>
  <cfreturn QuantityList>
  
	</cffunction>


  <cffunction name="getItemCount" access="public" returnType="numeric" output="false">
  <cfscript> 
  var itemCount=0;
  for (keyName in VARIABLES.Basket) {
    if (keyName neq "dateCreated") {
    itemCount=itemCount+1;	
    } 
  	
  }
  return itemCount; 
  </cfscript>
  </cffunction>	   

  <cffunction name="getDateCreated" access="public" returnType="string" output="false">
  
  <cfscript> 
  return VARIABLES.Basket.dateCreated; 
  </cfscript>
  
  </cffunction>
  	
  <cffunction name="getProductDescription" access="public" returnType="string" output="false">
  <cfargument name="productID" type="numeric" required="Yes">
  
  <cfreturn VARIABLES.Basket_do.getStockDesc(ARGUMENTS.productID)>
  
  </cffunction>	
	
  <cffunction name="getItemDetails" access="public" returnType="query" output="true">
	  <cfargument name="productID" type="numeric" required="Yes">
	  <cfargument name="returnDiscountedPrice" type="boolean" required="false" default="true" /> 
	  <cfset var q = VARIABLES.Basket_do.getItemDetails(ARGUMENTS.productID)>	
	  <!---when called from sageWSGW.PlaceSalesOrder() the full price should be used and the 
	  discount is entered as part of each line so that the full price shows on the invoice, but 
	  the net amount shows the discounted amount --->
	  <cfif ARGUMENTS.returnDiscountedPrice>
	  	<cftry>
	  	<cfset q.SalePrice = decimalformat(q.SalePrice * (1 - (session.auth.discountRate/100))) />	
	  	<cfcatch type="any">
			<cfset q.SalePrice = 0 />	
	  	</cfcatch>
	  	</cftry>
	  
	  <cfelse>
	  	<cfset q.SalePrice = decimalformat(q.SalePrice) />	
	  </cfif>	  
	<cfreturn q>
  
  </cffunction>	  

  <cffunction name="getTotal" access="public" returnType="numeric" output="false">
  <cfargument name="productID" type="numeric" required="Yes">
  <cfargument name="returnDiscountedPrice" type="boolean" required="false" default="true" /> 

  	  <!---when called from sageWSGW.PlaceSalesOrder() the full price should be used and the 
	  discount is entered as part of each line so that the full price shows on the invoice, but 
	  the net amount shows the discounted amount --->
	  <cfif ARGUMENTS.returnDiscountedPrice>
		<cfreturn (VARIABLES.Basket[arguments.productID].q * decimalformat(VARIABLES.Basket_do.getPrice(ARGUMENTS.productID) * (1 - (session.auth.discountRate/100))))>
	  <cfelse>
	  	<cfreturn (VARIABLES.Basket[arguments.productID].q * decimalformat(VARIABLES.Basket_do.getPrice(ARGUMENTS.productID)))>
	  </cfif>			
  
  </cffunction>	
	
  <cffunction name="getGrandTotal" access="public" returnType="numeric" output="false">
  <cfargument name="omitComma" required="false" default="false" type="Boolean" />  
	<cfset var grandTotal=0> 
  
  <!--- loop through the basket and add up the grand total --->
  <cfloop collection="#VARIABLES.Basket#" item="key">
	<cfif key neq "dateCreated">  
		<cfset grandTotal = grandTotal + (VARIABLES.Basket[key].q * decimalformat(VARIABLES.Basket_do.getPrice(key) * (1 - (session.auth.discountRate/100))))>
		<!--- <cfset grandTotal = grandTotal + (VARIABLES.Basket[key].q * VARIABLES.Basket_do.getPrice(key))> --->
  	</cfif>
  </cfloop>  
  
<cfif ARGUMENTS.omitComma>
	<cfreturn NumberFormat(grandTotal, "9.99")>
 <cfelse>
	<cfreturn grandTotal />
</cfif> 
  </cffunction>		

  <cffunction name="BasketToWDDX" access="private" returnType="string" output="false">
 	<cfwddx action = "cfml2wddx" input = #VARIABLES.Basket# output = "wddxText">
	<cfreturn wddxText /> 
  </cffunction>	
	
	
</cfcomponent>
