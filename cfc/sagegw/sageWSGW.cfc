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
	<li>Sage Version: Line 200 V5.0</li>
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



<cffunction name="getFreeStockLevels" access="public" returntype="string" output="false">
<cfargument name="a" type="array" required="true" />
<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Body>
    <GetFreeStockLevels xmlns="http://www.aspidistra.com/Sage200/WebService">
      <stockcodes>
	<cfloop from="1" to="#arraylen(ARGUMENTS.a)#" index="i">
        <string><cfoutput>#ARGUMENTS.A[i]#</cfoutput></string>
	</cfloop>
      </stockcodes>
      <warehouses>
        <string>Home</string>
      </warehouses>
    </GetFreeStockLevels>
  </soap12:Body>
</soap12:Envelope>
</cfxml>

<cfset myResponse = postRequest(toString(soap), "GetFreeStockLevels") /> 
<cfreturn toString(myResponse) />
<!--- try to post the order to Sage --->
<!---<cftry>
<cfset myResponse = postRequest(toString(soap), "GetFreeStockLevels") /> 
	<cfreturn toString(myResponse) />

 <cfcatch type="any">
		<cfreturn 0 />
</cfcatch> 
</cftry> --->

</cffunction>



<cffunction name="ListCustomers" access="public" returntype="string" output="false">

<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ListCustomers xmlns="http://www.aspidistra.com/Sage200/WebService" />
  </soap:Body>
</soap:Envelope>
</cfxml>

<!--- try to post the order to Sage --->
<cftry>
<cfset myResponse = postRequest(toString(soap), "ListCustomers") /> 
	<cfreturn toString(myResponse) />

<cfcatch type="any">
		<cfreturn 0 />
</cfcatch>
</cftry> 

</cffunction>


<cffunction name="PlaceSalesOrder" access="public" returntype="string" output="true">
<cfargument name="FORM" type="struct" required="true" />

<!--- get the shopping basket contents query --->
<cfset var myBasketQuery = session.shopper.basket.list() />
<cfset var itemDetails="" />
<cfset var deliveryDate="" />
<cfset var deliveryDrop="" />
<cfset var deliveryVan="" />





<!--- extract delivery notes string into array splitting by carriage return
<cfset var deliveryNotes = UTIL.splitByCR(FORM.delNotes)> --->

<!---initialise response vars--->
<cfset var isSuccessful=true />
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlOrderNumber="" />

<!---get delivery info--->
<cfset var delOb=createObject("component", "cfc.departments.delivery") />
<cfset deliveryDate=delOb.getDelDate(SESSION.Auth.AccountID) />
<cfset deliveryDrop=delOb.getDelDrop(SESSION.Auth.AccountID) /> 
<cfset deliveryVan=delOb.getDelVan(SESSION.Auth.AccountID) />

<cfscript>
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder started for web order: " & right(session.shopper.orderID, 6));
</cfscript>


