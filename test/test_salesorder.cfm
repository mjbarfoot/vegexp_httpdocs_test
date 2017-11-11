<cfscript>
SageWSGW = createObject("component","cfc.sagegw.sageWSGW").init();
SOAPTestSalesOrder = SageWSGW.testSalesOrder();
writeOutput("<p>Sending Sales Order ...</p>");
writeOutput("<pre>Server response: " & HTMLEditFormat(SageWSGW.postRequest(SOAPTestSalesOrder, "PlaceSalesOrder")) & "</pre>" );
writeOutput("<p>SOAP Request</p>")
writeOutput("<pre>" & HTMLEditFormat(SOAPTestSalesOrder) & "</pre>");


</cfscript>