
		<cfscript>
		   TestProductID = 5491;
		   ProductDO = createObject("component","cfc.departments.do");		
		   ProductQuery = VARIABLES.ProductDO.getItemDetails(TestProductID);
		   discountRate = 0;
	 	   TestProduct = createObject("component","cfc.model.product.product").init(productQuery, discountRate);
		</cfscript>

        <cfoutput>Stockcode: #TestProduct.getStockCode()#</cfoutput>