<cftry>
	<cfsavecontent  variable="soap">
	<cfoutput>	
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:web="http://www.aspidistra.com/Sage200/WebService">
   <soap:Header/>
	<soap:Body>
		<web:PlaceSalesOrder>
		<web:orderCreationInfo>  
	  		<web:OrderNumber /> 
	  		<web:AspidistraID>00000000-0000-0000-0000-000000000000</web:AspidistraID> 
	  		<cfif isdefined("FORM.customerPO")>
	  		<web:CustomerOrderNumber>#FORM.customerPO#</web:CustomerOrderNumber>
	  		<cfelse>
	  		<web:CustomerOrderNumber/> 	  		
	  		</cfif>
			<web:OrderDate>#DateFormat(now(), "yyyy-mm-ddT")##TimeFormat(now(), "HH:MM:SS")#</web:OrderDate>
			<web:RequestedDate>#DateFormat(DeliveryDate, "yyyy-mm-ddT")#00:00:00</web:RequestedDate> 
	  		<web:PromisedDate>#DateFormat(DeliveryDate, "yyyy-mm-ddT")#00:00:00</web:PromisedDate> 
	  		<web:OrderTakenBy>WEBSITE</web:OrderTakenBy>
			<web:AccountCode>#SESSION.Auth.AccountID#</web:AccountCode>
			<web:DeliveryAddress />
			<web:AnalysisCode4>#deliveryDrop#</web:AnalysisCode4>
			<web:AnalysisCode5>#deliveryVan#</web:AnalysisCode5>
			<web:OrderLines>
				<cfloop query="myBasketQuery">
                    <cfset product = session.shopper.basket.getProduct(ProductID)/>
				<web:StandardItemLine>
				  <web:StockCode>#xmlformat(product.getStockCode())#</web:StockCode>
				  <web:Comment /> 
				  <web:Description>#xmlformat(product.getName())#</web:Description>
				  <web:QuantityOrdered>#quantity#</web:QuantityOrdered> 
				  <web:UnitPrice>#decimalformat(product.getSalePrice())#</web:UnitPrice>
				  <web:DiscountRate>#SESSION.Auth.DiscountRate#</web:DiscountRate> 
				  <web:FullNetAmount>#decimalformat(session.shopper.basket.getTotal(productID, false))#</web:FullNetAmount> 
				  <web:TaxCode>0</web:TaxCode> 
				  <web:TaxRate>0.00</web:TaxRate> 
				  <web:TaxAmount>0.00</web:TaxAmount> 
				  <web:Warehouse>Home</web:Warehouse> 
			    </web:StandardItemLine>
				</cfloop>
	            </web:OrderLines>
         </web:orderCreationInfo>
      </web:PlaceSalesOrder>
   </soap:Body>
</soap:Envelope>
	</cfoutput>
	</cfsavecontent>

	<cfif application.orderdebug>
	<cfmail to="webmaster@vegetarianexpress.co.uk" from="debug@vegetarianexpress.co.uk" subject="VE Order Trace Email" type="html">
			<cfdump var="#SOAP#" /><br /><br />
			<cfdump var="#SESSION#" />
	</cfmail>
	</cfif>
	
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - created SOAP Envelope for web order: " & right(session.shopper.orderID, 6));
    application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ":" & soap );
	</cfscript>
<cfcatch type="any">
	
	<cfrethrow/>
	
	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Failed to create SOAP Envelope for web order: " & right(session.shopper.orderID, 6));
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Web Order: " & right(session.shopper.orderID, 6)& " Error details: " & cfcatch.message & " Full error: " & cfcatch.detail); 
	</cfscript>
</cfcatch>
</cftry>

<!--- try to post the order to Sage --->
<cftry>
   <cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - Posting Envelope to Aspidistra SageWS for web order: " & right(session.shopper.orderID, 6));
	</cfscript>	
    <cfset myResponse = postRequest(toString(soap), "PlaceSalesOrder") />
    <cfscript>
        application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - PlaceSalesOrder - response: " & myResponse );
    </cfscript>
    <cfcatch type="any">
    <cfrethrow/>
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
	<cfset  xmlOrderNumber	=	xmlResponse.xmlRoot.xmlChildren[1].PlaceSalesOrderResponse.PlaceSalesOrderResult.OrderNumber.xmlText />
	
	<!---strip leading zeros--->
	<cfscript>
		if (left(xmlOrderNumber, 1) eq "0") {
			for (i=1;i lte len(xmlOrderNumber); i=i+1) {
				if (left(XmlOrderNumber, 1) eq "0") {
					XmlOrderNumber = right(xmlOrderNumber, len(xmlOrderNumber)-1);
				} else {
					break;
				}
			}
		}
	</cfscript>
	
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







<cffunction name="testSalesOrder" access="public" returntype="string" output="false">
<cfset var myResponse="" />
<cfset var xmlResponse="" />
<cfset var xmlOrderNumber="" />
<cfset var delivery=createObject("component", "cfc.departments.delivery") />
<cfxml variable="soap">

