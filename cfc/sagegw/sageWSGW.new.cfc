<!--- 
	Filename: 	 /cfc/sagegw/sagewsGW.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Payment interface to different gateways
	Date: 
	Revisions:
--->

<cfcomponent output="false" name="sagewsGW" displayname="sagewsGW" hint="Sage Web Service Gateway">


<!--- *** Setup Hostname and port based upon server *** --->
<cfscript>
	switch (cgi.SERVER_NAME) {
			case "localhost": //VARIABLES.SageWSHost="213.210.52.169";
							  //VARIABLES.SageWSPort="80";
							  VARIABLES.SageWSHost="localhost";
  							  VARIABLES.SageWSPort="81";
  							  ;
  							  break;
			case "vpsserver": VARIABLES.SageWSHost="localhost";
  							  VARIABLES.SageWSPort="81";
  							  ;
  							  break;	
			case "vegexp.clearview-webmedia.co.uk": VARIABLES.SageWSHost="213.210.52.169";
													VARIABLES.SageWSPort="80";
							  ;
							  break;					
			default: 	      VARIABLES.SageWSHost="213.210.52.169";
  							  VARIABLES.SageWSPort="80";
							  ;				  	
				
			}

// create the utility object
util 	= createObject("component", "cfc.shop.util");
</cfscript>

	
<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript>    
// ----------- / get dependent objects / --------------//
// get the ...
//VARIABLES.myObject=createObject("component", "cfc.myObject.myObject").init();

//return a copy of this object
return this;
</cfscript>
</cffunction> 


<cffunction name="getConfig" output="false" returntype="string" access="public">

<cfsavecontent variable="myConfig">
<cfoutput>
<ul>
	<li>Sage Hostname: #VARIABLES.SageWSHost#</li>
	<li>Sage Port: #VARIABLES.SageWSPort#</li>
	<li>Sage Version: Line 50 V12</li>
</ul>
</cfoutput>
</cfsavecontent>

<cfreturn myConfig />
</cffunction>


<cffunction name="registerUser" output="true" returntype="boolean" access="public">
<cfargument name="FORMObj" type="struct" required="true" />

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<!---initialise response vars--->
<cfset var isSuccessful=true />
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlRegStatus="" />

<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:registerUser: started for company: #XMLFormat(ARGUMENTS.FormObj.clientcompany)#");
</cfscript>

<cftry>
<cfxml variable="soap">
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <CreateCustomer xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <customer>
        <AccountCode>#XMLFormat(ARGUMENTS.FormObj.AccountID)#</AccountCode>
        <AccountName>#XMLFormat(ARGUMENTS.FormObj.clientcompany)#</AccountName>
        <AccountOnHold>0</AccountOnHold>
        <AccountStatus>0</AccountStatus>
        <AccountAddressLine1>#XMLFormat(ARGUMENTS.FormObj.Line1)#</AccountAddressLine1>
        <AccountAddressLine2>#XMLFormat(ARGUMENTS.FormObj.line2andBuilding)#</AccountAddressLine2>
        <AccountAddressLine3>#XMLFormat(ARGUMENTS.FormObj.Line3)# #XMLFormat(ARGUMENTS.FormObj.Town)#</AccountAddressLine3>
        <AccountAddressLine4>#XMLFormat(ARGUMENTS.FormObj.County)#</AccountAddressLine4>
        <AccountAddressPostCode>#XMLFormat(ARGUMENTS.FormObj.postcode)#</AccountAddressPostCode>
        <Password />
        <Balance>0</Balance>
        <ContactName>#XMLFormat(ARGUMENTS.FormObj.firstname)# #XMLFormat(ARGUMENTS.FormObj.lastname)#</ContactName>
        <CountryCode>GB</CountryCode>
        <CreditLimit>0</CreditLimit>
        <DefaultNominalCode>1000</DefaultNominalCode>
        <DefaultTaxCode>0</DefaultTaxCode>
        <DeliveryAddressLine1 />
        <DeliveryAddressLine2 />
        <DeliveryAddressLine3 />
        <DeliveryAddressLine4 />
        <DeliveryAddressPostCode />
        <DeliveryContactName />
        <DeliveryFaxNumber />
        <DeliveryName />
        <DeliveryTelephoneNumber />
        <DiscountRate>0</DiscountRate>
        <EMailAddress>#XMLFormat(emailAddress)#</EMailAddress>
        <FaxNumber />
        <TelephoneNumber>#XMLFormat(telnum)#</TelephoneNumber>
        <VATRegistrationNumber />
      </customer>
    </CreateCustomer>
  </soap:Body>
