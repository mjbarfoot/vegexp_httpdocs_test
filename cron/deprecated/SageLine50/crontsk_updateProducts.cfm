<cfprocessingdirective  suppressWhiteSpace = "Yes">

<cfscript>
//create log files
//if (not isdefined("application.crontsklog")) { 
//application.crontsklog 			= createObject("component", "cfc.logwriter.logwriter").init("D:\JRun4\servers\vegexp\cfusion-war\logs\", "crontsklog");/
//}

//write crontask started
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateProducts Started *****");


//intialise the Sage Connector
VARIABLES.sageWSGW =  createObject("component", "cfc.sagegw.sageWSGW").init();

timeStarted = now();
tickBegin=getTickCount();
tickEnd=0;
tickinterval=0;

// Get Products From Sage
sageProductData = VARIABLES.sageWSGW.postRequest(generateSoap(), "GetProductListFull");
tickLap=getTickCount();
SageReturnInterval=(tickEnd-tickLap)/1000;

// Update Products Pad
uploadToProductsPad(sageProductData);

// Remove Old Items and Add new or Update Existing
ItemsOld = removeOldProducts();
AddUpdateReturn = AddUpdateExistingProducts(sageProductData);

// Update Items Out of Stock
ItemsOutOfStock = UpdateOutOfStock();

// Remove Items From Favourites
ItemsRemovedFromFavourites = RemoveOldProductsFromFavourites(sageProductData);

// Stop the Clock!
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
timeEnded = now();
</cfscript>

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title>VE Crontask: Update Products</title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <link rel="icon" href="favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
  <style>
	h1,h2 {font-family: Courier; font-size: 1.2em;}
	p {font-family: Courier; font-size: 1em;}
</style>	
</head>		
<body>
	<h1>Crontask: Update Products - Started at: #timeformat(timeStarted, "H:MM:SS TT")#, Completed at: #timeformat(timeEnded, "H:MM:SS TT")#, Duration: #tickInterval# Seconds</h1>
	<h2>Results</h2>
	<p>
	Time taken to retrieve Product details from Sage: #SageReturnInterval# seconds<br />
	Products removed from Website Inventory (Deleted in Sage): #ItemsOld#<br />
	Products Added to Website Inventory: #AddUpdateReturn.addList# <br />
	Number of Products Updated in Website Inventory #AddUpdateReturn.updateCount#<br />
	Products set as Out of Stock (999.99): #ItemsOutOfStock#<br />
	Products removed from Favourites (Products with Stock Category 9xx): #ItemsRemovedFromFavourites#<br />
	</p>
</body>
</html>
</cfoutput>



<cfscript>
//Write complete status to Crontask Log
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " ***** Crontask: updateProducts complete - Execution time: #tickInterval# s *****");
</cfscript>


<cffunction name="uploadToProductsPad" output="false" returntype="void" access="private">
<cfargument name="soapResponse" type="string" />

<!--- initialise xml and timing variables --->
<cfset var xml=xmlParse(arguments.soapResponse)> 
<cfset var xmlProducts=xml.xmlRoot.xmlChildren[2].GetProductListFullResponse.GetProductListFullResult.Product>
<cfset var tickBegin=getTickCount() />
<cfset var tickEnd=0 />
<cfset var tickinterval=0 />

<!--- truncate data --->
<cfquery name="qryInsertIntoPad" datasource="#APPLICATION.dsn#">
DELETE FROM tblSageProductPad
</cfquery>