<cfoutput>	
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:web="http://www.aspidistra.com/Sage200/WebService">
    <soap:Header/>
    <soap:Body>
        <web:PlaceSalesOrder>
            <web:orderCreationInfo>
                <web:OrderNumber />
                <web:AspidistraID>00000000-0000-0000-0000-000000000000</web:AspidistraID>
                <web:CustomerOrderNumber></web:CustomerOrderNumber>
                <web:OrderDate>2015-03-29T23:19:05</web:OrderDate>
                <web:RequestedDate>2015-03-31T00:00:00</web:RequestedDate>
                <web:PromisedDate>2015-03-31T00:00:00</web:PromisedDate>
                <web:OrderTakenBy>WEBSITE</web:OrderTakenBy>
                <web:AccountCode>WEBTEST</web:AccountCode>
                <web:DeliveryAddress />
                <web:AnalysisCode4></web:AnalysisCode4>
                <web:AnalysisCode5>90</web:AnalysisCode5>
                <web:OrderLines>
                    <web:StandardItemLine>
                        <web:StockCode>BUTPEACRU2.5K</web:StockCode>
                        <web:Comment />
                        <web:Description>Peanut Butter, Crunchy &apos;Whole Earth&apos;</web:Description>
                        <web:QuantityOrdered>2</web:QuantityOrdered>
                        <web:UnitPrice>21.96</web:UnitPrice>
                        <web:DiscountRate>0</web:DiscountRate>
                        <web:FullNetAmount>43.92</web:FullNetAmount>
                        <web:TaxCode>0</web:TaxCode>
                        <web:TaxRate>0.00</web:TaxRate>
                        <web:TaxAmount>0.00</web:TaxAmount>
                        <web:Warehouse>Home</web:Warehouse>
                    </web:StandardItemLine>

                </web:OrderLines>
            </web:orderCreationInfo>
        </web:PlaceSalesOrder>
    </soap:Body>
</soap:Envelope>
</cfoutput>	
	
	
</cfxml>

<cfreturn toString(soap)/>

<!--- <cfset myResponse = postRequest(toString(soap), "PlaceSalesOrder") /> 
<cfreturn toString(myResponse) /> --->
	
<!---
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:web="http://www.aspidistra.com/Sage200/WebService">
   <soap:Header/>
   <soap:Body><web:PlaceSalesOrder>
         <!--Optional:-->
         <web:orderCreationInfo>
            <!--Optional:-->
            <web:OrderNumber/>
            <!--Optional:-->
            <web:AspidistraID>00000000-0000-0000-0000-000000000000</web:AspidistraID>
            <!--Optional:-->
            <web:CustomerOrderNumber/>
            <!--Optional:-->
            <web:OrderDate><cfoutput>#DateFormat(now(), "yyyy-mm-ddT")##TimeFormat(now(), "HH:MM:SS")#</cfoutput></web:OrderDate>
            <!--Optional:-->
            <web:RequestedDate><cfoutput>#DateFormat(now(), "yyyy-mm-ddT")##TimeFormat(now(), "HH:MM:SS")#</cfoutput></web:RequestedDate>
            <!--Optional:-->
            <web:PromisedDate><cfoutput>#DateFormat(now(), "yyyy-mm-ddT")##TimeFormat(now(), "HH:MM:SS")#</cfoutput></web:PromisedDate>
            <!--Optional:-->
            <web:OrderTakenBy>WEBSITE</web:OrderTakenBy>
            <!--Optional:-->
            <web:AccountCode>20/20</web:AccountCode>
            <!--Optional:-->
            <web:DeliveryAddress />
            
            <!--Optional:-->
            <web:OrderLines>
<!--- 			 <web:AdditionalCharge>
	   	        <web:NetValue>44.99</web:NetValue>    
          	</web:AdditionalCharge> --->
			  <web:StandardItemLine>
				  <web:StockCode>BEAADU25K</web:StockCode> 
				  <web:Comment /> 
				  <web:Description>Aduki (Adzuki) Beans, (cleaned &amp; polished)</web:Description> 
				  <web:QuantityOrdered>1</web:QuantityOrdered> 
				  <web:UnitPrice>49.99</web:UnitPrice> 
				  <web:DiscountRate>1.00</web:DiscountRate>
	   			  <!--- <web:NominalCode xsi:nil="true" /> --->
				  <web:TaxCode>0</web:TaxCode> 
				  <web:Warehouse>Home</web:Warehouse> 
		    	</web:StandardItemLine>
		    </web:OrderLines>
         </web:orderCreationInfo>
      </web:PlaceSalesOrder>
   </soap:Body>
</soap:Envelope>
--->
</cffunction>


