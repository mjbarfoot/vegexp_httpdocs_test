<cfcomponent  name="basket" displayname="basket" hint="basket" output="false">

 <!--- Initialize the basket contents --->
  <cfset VARIABLES.Basket = StructNew()>
  <cfset VARIABLES.Basket.dateCreated = dateformat(now())>   
  <cfset VARIABLES.ProductDO = ""/>


  <!--- *** INIT Method *** --->
  <cffunction name="init" access="public" returnType="any" output="false">
      <cfargument name="oldBasketContents" type="struct" required="false" />
      <cfargument name="stockDO" type="cfc.departments.do" required="true" />
      <cfargument name="discountRate" type="numeric" required="true">

      <!--- if a old basket has been passed replace VARIABLES.Basket with this one --->
      <cfif isdefined("ARGUMENTS.oldBasketContents")>
        <cfset VARIABLES.Basket = ARGUMENTS.oldBasketContents>
      </cfif>

        <cfset VARIABLES.stockDO = ARGUMENTS.stockDO />
        <cfset VARIABLES.discountRate = ARGUMENTS.discountRate />
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
                case "Empty": EmptyBasket();
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
	
	 <cfset var productQuery = VARIABLES.stockDO.getItemDetails(ARGUMENTS.productid) />
	 <cfset var myproduct = createObject("component","cfc.model.product.product").init(productQuery, VARIABLES.DiscountRate) />
	 <cfset var q = StructNew()>
	 <cfset var d = StructNew()>
	
	
	 
	 <cfif Not myproduct.IsEmpty()>
	 	 <cfif structKeyExists(VARIABLES.Basket, productID)>
		 	   <cfset VARIABLES.Basket[productID].q = VARIABLES.Basket[ARGUMENTS.productID].q + arguments.quantity>
		   		<cfset VARIABLES.Basket[productID].d = getTickCount()>
		 <cfelse>
		 		  <cfset temp=StructInsert(VARIABLES.Basket, ARGUMENTS.productID, structnew()) />
	    		  <cfset VARIABLES.Basket[ARGUMENTS.productID].product = myproduct />	
	    		  <cfset VARIABLES.Basket[ARGUMENTS.productID].q = arguments.quantity />
	   			  <cfset VARIABLES.Basket[ARGUMENTS.productID].d = getTickCount() />
		 </cfif>

         <!---<cfcookie name="VEbasket" value="#serializeJSON(VARIABLES.basket)#"/>--->
		  
	 </cfif>
	</cffunction>	
	
	<!--- *** get a copy of the product from the basket --->
	<cffunction name="getProduct" access="public" returntype="cfc.model.product.product" output="false">
		 <cfargument name="productID" type="numeric" required="Yes">
	
		<cfreturn VARIABLES.Basket[ARGUMENTS.ProductID].product />
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
              hint="Updates an item�s quantity in the shopping cart">
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

     <!--- <cfcookie name="VEbasket" value="#serializeJSON(VARIABLES.basket)#"/>--->
	
	</cfif>    
   </cffunction> 

  <!--- *** REMOVE Method *** --->
  <cffunction name="Remove" access="public" returnType="void" output="false"
              hint="Removes an item from the shopping cart">
    <!--- One Argument: productID --->
    <cfargument name="productID" type="numeric" required="Yes">

        <cfset structDelete(VARIABLES.Basket, arguments.productID)>
        <!---<cfcookie name="VEbasket" value="#serializeJSON(VARIABLES.basket)#"/>--->
	</cffunction>

<!--- *** EMPTY Method *** --->
    <cffunction name="Empty" access="public" returnType="void" output="false"
            hint="Removes all items from the shopping cart">
        <cfscript>
            emptyBasket();
        </cfscript>
    </cffunction>


  <!--- *** EmptyBasket - Empty can be called internally *** --->
  <cffunction name="EmptyBasket" access="public" returnType="void" output="false"
              hint="Removes all items from the shopping cart">
 
    <!--- Empty the cart by clearing the This.CartArray array --->
    <cfset structClear(VARIABLES.Basket) />

	<cfset VARIABLES.Basket.dateCreated = dateformat(now())>   
</cffunction>
 
  <!--- *** LIST Method *** --->
  <cffunction name="List" access="public" returnType="query" output="false"
              hint="Returns a query object containing all items in shopping 
              cart. The query object has two columns: productID and Quantity.">

    <!--- Create a query, to return to calling process --->
    <cfset var q = queryNew("productID,Quantity,ts")>
    <cfset var key = "">

  
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
	
	  <cfreturn ListSort(ProductIDList,"numeric")>
  
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

  <cffunction name="getQuantity" access="public" returnType="numeric" output="false">
	 <cfargument name="productID" type="numeric" required="Yes">
	 <cfreturn VARIABLES.Basket[ARGUMENTS.productID].q />
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
  
  <cfreturn VARIABLES.Basket[ARGUMENTS.productID].product.getDescription()>
  
  </cffunction>	

  <cffunction name="getItemSalesPrice" access="public" returntype="numeric" output="false">
	  <cfargument name="productID" type="numeric" required="Yes">
	  <cfargument name="returnDiscountedPrice" type="boolean" required="false" default="true" /> 
		<cfscript>
				var salesPrice = VARIABLES.Basket[ARGUMENTS.product].product.getSalesPrice();
				
				if (ARGUMENTS.returnDiscountedPrice eq true) {
					
					try {
					 salesPrice = SalePrice * (1 - (session.auth.discountRate/100));
					} catch (any) {
					 salesPrice = 0;
					}
					 
				} 
					
				return decimalFormat(salesPrice);
				
		</cfscript>
	</cffunction>

 <cffunction name="getTotal" access="public" returntype="numeric" output="false">
	  <cfargument name="productID" type="numeric" required="Yes">
	  <cfargument name="returnDiscountedPrice" type="boolean" required="false" default="true" /> 
		<cfscript>
				var salesPrice = VARIABLES.Basket[ARGUMENTS.productID].product.getSalePrice();
				var q = VARIABLES.Basket[ARGUMENTS.productID].q
				var totalPrice = salesPrice * q;
				
				if (ARGUMENTS.returnDiscountedPrice eq true) {
					
					try {
					 totalPrice = totalPrice * (1 - (session.auth.discountRate/100));
					} catch (any) {
					 totalPrice = 0;
					}
					 
				} 
					
				return decimalFormat(totalPrice);
				
		</cfscript>
</cffunction>

<cffunction name="getGrandTotal" access="public" returnType="numeric" output="false">
		  <cfargument name="omitComma" required="false" default="false" type="Boolean" />  
		  <cfargument name="returnDiscountedPrice" type="boolean" required="false" default="true" /> 
		  <cfset var grandtotal = 0/>
	  		<cfloop collection="#VARIABLES.Basket#" item="key">
				<cfif key neq "dateCreated">  
					<cfset grandTotal = grandTotal + getTotal(key, ARGUMENTS.returnDiscountedPrice)>
			  	</cfif>
 			 </cfloop> 


			<cfif ARGUMENTS.omitComma>
				<cfreturn NumberFormat(grandTotal, "9.99")>
			 <cfelse>
				<cfreturn grandTotal />
			</cfif> 
	</cffunction>


</cfcomponent>