<!--- add to productpad --->
<cfloop from="1" to="#arraylen(xmlProducts)#" index="x">
	<cfquery name="qryInsertIntoPad" datasource="#APPLICATION.dsn#">
	INSERT INTO tblSageProductPad
	(StockCode, SalePrice)
	values ('#xmlProducts[x].StockCode.xmlText#',#xmlProducts[x].Saleprice.xmlText#)
	</cfquery>
</cfloop>


<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Function: uploadToProductsPad - Added #arraylen(xmlProducts)# products to ProductsPad (#tickInterval# s)");
</cfscript>
</cffunction>

<cffunction name="removeOldProducts" output="false" returntype="string" access="private">
<cfset var tickBegin=getTickCount() />
<cfset var tickEnd=0 />
<cfset var tickinterval=0 />
<cfset var deleteCount =0 />
<cfset var listItemsOld ="" />

<cfquery name="qryCountProductsOld" datasource="#APPLICATION.dsn#">
SELECT count(StockID) as "productCountOld" FROM tblProducts 
</cfquery>

<cfquery name="qryGetOldProducts" datasource="#APPLICATION.dsn#">
select stockcode from tblProducts
where StockCode NOT IN (select StockCode from tblSageProductPad)
</cfquery>

<cfset listItemsOld=ValueList(qryGetOldProducts.Stockcode)>

<!--- remove any that don't exist in sageUserPad --->
<cfquery name="qryRemoveOldProducts" datasource="#APPLICATION.dsn#">
DELETE FROM tblProducts
where StockCode NOT IN (select StockCode from tblSageProductPad)
</cfquery>

<cfquery name="qryCountProductsNew" datasource="#APPLICATION.dsn#">
SELECT count(StockID) as "productCountNew" FROM tblProducts 
</cfquery>

<!--- set deleteCount var  --->
<!--- <cfset deleteCount = val(qryCountProductsNew['"productCountNew"'][1]) - val(qryCountProductsOld['"productCountOld"'][1]) /> --->
<cfset deleteCount = val(qryCountProductsNew.productCountNew) - val(qryCountProductsOld.productCountOld) />

<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Function: removeOldProducts - Removed #deleteCount# products (#tickInterval# s)");
</cfscript>


<cfreturn listItemsOld/>
</cffunction>

<cffunction name="AddUpdateExistingProducts" returntype="struct" output="false" acess="private">
<cfargument name="soapResponse" type="string">

<!--- <ArrayOfProduct xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
  <Product>
    <Description>string</Description>
    <StockCategoryNumber>short</StockCategoryNumber>
    <StockCode>string</StockCode>
    <AvailableStock>double</AvailableStock>
    <WebPublishFlag>boolean</WebPublishFlag>
    <SupplierPartNumber>string</SupplierPartNumber>
    <SupplierAccountReference>string</SupplierAccountReference>
    <DepartmentNumber>short</DepartmentNumber>
    <ItemType>StockItem or NonStockItem or ServiceItem</ItemType>
    <NominalCode>string</NominalCode>
    <QuantityAllocated>double</QuantityAllocated>
    <QuantityInStock>double</QuantityInStock>
    <QuantityOnOrder>double</QuantityOnOrder>
    <SalePrice>double</SalePrice>
    <TaxCode>short</TaxCode>
    <UnitofSale>string</UnitofSale>
    <UnitofWeight>double</UnitofWeight>
    <WebDescription>string</WebDescription>
    <WebImageFilename>string</WebImageFilename>
    <WebLongDescription>string</WebLongDescription>
    <Custom1>string</Custom1>
    <Custom2>string</Custom2>
    <Custom3>string</Custom3>
  </Product>
</ArrayOfProduct> --->


<!--- initialise xml and timing variables --->
<cfset var xml=xmlParse(arguments.soapResponse)> 
<cfset var xmlProducts=xml.xmlRoot.xmlChildren[2].GetProductListFullResponse.GetProductListFullResult.Product>
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>
<cfset var tickinterval=0>
<cfset var updateCount=0 />
<cfset var addCount=0 />
<cfset var AddUpdateReturn=structnew() />
<cfset AddUpdateReturn.addList = "" />
<cfset AddUpdateReturn.updateCount = 0 />


<!--- iterate through the product catalogue and insert products in to the products table --->
<cftransaction>	
<cfloop from="1" to="#arraylen(xmlProducts)#" index="x">

<cfquery name="qryChkForProductItem" datasource="#APPLICATION.dsn#">
SELECT StockCode from tblProducts
where StockCode = '#xmlProducts[x].StockCode.xmlText#'
</cfquery>

<cfif qryChkForProductItem.recordcount eq 0>
	<cfquery name="qryInsProducts" datasource="#APPLICATION.dsn#"> 
	INSERT INTO tblProducts
	(
		Stockcode, 
		StockCategoryNumber,
		Description,
		UnitofSale,
		UnitofWeight,
		Saleprice,
		Custom1, 
		Custom2,
		Custom3,
		WebDescription,
		WebImageFilename,
		WebLongDescription,
		DateLastUpdated,
		TimeLastUpdated,
		LastModifiedBy
	) values ( 
		'#xmlProducts[x].StockCode.xmlText#', 
		'#xmlProducts[x].StockCategoryNumber.xmlText#', 
		'#REReplace(xmlProducts[x].Description.xmlText,"\.*\s*\.C", "")#',  
		'#xmlProducts[x].UnitofSale.xmlText#',  
		 #xmlProducts[x].UnitofWeight.xmlText#,  
		 #xmlProducts[x].Saleprice.xmlText#, 
		'#xmlProducts[x].Custom1.xmlText#', 
		'#xmlProducts[x].Custom2.xmlText#',
		'#xmlProducts[x].Custom3.xmlText#',
		'#xmlProducts[x].WebDescription.xmlText#',
		'#xmlProducts[x].WebImageFilename.xmlText#',		
		'#xmlProducts[x].WebLongDescription.xmlText#',
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		'crontask'
	);
	</cfquery>
	
	<cfif AddUpdateReturn.addList eq "">
		<cfset AddUpdateReturn.addList = "#xmlProducts[x].StockCode.xmlText#">
	<cfelse>
		<cfset AddUpdateReturn.addList = AddUpdateReturn.addList & "," & "#xmlProducts[x].StockCode.xmlText#">
	</cfif>
	
	<cfset addCount = addCount + 1 />
<cfelse>
		<cfquery name="qryInsProducts" datasource="#APPLICATION.dsn#"> 
	UPDATE 	tblProducts
	SET 	StockCategoryNumber = '#xmlProducts[x].StockCategoryNumber.xmlText#',
			Description 		= '#REReplace(xmlProducts[x].Description.xmlText,"\.*\s*\.C", "")#',
			UnitofSale 			= '#xmlProducts[x].UnitofSale.xmlText#' ,
			UnitofWeight 		=  #xmlProducts[x].UnitofWeight.xmlText#,
			Saleprice 			=  #xmlProducts[x].SalePrice.xmlText#,
			Custom1 			= '#xmlProducts[x].Custom1.xmlText#', 
			Custom2 			= '#xmlProducts[x].Custom2.xmlText#',
			Custom3 			= '#xmlProducts[x].Custom3.xmlText#',
			WebDescription 		= '#xmlProducts[x].WebDescription.xmlText#',
			WebImageFilename 	= '#xmlProducts[x].WebImageFilename.xmlText#',
			WebLongDescription 	= '#xmlProducts[x].WebLongDescription.xmlText#',
			DateLastUpdated 	= <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			TimeLastUpdated 	= <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
			LastModifiedBy 		= 'crontask'										
	WHERE 	StockCode 			= '#xmlProducts[x].StockCode.xmlText#';
	</cfquery>
	<cfset updateCount = updateCount + 1 />
</cfif>

</cfloop>
 
</cftransaction>

<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Function: AddUpdateExistingProducts - Added #addCount# products, Updated #updateCount# products (#tickInterval# s)");
</cfscript>

<cfset AddUpdateReturn.updateCount = updateCount>

<cfreturn AddUpdateReturn />
</cffunction>

<cffunction name="UpdateOutOfStock" returntype="string" output="false" acess="private">
<cfset var tickBegin=getTickCount() />
<cfset var tickEnd=0 />
<cfset var tickinterval=0 />
<cfset var updateCount=0 />
<cfset var ListOutOfStock=""/>

<cfquery name="qrySelectProductPad" datasource="#APPLICATION.dsn#">
select StockCode, SalePrice
from tblSageProductPad
</cfquery>

<cfloop query="qrySelectProductPad">
<cfif SalePrice eq 999.00>
	<cfquery name="qryUpdateOutOfStock" datasource="#APPLICATION.dsn#">
	UPDATE tblProducts
	set OutOfStock = 1
	where StockCode = '#Stockcode#'
	</cfquery>
	<cfset updateCount = updateCount + 1 />
	
	<cfif ListOutOfStock eq "">
		<cfset ListOutOfStock = "#Stockcode#">
	<cfelse>
		<cfset ListOutOfStock = ListOutOfStock & "," & "#Stockcode#">
	</cfif>
		
<cfelse>
	<cfquery name="qryUpdateOutOfStock" datasource="#APPLICATION.dsn#">
	UPDATE tblProducts
	set OutOfStock = 0
	where StockCode = '#Stockcode#'
	</cfquery>
</cfif>
</cfloop>

<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Function: UpdateOutOfStock - Set #updateCount# OutOfStock flags (#tickInterval# s)");
</cfscript>

<cfreturn ListOutOfStock />
</cffunction>

<cffunction name="RemoveOldProductsFromFavourites" returntype="string" output="false" acess="private">
<cfargument name="soapResponse" type="string">

<!--- initialise xml and timing variables --->
<cfset var xml=xmlParse(arguments.soapResponse)> 
<cfset var xmlProducts=xml.xmlRoot.xmlChildren[2].GetProductListFullResponse.GetProductListFullResult.Product>
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>
<cfset var tickinterval=0>
<cfset var listOfRemovedProducts=""/>
<cfset var updateCount=0 />


<cfloop from="1" to="#arraylen(xmlProducts)#" index="x">
<cfif left(xmlProducts[x].StockCategoryNumber.xmlText, 1) eq "9">

	<!--- remove the product from the favourites table --->
	<cfquery name="qRemoveFromFavourites" datasource="#APPLICATION.dsn#"> 
	DELETE FROM tblFavourite
	WHERE  StockCode = '#xmlProducts[x].StockCode.xmlText#'
	</cfquery>
	
	<cfif listOfRemovedProducts eq "">
		<cfset listOfRemovedProducts = "#xmlProducts[x].StockCode.xmlText#" />
	<cfelse>
		<cfset listOfRemovedProducts = listOfRemovedProducts & "," & "#xmlProducts[x].StockCode.xmlText#" />
	</cfif>

	<cfset updateCount = updateCount + 1/>
</cfif>

</cfloop>


<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Function: RemoveOldProductsFromFavourites - Removed #updateCount# (#tickInterval# s)");
</cfscript>

<cfreturn listOfRemovedProducts />

</cffunction>


<cffunction name="postRequest" output="true" returntype="string">
<cfargument name="soapRequest" type="string" required="true">
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

	<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx/GetProductListFull"
			method="post">
	<cfhttpparam name="xml" value="#arguments.soapRequest#" type="xml" />
	</cfhttp>		

<cfscript>
tickEnd=getTickCount();
tickInterval=(tickEnd-tickBegin)/1000;
application.crontsklog.write(timeformat(now(), 'h:mm:ss tt') & " Function: postRequest - Retrieved ProductsData from Sage Web Service (#tickInterval# s)");
</cfscript>

<cfreturn trim(cfhttp.filecontent)>
</cffunction>

<cffunction name="generateSOAP" output="false" returntype="string" access="private">
<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetProductListFull xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfxml>

<cfreturn toString(soap)>
</cffunction>




</cfprocessingdirective>