<cffunction name="CancelSalesOrder" access="public" returntype="string" output="false">
<cfargument name="orderNumber" type="string" required="true" />	

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <CancelSalesOrder xmlns="http://www.aspidistra.com/Sage200/WebService">
      <orderNumber><cfoutput>#ARGUMENTS.ordernumber#</cfoutput></orderNumber>
    </CancelSalesOrder>
  </soap:Body>
</soap:Envelope>
</cfxml>
<!--- try to post the order to Sage --->

<cfset myResponse = postRequest(toString(soap), "CancelSalesOrder") /> 
<cfreturn toString(myResponse) />
 

</cffunction>


<cffunction name="ListCustomersByPartialPostcode" access="public" returntype="string" output="false">
<cfargument name="partPostcode" type="string" required="true" />
<!--- set up time counter vars--->
<cfset var tickBegin=getTickCount()>
<cfset var tickEnd=0>

<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ListCustomersByPartialPostcode xmlns="http://www.aspidistra.com/Sage200/WebService">
      <postcode>#ARGUMENTS.partPostCode#</postcode>
    </ListCustomersByPartialPostcode>
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



 <!--- *** PlaceSalesOrder METHOD *** --->
<cffunction name="PlaceSalesOrder_deprecated" access="public" returntype="string" output="true">
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
      <orderCreationInfo>
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
		<DiscountType>1<!--- 0 ---></DiscountType>
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
        
		<OrderLines>
        	<!--- Loop over items in basket --->  
			<cfloop query="myBasketQuery">
			<cfset itemDetails = session.shopper.basket.getItemDetails(ProductID, false) />
						<SalesOrderItem>
<!--- NOT USED --->         <Comment1 />
<!--- NOT USED --->         <Comment2 />
				         <Description>#xmlformat(itemDetails.Description)#</Description>
<!--- NOT USED --->      <DiscountRate>#SESSION.Auth.DiscountRate#</DiscountRate>
<!--- NOT USED --->         <FullNetAmount>#decimalformat(session.shopper.basket.getTotal(productID, false))#</FullNetAmount>
							<ItemNumber>#currentrow#</ItemNumber>
<!--- NOT USED --->         <JobReference />
				       	<NetAmount>#decimalformat(session.shopper.basket.getTotal(productID, true))#</NetAmount>
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
            </OrderLines>
      </orderCreationInfo>
    </PlaceSalesOrder>
  </soap:Body>
</soap:Envelope>
</cfoutput>
</cfxml>

<cfif application.orderdebug>
<cfmail to="webmaster@vegetarianexpress.co.uk" from="debug@vegetarianexpress.co.uk" subject="VE Order Trace Email" type="html">
		<cfdump var="#SOAP#" /><br /><br />
		<cfdump var="#SESSION#" />
</cfmail>
</cfif>

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
	<cfhttp url="#application.sageWSendpoint#" port="#application.sageWSendpointport#" GetAsBinary="no" charset="utf-8" method="post" timeout="120">
		<cfhttpparam name="SOAPAction" type="header"  value="http://www.aspidistra.com/Sage200/WebService/#sageWSMethod#">
		<cfhttpparam name="xml" 	   value="#ARGUMENTS.soapRequest#" type="xml" />
	</cfhttp>

	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Aspidistra SageWS responds: " & cfhttp.statusCode & " - endpoint: " & application.sageWSendpoint & " Method:" & ARGUMENTS.sageWSMethod);
    application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Aspidistra SageWS responds: " & cfhttp.filecontent);
	</cfscript>
<cfcatch type="any">
	<cfrethrow />
<!--- 	<cfscript>
	application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Aspidistra SageWS responds: " & iif(isdefined("cfhttp.statusCode"),cfhttp.statusCode,"") & " - Server: " & application.sageWSendpoint & " Method:" & ARGUMENTS.sageWSMethod);	
	</cfscript> --->
</cfcatch>
</cftry>

<cfscript>
//write to Sage log
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
application.sageWSlog.write(timeformat(now(), 'h:mm:ss tt') & ": SageWS - Post to server:  " & application.sageWSendpoint & " Method:" & ARGUMENTS.sageWSMethod & " Response time:" & tickinterval & "seconds" );	
</cfscript>
	
<cfreturn trim(cfhttp.filecontent)>
</cffunction>

</cfcomponent>