</soap:Envelope>
</cfxml>
<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - created SOAP Envelope for company: #XMLFormat(ARGUMENTS.FormObj.clientcompany)#");
</cfscript>
<cfcatch type="any">
<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - Failed to create SOAP Envelope for registration for: #XMLFormat(ARGUMENTS.FormObj.clientcompany)#");
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - Error details: " & cfcatch.message & " Full error: " & cfcatch.details); 
</cfscript>
</cfcatch>
</cftry>


<!--- try to post the order to Sage --->
<cftry>
   <cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - Posting Envelope to Aspidistra SageWS for: #XMLFormat(ARGUMENTS.FormObj.clientcompany)#");
	</cfscript>	
<cfset myResponse = postRequest(toString(soap), "CreateCustomer") /> 
<cfcatch type="any">
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - Error: No one available to collect SOAP Envelope ... Aspidistra SageWS did not respond for: #XMLFormat(ARGUMENTS.FormObj.clientcompany)#");
	</cfscript>		
</cfcatch>
</cftry>

<!--- try to parse the response --->
<cftry>
	<!--- parse the xml response and return the order number --->
	<cfset  xmlResponse		=	xmlParse(myResponse)> 
	<cfset  xmlRegStatus	=	xmlResponse.xmlRoot.xmlChildren[2].CreateCustomerResponse.CreateCustomerResult.xmlText />
	
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - AspiDistra WS accepted registration for #XMLFormat(ARGUMENTS.FormObj.clientcompany)# - response: #toString(xmlRegStatus)#");
	</cfscript>	
	
	<cfreturn true />

<cfcatch type="any">
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS:regisiterUser - AspiDistra WS user registration for: #XMLFormat(ARGUMENTS.FormObj.clientcompany)# - Reason: " & myResponse);
	</cfscript>	
	
	<cfreturn false />
</cfcatch>
</cftry>


</cffunction>



<cffunction name="AccountStatus" access="public" returntype="string" output="false">
<!---initialise response vars--->
<cfset var isSuccessful=true />
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlStatus="" />

<cfxml variable="soap">
<cfoutput>	
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AccountsStatus xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfoutput>
</cfxml>


<!--- try to post the order to Sage --->
<cftry>
	<cfset myResponse = postRequest(toString(soap), "AccountsStatus") /> 
	
	<cfif cfhttp.statusCode eq "200 OK">
		<cfset  xmlResponse		=	xmlParse(myResponse)> 
		<cfset  xmlStatus	=	xmlResponse.xmlRoot.xmlChildren[2].AccountsStatusResponse.AccountsStatusResult.xmlText />
		<cfreturn toString(xmlStatus) />
	<cfelse>
		<cfreturn "error!: #myResponse#" />
	</cfif>	
<cfcatch type="any">
		<cfreturn myResponse />
</cfcatch>
</cftry> 

</cffunction>

<cffunction name="GetCustomerList" access="public" returntype="string" output="false">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCustomerList xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfxml>

<!--- try to post the order to Sage --->
<cftry>
<cfset myResponse = postRequest(toString(soap), "GetCustomerList") /> 
	<cfreturn toString(myResponse) />

<cfcatch type="any">
		<cfreturn 0 />
</cfcatch>
</cftry> 

</cffunction>

<cffunction name="testSalesOrder" access="public" returntype="string" output="false">
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlOrderNumber="" />

