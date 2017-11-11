<cfsavecontent variable="teststr">
<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><soap:Fault><soap:Code><soap:Value>soap:Receiver</soap:Value></soap:Code><soap:Reason><soap:Text xml:lang="en">Server was unable to process request. ---&gt; Error while running command ---&gt; The specified quantity exceeds the stock available at the location.</soap:Text></soap:Reason><soap:Detail /></soap:Fault></soap:Body></soap:Envelope>
</cfsavecontent>
<cfxml variable="myStrXML">
<cfoutput>#replace(teststr,'<?xml version="1.0" encoding="utf-8"?>','')#</cfoutput>
</cfxml>

<!--- <cfoutput>#replace(replace(rereplace(testStr, "^(?six) < (.*):Envelope .* <\\1:Body> (.*) </\\1:Body> .* $", "", "All"), "soap:Receiver",""), """/>","")#</cfoutput> --->
<Cfset myresult = xmlsearch(myStrXML,"//soap:Reason")>
<cfdump var="#myresult[1].XmlChildren[1].xmlText#" />

<cfoutput>#tostring(myresult[1].XmlChildren[1].xmlText)#</cfoutput>
<!--- <cfscript>

   for (i = 1; i LTE ArrayLen(myresult); i = i + 1)
        writeoutput(myresult[i].XmlText & "<br>");
</cfscript> --->
<!--- <cfoutput>#tostring(myresult.xmlChildren[0].xmlText)#</cfoutput> --->
