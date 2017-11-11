<cfxml variable="ack">
<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><PlaceSalesOrderResponse xmlns="http://www.aspidistra.com/Sage200/WebService"><PlaceSalesOrderResult><OrderNumber>0000124000546</OrderNumber><AspidistraID>00000000-0000-0000-0000-000000000000</AspidistraID><CustomerOrderNumber /><OrderDate>2008-10-09T15:54:37</OrderDate><RequestedDate>2008-10-11T15:54:37</RequestedDate><PromisedDate>2008-10-11T15:54:37</PromisedDate><OrderTakenBy>WEBSITE</OrderTakenBy><AccountCode>LEHBRO2</AccountCode><InvoiceAddress><Line1>Restaurant Assoc (7th floor Staff)</Line1><Line2>25 Bank St</Line2><Line3>London</Line3><Line4 /><PostCode>E14 5LE</PostCode><CountryCode>GB</CountryCode><Country>Great Britain</Country></InvoiceAddress><DeliveryAddress><Line1>Delivery entrance via Billingsgate</Line1><Line2>Market.Security will direct.</Line2><Line3>Loading bay V8.</Line3><Line4 /><PostCode /><CountryCode>GB</CountryCode><Country>Great Britain</Country></DeliveryAddress><OrderLines><StandardItemLine><ID>4604616</ID><StockCode>BEAADU25K</StockCode><Comment /><Description>Aduki (Adzuki) Beans, (cleaned &amp; polished)</Description><QuantityOrdered>2.00000</QuantityOrdered><QuantityAllocated>0.00000</QuantityAllocated><QuantityDelivered>0.00000</QuantityDelivered><UnitPrice>49.99000</UnitPrice><DiscountRate>12.50</DiscountRate><FullNetAmount>87.48</FullNetAmount><NominalCode><Reference>4000</Reference><CostCentre /><Department /></NominalCode><TaxCode>0</TaxCode><TaxRate>0.00</TaxRate><TaxAmount>0.00</TaxAmount><Warehouse>Home</Warehouse></StandardItemLine></OrderLines><NetAmount>87.48</NetAmount><TaxAmount>0</TaxAmount><GrossAmount>87.48</GrossAmount></PlaceSalesOrderResult></PlaceSalesOrderResponse></soap:Body></soap:Envelope>
</cfxml>

<cfset xmlResponse = xmlParse(ack)>
<cfset  xmlOrderNumber	=	xmlResponse.xmlRoot.xmlChildren[1].PlaceSalesOrderResponse.PlaceSalesOrderResult.OrderNumber.xmlText />
<cfoutput>#xmlOrderNumber#</cfoutput>

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
	
	<cfoutput>#xmlOrderNumber#</cfoutput>	