<cfxml variable="soap">
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soap:Body>
    <PlaceSalesOrder xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <order>     	
		<NetAmount>21.91</NetAmount>
		<OrderDate>2006-09-29T16:45:33</OrderDate>
		<OrderNumber></OrderNumber>
		<AccountCode>20/20</AccountCode>
		<CustomerAddress1>20/20 BS</CustomerAddress1>
        <CustomerAddress2></CustomerAddress2>
        <CustomerAddress3></CustomerAddress3>
        <CustomerAddress4>Camden London</CustomerAddress4>
        <CustomerAddressPostCode>NW1 0DU</CustomerAddressPostCode>
		<ConsignmentReference>20/20 BS</ConsignmentReference>
		<AmountPrepaid>0</AmountPrepaid>
		<CarriageDepartmentNumber>0</CarriageDepartmentNumber>
        <CarriageNetAmount>0</CarriageNetAmount>
        <CarriageTaxAmount>0</CarriageTaxAmount>
        <CarriageTaxCode>0</CarriageTaxCode>
		<CustomerContactName>John  wood</CustomerContactName>
		<CustomersOrderNumber>20/20 BS</CustomersOrderNumber>
        <CustomersTelephoneNumber>0207 383 7071</CustomersTelephoneNumber>
		<DeliveryAddressLine1/>
        <DeliveryAddressLine2/>
        <DeliveryAddressLine3/>
        <DeliveryAddressLine4/>
        <DeliveryAddressPostCode/>
        <DeliveryAddressName/>      
		<DespatchDate>2006-09-01T16:33:33</DespatchDate>
		<DiscountType>0</DiscountType>
        <TaxAmount>0</TaxAmount>
		<GlobalDepartmentNumber>0</GlobalDepartmentNumber>
        <GlobalDetails/>
        <GlobalNominalCode/>
        <GlobalTaxCode>0</GlobalTaxCode>
		<Description>Test order </Description>
        <Notes1/>
        <Notes2/>
        <Notes3/>
		<PaymentReference/>
        <OrderStatusCode>UnallocatedUndelivered</OrderStatusCode>
        <OrderTakenBy>Website</OrderTakenBy>
		<OrderTypeCode>ProductInvoice</OrderTypeCode>
		<OrderItems>
		<SalesOrderItem>
         <Comment1/>
         <Comment2/>
		 <Description>Aduki Beans</Description>
         <DiscountRate>0</DiscountRate>

				        <FullNetAmount>9.77</FullNetAmount>
         <ItemNumber>1</ItemNumber>
         <JobReference/>
				       <NetAmount>9.77</NetAmount>
         <NominalCode>1000</NominalCode>
  		<QuantityAllocated>0</QuantityAllocated>

  		<QuantityToDispatch>0</QuantityToDispatch>
  		<QuantityDelivered>0</QuantityDelivered>
				        <QuantityOrdered>1</QuantityOrdered>
				        <StockCode>BEAADU6X500G</StockCode>
				        <TaxAmount>0</TaxAmount>
				        <TaxCode>0</TaxCode>

				        <TaxRate>0</TaxRate>
				        <UnitofSale>6x500g</UnitofSale>
				        <UnitPrice>9.77</UnitPrice>
						</SalesOrderItem>
			
			
						<SalesOrderItem>
         <Comment1/>
         <Comment2/>

				         <Description>Aduki Beans (ORG)</Description>
         <DiscountRate>0</DiscountRate>
				        <FullNetAmount>12.14</FullNetAmount>
         <ItemNumber>2</ItemNumber>
         <JobReference/>
				       <NetAmount>0</NetAmount>

         <NominalCode>1000</NominalCode>
  		<QuantityAllocated>0</QuantityAllocated>
  		<QuantityToDispatch>0</QuantityToDispatch>
  		<QuantityDelivered>0</QuantityDelivered>
				        <QuantityOrdered>1</QuantityOrdered>
				        <StockCode>BEAADUORG6X500G</StockCode>

				        <TaxAmount>0</TaxAmount>
				        <TaxCode>0</TaxCode>
				        <TaxRate>0</TaxRate>
				        <UnitofSale>6x500g</UnitofSale>
				        <UnitPrice>12.14</UnitPrice>
						</SalesOrderItem>
		</OrderItems>
      </order>
    </PlaceSalesOrder>
  </soap:Body>
</soap:Envelope>
</cfxml>



<cfset myResponse = postRequest(toString(soap), "PlaceSalesOrder") /> 
<cfreturn toString(myResponse) />

</cffunction>


<cffunction name="DeleteSalesOrder" access="public" returntype="string" output="false">
<cfargument name="orderNumber" type="string" required="true" />	

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <DeleteSalesOrder xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <orderNumber><cfoutput>#ARGUMENTS.orderNumber#</cfoutput></orderNumber>
    </DeleteSalesOrder>
  </soap:Body>
</soap:Envelope>
</cfxml>
<!--- try to post the order to Sage --->

