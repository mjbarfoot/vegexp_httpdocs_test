
<cfcomponent output="false" name="product">
	<!---

	--->
	<cfproperty name="ProductID" type="numeric" default="0">
	<cfproperty name="StockCode" type="string" default="">
    <cfproperty name="Name" type="string" default="">
	<cfproperty name="Description" type="string" default="">
	<cfproperty name="PackSize" type="numeric" default="0">
	<cfproperty name="SalePrice" type="numeric" default="0">
	<cfproperty name="DiscountedSalePrice" type="numeric" default="0">
	<cfproperty name="PortionCost" type="numeric" default="0">
	<cfproperty name="TaxCode" type="numeric" default="">
	<cfproperty name="TaxRate" type="numeric" default="0">
	<cfproperty name="TaxAmount" type="numeric" default="0">
	<cfproperty name="IsEmpty" type="boolean" default="true">


	<cfscript>
		//Initialize the CFC with the default properties values.
		
		variables.IsEmpty = true;
		variables.productID = 0;
		variables.stockcode = "";
		variables.description= "";
		variables.StockQuantity=0;
		variables.PackSize = "";
		variables.SalePrice = 0;
		variables.DiscountedSalePrice = 0;
		variables.PortionCost = 0;
		variables.TaxCode = 0;
		variables.TaxRate = 0;
		variables.TaxAmount = 0;
		variables.TotalPrice = 0;
		
		
		
	</cfscript>

	<cffunction name="init" output="false" returntype="cfc.model.product.product">
 		<cfargument name="q" type="query" required="true" /> 
		<cfargument name="discountRate" type="numeric" required="true" />
		<cfscript>

			if (isQuery(ARGUMENTS.q)) {
				variables.productID = ARGUMENTS.q.stockid;
				variables.StockCode = ARGUMENTS.q.stockcode;
                variables.name = ARGUMENTS.q.name;
				variables.description = ARGUMENTS.q.description;
				variables.StockQuantity =  ARGUMENTS.q.StockQuantity;
				variables.discountRate = ARGUMENTS.discountRate;
				variables.PackSize =  ARGUMENTS.q.unitofsale;
				variables.SalePrice =  lsParseNumber(ARGUMENTS.q.SalePrice);
				variables.DiscountedSalePrice = getDiscountedSalesPrice(variables.SalePrice,variables.discountRate);
				variables.PortionCost = setPortionCost(ARGUMENTS.q.unitofsale,variables.SalePrice,variables.discountRate);
				variables.isEmpty = false;	 
			}
		</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setStockQuantity" returntype="boolean">
		<cfargument name="StockQuantity" required="true" type="numeric" />
		<cfset VARIABLES.stockquantity = ARGUMENTS.stockquantity />
		<cfreturn true/>	
	</cffunction>
	
	<cffunction name="IsEmpty" returntype="boolean">
		<cfreturn VARIABLES.isEmpty />
	</cffunction>
	
		
	<cffunction name="getProductID" returntype="numeric">	
		<cfreturn VARIABLES.productID / >
	</cffunction>

	<cffunction name="getStockCode" returntype="string"><cfreturn trim(VARIABLES.stockcode) / ></cffunction>
	
	<cffunction name="getStockQuantity" returntype="numeric" access="public"><cfreturn trim(VARIABLES.StockQuantity) /></cffunction>

    <cffunction name="getName" returntype="string"><cfreturn trim(VARIABLES.name) / ></cffunction>

	<cffunction name="getDescription" returntype="string"><cfreturn trim(VARIABLES.description) / ></cffunction>

	<cffunction name="getPackSize" returntype="string"><cfreturn VARIABLES.PackSize /></cffunction>
	
	<cffunction name="getSalePrice" returntype="numeric"><cfreturn VARIABLES.SalePrice /></cffunction>
	
	<cffunction name="getDiscountedSalePrice" returntype="numeric"><cfreturn VARIABLES.DiscountedSalePrice /></cffunction>

	<cffunction name="getPortionCost" returntype="numeric" access="public"><cfreturn VARIABLES.PortionCost /></cffunction>

	<cffunction name="getTaxCode" returntype="numeric"><cfreturn VARIABLES.TaxCode /></cffunction>

	<cffunction name="getTaxRate" returntype="numeric"><cfreturn VARIABLES.TaxRate /></cffunction>
	
	<cffunction name="getTaxAmount" returntype="numeric"><cfreturn VARIABLES.TaxAmount /></cffunction>
	
	<cffunction name="getDiscountedSalesPrice" access="private" returnType="any" hint="Caculates discounted sale price">
	<cfargument name="salesprice" type="numeric" required="true">
	<cfargument name="discountRate" type="numeric" required="false" default="0">
		<cfreturn decimalformat(arguments.salesprice * (1 - (arguments.discountRate/100))) /> 
	</cffunction>
	
	<cffunction name="setPortionCost" access="private" returnType="numeric" hint="Caculates the portion cost (if appopriate)">
		<cfargument name="UnitOfSale" type="String"  required="true"  hint="The pack size description e.g. 1x144" />
		<cfargument name="SalePrice"  type="numeric" required="true"  hint="The total price" />
		<cfargument name="discountRate" type="numeric" required="false" default="0">
		<cfscript>
		//is there a multiplier i.e. 1x144 the x indicates only a quantity of 1 there fore portion cost is not relevant
		var positionOfMultiplier = find("x", UnitOfSale);
		var packQuantity = "";
		var portionCost = "";
		var sp = 0;
		
		
		if (positionOfMultiplier neq 0) {
			
			// is there a pack size defined which includes only one portion?	
			if (left(positionOfMultiplier, 1) eq 1 AND positionOfMultiplier eq 2) {
							application.applog.write("Returning with pack size of 1");
				return decimalFormat(variables.DiscountedSalePrice); //return empty string
				
			}	
			// found a pack of several items 
			else {
			packQuantity 	= mid(UnitOfSale, 1, (positionOfMultiplier-1));
			packQuantity    = rereplace(packQuantity, "[^0-9x]", "", "ALL");
			application.applog.write("Pack Quantity is: " & packQuantity);
			if (variables.DiscountedSalePrice neq "") {
				portionCost 	= variables.DiscountedSalePrice/packQuantity;
			} else {
				portionCost 	= lsParseNumber(SalePrice)/packQuantity;
			}
			//return the portion cost as a string (but formatted as a decimal)	
			return decimalFormat(roundup(portionCost));	
			}	
		} else {
		// single pack size - return empty string
		application.applog.write("Returning with pack size of 1, unit of sale" & UnitOfSale);
		return decimalFormat(variables.DiscountedSalePrice);	
		}
		
		</cfscript>
		</cffunction>
		
		<cffunction name="roundUp" access="private" returntype="numeric">
			<cfargument name="x" type="numeric" required="true" />
			<cfscript>
				return  ceiling(x * 100)/100;
			</cfscript>
		</cffunction>	
</cfcomponent> 