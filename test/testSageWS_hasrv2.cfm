<cffunction name="GetCustomerData" output="true" returntype="void" access="private">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

	<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx/GetCustomerData"
			method="post">
	<CFHTTPPARAM type="FORMFIELD" name="accountCode" value="20/20">
	</cfhttp>



<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<br />
#trim(cfhttp.filecontent)#
</cfoutput>


</cffunction>

<cffunction name="accountStatus" output="true" returntype="void" access="private">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

	<cfhttp url="http://hasrv2:81/accountsWS/AccountsIntegration.asmx/AccountsStatus"
			method="post">
	<CFHTTPPARAM type="FORMFIELD" name="test1" value="Hello">
	</cfhttp>



<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<p>Response: #htmleditformat(trim(cfhttp.filecontent))#</p>
<ul>
<li>cfhttp.charSet: #cfhttp.charSet#</li>
<li>cfhttp.errorDetail: #cfhttp.errorDetail#</li>
<li>cfhttp.header: #cfhttp.header#</li>
<li>cfhttp.mimeType:  #cfhttp.mimeType#</li>
<li>cfhttp.statusCode: #cfhttp.statusCode# </li>
<li>cfhttp.text: #cfhttp.text# </li>
</ul>

<cfdump var=#cfhttp.responseHeader#>
</cfoutput>

</cffunction>

<cffunction name="accountStatusSOAP" output="true" returntype="void" access="private">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AccountsStatus xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
</cfxml>


	<cfhttp url="http://hasrv2:81/accountsWS/AccountsIntegration.asmx" GetAsBinary="no" charset="utf-8" method="post">
	<cfhttpparam name="SOAPAction" type="header"  value="http://www.aspidistra.com/WebService/AccountsIntegration/AccountsStatus">
	<cfhttpparam name="xml" 	   value="#toString(soap)#" type="xml" />
	</cfhttp>



<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<p>Response: #htmleditformat(trim(cfhttp.filecontent))#</p>
<ul>
<li>cfhttp.charSet: #cfhttp.charSet#</li>
<li>cfhttp.errorDetail: #cfhttp.errorDetail#</li>
<li>cfhttp.header: #cfhttp.header#</li>
<li>cfhttp.mimeType:  #cfhttp.mimeType#</li>
<li>cfhttp.statusCode: #cfhttp.statusCode# </li>
<li>cfhttp.text: #cfhttp.text# </li>
</ul>


<cfdump var=#cfhttp.responseHeader#>
</cfoutput>

</cffunction>

<cffunction name="postRequest" output="true" returntype="string" access="private">
<cfargument name="soapRequest" type="string" required="true">


<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

	<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx/GetCustomerData"
			method="post">
	<cfhttpparam name="xml" value="20/20" type="xml" />
	</cfhttp>		


<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;

//write the application started
//application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & "Post to server:  " & variables.SageWSHost & " Method:" & ARGUMENTS.sageWSMethod & " Response time:" & tickinterval & "seconds" );	
</cfscript>


<cfreturn trim(cfhttp.filecontent)>
</cffunction>