<cfset myResponse = postRequest(toString(soap), "DeleteSalesOrder") /> 
<cfreturn toString(myResponse) />
 

</cffunction>


<cffunction name="GetCustomerListByPartialPostcode" access="public" returntype="string" output="false">
<cfargument name="partPostcode" type="string" required="true" />
<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCustomerListByPartialPostcode xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <postcode><cfoutput>#ARGUMENTS.partPostcode#</cfoutput></postcode>
    </GetCustomerListByPartialPostcode>
  </soap:Body>
</soap:Envelope>
</cfxml>

<!--- try to post the order to Sage --->
<cftry>
<cfset myResponse = postRequest(toString(soap), "GetCustomerListByPartialPostcode") /> 
	<cfreturn toString(myResponse) />

<cfcatch type="any">
		<cfreturn 0 />
</cfcatch>
</cftry> 

</cffunction>

<cffunction name="DisconnectForMaintenance" access="public" returntype="string" output="true">
<cfargument name="timeout" type="string" required="false" default="1" />
<!---initialise response vars--->
<cfset var isSuccessful=true />
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlString="" />

<cfxml variable="soap">
<cfoutput>	
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <DisconnectForMaintenance xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <timeout>#ARGUMENTS.Timeout#</timeout>
    </DisconnectForMaintenance>
  </soap:Body>
</soap:Envelope>
</cfoutput>
</cfxml>


<!--- try to post the order to Sage --->
<cftry>
<cfset myResponse = postRequest(toString(soap), "DisconnectForMaintenance") /> 
	<cfif cfhttp.statusCode eq "200 OK">
	<cfreturn "The Sage Web Services has disconnected and will reconnect after #ARGUMENTS.Timeout# minutes" />
	<cfelse>
		<cfreturn "error!: #myResponse#" />
	</cfif>
<cfcatch type="any">
		<cfreturn 0 />
</cfcatch>
</cftry> 

</cffunction>

 <!--- *** PlaceSalesOrder METHOD *** --->
<cffunction name="PlaceSalesOrder" access="public" returntype="string" output="true">
<cfargument name="FORM" type="struct" required="true" />

<!--- get the shopping basket contents query --->
<cfset var myBasketQuery = session.shopper.basket.list() />
<cfset var itemDetails="" />

<cfset var OrderDate=createObject("component", "cfc.departments.delivery").getDelDate()>

<!--- extract delivery notes string into array splitting by carriage return --->
<cfset var deliveryNotes = UTIL.splitByCR(FORM.delNotes)>

<!---initialise response vars--->
<cfset var isSuccessful=true />
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlOrderNumber="" />


<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder started for web order: " & right(session.shopper.orderID, 6));
</cfscript>

<cftry>
<cfxml variable="soap">
<cfoutput>	
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <PlaceSalesOrder xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <order>
       	<!--- amount --->
		<NetAmount>#decimalformat(session.shopper.basket.getGrandTotal())#</NetAmount>
        
		<!--- datetime --->
		<OrderDate>#DateFormat(OrderDate, "yyyy-mm-ddT")##TimeFormat(OrderDate, "HH:MM:SS")#</OrderDate>
       
		 <!--- order number: Null --->
		<OrderNumber></OrderNumber>
        
		<!--- customer account code --->
		<AccountCode>#SESSION.Auth.AccountID#</AccountCode>
        
		<!--- customer address --->
		<CustomerAddress1>#XMLFormat(FORM.delbuilding)#</CustomerAddress1>
        <CustomerAddress2>#XMLFormat(FORM.delline1)#</CustomerAddress2>
        <CustomerAddress3>#XMLFormat(FORM.deltown)#</CustomerAddress3>
        <CustomerAddress4>#XMLFormat(FORM.delcounty)#</CustomerAddress4>
        <CustomerAddressPostCode>#XMLFormat(FORM.delpostcode)#</CustomerAddressPostCode>
        
		<!--- AmountPrepaid --->
		<AmountPrepaid>0</AmountPrepaid>
        
		<!--- Carriage --->
		<CarriageDepartmentNumber>0</CarriageDepartmentNumber>
        <CarriageNetAmount>0</CarriageNetAmount>
        <CarriageNominalCode/>
        <CarriageTaxAmount>0</CarriageTaxAmount>
        <CarriageTaxCode>0</CarriageTaxCode>
        
		<CustomerContactName>#XMLFormat(SESSION.Auth.firstname)# #XMLFormat(SESSION.Auth.lastname)#</CustomerContactName>
        <!---/ customer PO ref? /--->
		<CustomersOrderNumber />
        <CustomersTelephoneNumber>#SESSION.Auth.Telnum#</CustomersTelephoneNumber>
        
		<!--- Delivery Notes entered here **? --->
		<cfif ArrayLen(deliveryNotes) gte 1>
		<DeliveryAddressLine1>#XMLFormat(deliveryNotes[1])#</DeliveryAddressLine1>
		<cfelse>
		<DeliveryAddressLine1/>
		</cfif>
        	<cfif ArrayLen(deliveryNotes) gte 2>
		<DeliveryAddressLine2>#XMLFormat(deliveryNotes[2])#</DeliveryAddressLine2>
		<cfelse>
		<DeliveryAddressLine2/>
		</cfif>
        	<cfif ArrayLen(deliveryNotes) gte 3>
		<DeliveryAddressLine3>#XMLFormat(deliveryNotes[3])#</DeliveryAddressLine3>
		<cfelse>
		<DeliveryAddressLine3/>
		</cfif>
        	<cfif ArrayLen(deliveryNotes) gte 4>
		<DeliveryAddressLine4>#XMLFormat(deliveryNotes[4])#</DeliveryAddressLine4>
		<cfelse>
		<DeliveryAddressLine4/>
		</cfif>
			<cfif ArrayLen(deliveryNotes) gte 5>
		<DeliveryAddressPostCode>#XMLFormat(deliveryNotes[5])#</DeliveryAddressPostCode>
		<cfelse>
		<DeliveryAddressPostCode/>
		</cfif>
        <DeliveryAddressName>#XMLFormat(FORM.deliveryContact)#</DeliveryAddressName>
        
		<!--- Despatch Date --->
		<DespatchDate>#DateFormat(OrderDate, "yyyy-mm-ddT")##TimeFormat(OrderDate, "HH:MM:SS")#</DespatchDate>
        
		<!--- Settlement Terms (NOT USED)--->
		<DiscountType>0</DiscountType>
        <TaxAmount>0</TaxAmount>
        
		<!--- Globals (NOT USED) --->
<!--- NOT USED --->			<GlobalDepartmentNumber>0</GlobalDepartmentNumber>
<!--- NOT USED --->         <GlobalDetails />
<!--- NOT USED --->         <GlobalNominalCode />
<!--- NOT USED --->         <GlobalTaxCode>0</GlobalTaxCode>
        
		<!--- NOTES (NOT USED) --->
						   <Description>WEB: #SESSION.Auth.Company#</Description>
<!--- NOT USED --->        <Notes1 />
<!--- NOT USED --->        <Notes2 />
<!--- NOT USED --->        <Notes3 />
        		
		<!--- CUSTOMER ORDER DETAILS --->
				<PaymentReference>#FORM.poref#</PaymentReference>
        		<OrderStatusCode>UnallocatedUndelivered</OrderStatusCode>
        		<OrderTakenBy>Website</OrderTakenBy>
        		<OrderTypeCode>ProductInvoice</OrderTypeCode>
        
		<OrderItems>
        	<!--- Loop over items in basket --->  
			<cfloop query="myBasketQuery">
			<cfset itemDetails = session.shopper.basket.getItemDetails(ProductID, false) />
						<SalesOrderItem>
<!--- NOT USED --->         <Comment1 />
<!--- NOT USED --->         <Comment2 />
				         <Description>#xmlformat(itemDetails.Description)#</Description>
<!--- NOT USED --->      <DiscountRate>#SESSION.Auth.DiscountRate#</DiscountRate>
				        <FullNetAmount>#decimalformat(itemDetails.SalePrice)#</FullNetAmount>
<!--- NOT USED --->         <ItemNumber>#currentrow#</ItemNumber>
<!--- NOT USED --->         <JobReference />
				       <NetAmount>#decimalformat(session.shopper.basket.getTotal(productID))#</NetAmount>