<cffunction name="PlaceSalesOrderSOAP" output="true" returntype="void" access="private">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<!--- <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soap:Body>
    <PlaceSalesOrder xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <order> 	
		<NetAmount>68.22</NetAmount>
		<OrderDate>2006-09-01T00:00:00</OrderDate>
		<OrderNumber>9998</OrderNumber>
		<AccountCode>20/20</AccountCode>
		<CustomerAddress1>Clearview</CustomerAddress1>
        <CustomerAddress2>11 Mandeville Drive</CustomerAddress2>
        <CustomerAddress3 />
        <CustomerAddress4>St. Albans Herts</CustomerAddress4>
        <CustomerAddressPostCode>AL12LD</CustomerAddressPostCode>
		<AmountPrepaid>0</AmountPrepaid>
		<CarriageDepartmentNumber>0</CarriageDepartmentNumber>
        <CarriageNetAmount>0</CarriageNetAmount>
        <CarriageNominalCode/>
        <CarriageTaxAmount>0</CarriageTaxAmount>
        <CarriageTaxCode>0</CarriageTaxCode>
        <CustomerContactName>Matt Barfoot</CustomerContactName>
		<CustomersOrderNumber/>
        <CustomersTelephoneNumber>0870 486 2370</CustomersTelephoneNumber>        
		<DeliveryAddressLine1/>
        <DeliveryAddressLine2/>
        <DeliveryAddressLine3/>
        <DeliveryAddressLine4/>
        <DeliveryAddressPostCode/>
        <DeliveryAddressName/>
		<DespatchDate>2006-07-02T00:00:00</DespatchDate>
        <DiscountType>0</DiscountType>
        <TaxAmount>0</TaxAmount>
        <GlobalDepartmentNumber>0</GlobalDepartmentNumber>
        <GlobalDetails/>
        <GlobalNominalCode/>
        <GlobalTaxCode>0</GlobalTaxCode>
		<Description/>
		<Notes1/>
        <Notes2/>
        <Notes3/>
		<PaymentReference/>
        <OrderStatusCode>UnallocatedUndelivered</OrderStatusCode>
        <OrderTakenBy>Website</OrderTakenBy>
        <OrderTypeCode>SopInvoice</OrderTypeCode>
		<OrderItems>
			<SalesOrderItem>
				 <Comment1/> 
				 <Comment2/>
				 <Description>Aduki (Adzuki) Beans, (cleaned &amp; polished)   .C</Description>
				 <DiscountRate>0</DiscountRate>
				 <FullNetAmount>46.31</FullNetAmount>
				 <ItemNumber>1</ItemNumber>
				 <JobReference/>
				 <NetAmount>0</NetAmount>
				 <NominalCode>1700</NominalCode>
				 <QuantityAllocated>0</QuantityAllocated>
		  		<QuantityToDispatch>0</QuantityToDispatch>
				<QuantityDelivered>0</QuantityDelivered>
				<QuantityOrdered>1</QuantityOrdered>
				<StockCode>BEAADU25K</StockCode>
				<TaxAmount>0</TaxAmount>
				<TaxCode>0</TaxCode>
				<TaxRate>0</TaxRate>
				 <UnitofSale>25kg</UnitofSale>
				 <UnitPrice>46.31</UnitPrice>
			</SalesOrderItem>
		 </OrderItems>
      </order>
	 </PlaceSalesOrder>
  </soap:Body>
</soap:Envelope> --->
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soap:Body>
    <PlaceSalesOrder xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <order>
       	
		<NetAmount>21.91</NetAmount>
        
		
		<OrderDate>2006-09-01T16:45:33</OrderDate>
       
		 
		<OrderNumber>9997</OrderNumber>

        
		
		<AccountCode>20/20</AccountCode>
        
		
		<CustomerAddress1>20/20             BS</CustomerAddress1>
        <CustomerAddress2>BAXTERSTOREY Catering 20-23 Mandela St</CustomerAddress2>
        <CustomerAddress3> </CustomerAddress3>
        <CustomerAddress4>Camden London</CustomerAddress4>
        <CustomerAddressPostCode>NW1 0DU</CustomerAddressPostCode>

        
		
		<AmountPrepaid>0</AmountPrepaid>
        
		
		<CarriageDepartmentNumber>0</CarriageDepartmentNumber>
        <CarriageNetAmount>0</CarriageNetAmount>
        <CarriageNominalCode/>
        <CarriageTaxAmount>0</CarriageTaxAmount>
        <CarriageTaxCode>0</CarriageTaxCode>

        
		<CustomerContactName>John  wood</CustomerContactName>
        
		<CustomersOrderNumber/>
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
        
		
 	   <Description/>
        <Notes1/>
        <Notes2/>
        <Notes3/>
        		
		
				<PaymentReference/>
        		<OrderStatusCode>UnallocatedUndelivered</OrderStatusCode>
        		<OrderTakenBy>Website</OrderTakenBy>

        		<OrderTypeCode>SopInvoice</OrderTypeCode>
        
		<OrderItems>
        	  
			
			
						<SalesOrderItem>
         <Comment1/>
         <Comment2/>
				         <Description>Aduki Beans</Description>
         <DiscountRate>0</DiscountRate>

				        <FullNetAmount>9.77</FullNetAmount>
         <ItemNumber>1</ItemNumber>
         <JobReference/>
				       <NetAmount>0</NetAmount>
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


<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx"
			method="post">
	<cfhttpparam type="header" name="SOAPAction" value="http://www.aspidistra.com/WebService/AccountsIntegration/PlaceSalesOrder">
	<cfhttpparam name="xml" value="#toString(soap)#" type="xml" />
</cfhttp>