<!--- NOT USED --->         <NominalCode>4000</NominalCode>
<!--- NOT USED --->  		<QuantityAllocated>0</QuantityAllocated>
<!--- NOT USED --->  		<QuantityToDispatch>0</QuantityToDispatch>
<!--- NOT USED --->  		<QuantityDelivered>0</QuantityDelivered>
				        <QuantityOrdered>#quantity#</QuantityOrdered>
				        <StockCode>#xmlformat(itemDetails.stockcode)#</StockCode>
				        <TaxAmount>0</TaxAmount>
				        <TaxCode>0</TaxCode>
				        <TaxRate>0</TaxRate>
				        <UnitofSale>#xmlformat(itemDetails.UnitOfSale)#</UnitofSale>
				        <UnitPrice>#decimalformat(itemDetails.SalePrice)#</UnitPrice>
						</SalesOrderItem>
			</cfloop>
            </OrderItems>
      </order>
    </PlaceSalesOrder>
  </soap:Body>
</soap:Envelope>
</cfoutput>
</cfxml>
<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - created SOAP Envelope for web order: " & right(session.shopper.orderID, 6));
</cfscript>
<cfcatch type="any">
<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Failed to create SOAP Envelope for web order: " & right(session.shopper.orderID, 6));
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Web Order: " & right(session.shopper.orderID, 6)& " Error details: " & cfcatch.message & " Full error: " & cfcatch.details); 
</cfscript>
</cfcatch>
</cftry>

<!--- try to post the order to Sage --->
<cftry>
   <cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Posting Envelope to Aspidistra SageWS for web order: " & right(session.shopper.orderID, 6));
	</cfscript>	
<cfset myResponse = postRequest(toString(soap), "PlaceSalesOrder") /> 
<cfcatch type="any">
	<cfset session.shopper.orderError = "Error: Sage Web Service did not respond" />
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Error: No one available to collect SOAP Envelope ... Aspidistra SageWS did not respond. Web Order: " & right(session.shopper.orderID, 6));
	</cfscript>		
</cfcatch>
</cftry>

<!--- try to parse the response --->
<cftry>
	<!--- parse the xml response and return the order number --->
	<cfset  xmlResponse		=	xmlParse(myResponse)> 
	<cfset  xmlOrderNumber	=	xmlResponse.xmlRoot.xmlChildren[2].PlaceSalesOrderResponse.PlaceSalesOrderResult.xmlText />
	
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - AspiDistra WS accepted Order. Web Order: " & right(session.shopper.orderID, 6) & " is now Sage Order: " & toString(xmlOrderNumber));
	</cfscript>	
	
	<cfreturn toString(xmlOrderNumber) />

<cfcatch type="any">
	<!--- <cfset session.shopper.orderError = "error message: " & cfcatch.message & ", error details: " & cfcatch.detail />  --->
	<cfset session.shopper.orderError = "Error posting order to sage: " & myResponse />
	
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - AspiDistra WS refused Order. Reason: " & myResponse);
	</cfscript>	
	
	<cfreturn 0 />
</cfcatch>
</cftry>

</cffunction>

 <!--- *** SEND SOAP REQUEST  *** --->
<cffunction name="postRequest" output="true" returntype="string" access="public">
<cfargument name="soapRequest" type="string" required="true">
<cfargument name="sageWSMethod" type="string" required="true">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cftry>
	<cfhttp url="http://#VARIABLES.SageWSHost#:#VARIABLES.SageWSPort#/accountsWS/AccountsIntegration.asmx" GetAsBinary="no" charset="utf-8" method="post" timeout="120">
		<cfhttpparam name="SOAPAction" type="header"  value="http://www.aspidistra.com/WebService/AccountsIntegration/#sageWSMethod#">
		<cfhttpparam name="xml" 	   value="#ARGUMENTS.soapRequest#" type="xml" />
	</cfhttp>

	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Aspidistra SageWS responds: " & cfhttp.statusCode & " - Server: " & variables.SageWSHost & " Method:" & ARGUMENTS.sageWSMethod);	
	</cfscript>
<cfcatch type="any">
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Aspidistra SageWS responds: " & cfhttp.statusCode & " - Server: " & variables.SageWSHost & " Method:" & ARGUMENTS.sageWSMethod);	
	</cfscript>
</cfcatch>
</cftry>

<cfscript>
//write to Sage log
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Post to server:  " & variables.SageWSHost & " Method:" & ARGUMENTS.sageWSMethod & " Response time:" & tickinterval & "seconds" );	
</cfscript>
	
<cfreturn trim(cfhttp.filecontent)>
</cffunction>

</cfcomponent>