<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<p>Response#htmleditformat(trim(cfhttp.filecontent))#</p>
<ul>
<li>cfhttp.charSet: #cfhttp.charSet#</li>
<li>cfhttp.errorDetail: #cfhttp.errorDetail#</li>
<li>cfhttp.header: #cfhttp.header#</li>
<li>cfhttp.mimeType:  #cfhttp.mimeType#</li>
<li>cfhttp.statusCode: #cfhttp.statusCode# </li>
<li>cfhttp.text: #cfhttp.text# </li>
</ul>

<cfdump var=#cfhttp.responseHeader#>
</cfoutput>

</cffunction>


<cffunction name="registerUser" output="true" returntype="void" access="private">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <CreateCustomer xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/">
      <customer>
        <AccountCode>0WCLEARV</AccountCode>
        <AccountName>Clearview Webmedia Limited</AccountName>
        <AccountOnHold>FALSE</AccountOnHold>
        <AccountStatus>0</AccountStatus>
        <AccountAddressLine1></AccountAddressLine1>
        <AccountAddressLine2>11 Mandeville Drive</AccountAddressLine2>
        <AccountAddressLine3>St. Albans</AccountAddressLine3>
        <AccountAddressLine4>Herts</AccountAddressLine4>
        <AccountAddressPostCode>AL12LD</AccountAddressPostCode>
        <Password>te57er</Password>
        <Balance>0</Balance>
        <ContactName>Matt Barfoot</ContactName>
        <CountryCode>GB</CountryCode>
        <CreditLimit>0</CreditLimit>
        <DefaultNominalCode>1000</DefaultNominalCode>
        <DefaultTaxCode>0</DefaultTaxCode>
        <DeliveryAddressLine1>Ring on my doorbell</DeliveryAddressLine1>
        <DeliveryAddressLine2>Don't take around back</DeliveryAddressLine2>
        <DeliveryAddressLine3>No business sing yet</DeliveryAddressLine3>
        <DeliveryAddressLine4>No deliveries before 6am</DeliveryAddressLine4>
        <DeliveryAddressPostCode>Did you get all that?</DeliveryAddressPostCode>
        <DeliveryContactName>Matt</DeliveryContactName>
        <DeliveryFaxNumber>DONT FAX</DeliveryFaxNumber>
        <DeliveryName>Clearview Webmedia Limited</DeliveryName>
        <DeliveryTelephoneNumber>RING MOBILE</DeliveryTelephoneNumber>
        <DiscountRate>0</DiscountRate>
        <EMailAddress>string</EMailAddress>
        <FaxNumber>string</FaxNumber>
        <TelephoneNumber>string</TelephoneNumber>
        <VATRegistrationNumber>string</VATRegistrationNumber>
      </customer>
    </CreateCustomer>
  </soap:Body>
</soap:Envelope>
</cfxml>


<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx"
			method="post">
	<cfhttpparam type="header" name="SOAPAction" value="http://www.aspidistra.com/WebService/AccountsIntegration/CreateCustomer">
	<cfhttpparam name="xml" value="#toString(soap)#" type="xml" />
</cfhttp>

<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<br />
#htmleditformat(trim(cfhttp.filecontent))#
</cfoutput>

</cffunction>

<cffunction name="GetCustomerListSOAP" output="true" returntype="void" access="private">

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


<cfhttp url="http://localhost:81/accountsWS/AccountsIntegration.asmx" method="post">
	<cfhttpparam type="header" name="SOAPAction" value="http://www.aspidistra.com/WebService/AccountsIntegration/GetCustomerList">
	<cfhttpparam name="xml" value="#toString(soap)#" type="xml" />
</cfhttp>

<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<p>Response: #htmleditformat(trim(cfhttp.filecontent))#</p>
<ul>
<li>cfhttp.charSet: #cfhttp.charSet#</li>
<li>cfhttp.errorDetail: #cfhttp.errorDetail#</li>
<li>cfhttp.header: #cfhttp.header#</li>
<li>cfhttp.mimeType:  #cfhttp.mimeType#</li>
<li>cfhttp.statusCode: #cfhttp.statusCode# </li>
<li>cfhttp.text: #cfhttp.text# </li>
</ul>

<cfdump var=#cfhttp.responseHeader#>
</cfoutput>

</cffunction>

<cfoutput>#accountStatusSOAP()#<!--- #registerUser()# ---></cfoutput>
