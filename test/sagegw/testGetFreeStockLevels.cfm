<!---
loop through query in blocks of 10
create an array 
pass the array to sage method
decode the returned SOAP into xml
create two dimension array with stockcode 
send the stockcode to update
--->

	<cffunction name="getXML" returntype="xml" access="public">
		<cfargument name="x" type="string" required="true" />
		<cfset var myXmlDoc = replace(ARGUMENTS.x,'<?xml version="1.0" encoding="utf-8"?>','')/>
		<cfxml variable="r">
			<cfoutput>#myXmlDoc#</cfoutput>
		</cfxml>
		<cfreturn r/>
	</cffunction>


    <cffunction name="getStock" returntype="query" access="public" hint="put things here that you want to run before each test">
			<cfquery name="q" datasource="#APPLICATION.dsn#">
				SELECT STOCKCODE FROM tblProducts
				WHERE STOCKCODE LIKE 'D%' 
				<!---STOCKQUANTITY < 50 --->
			</cfquery>
			
			<cfreturn q />
    </cffunction>
	
	
	
	<cfscript>
		sagegw = createObject("component","cfc.sagegw.sageWSGW").init();
		//BAGPOL10X15
		q = getStock();
		a = arraynew();
		
		for (i=1; i lte q.recordcount; i=i+1) {
				a[i] = q["stockcode"][i];
		}
		

		result = sagegw.getFreeStockLevels(a);
		xmldoc = getXML(result);
		
		//writeOutput(xmlformat(xmldoc));
		
		xmlElements = xmlSearch(xmlDoc, "//*/*/*/*");
		b = arraynew();

		for (i = 1; i LTE ArrayLen(a); i = i + 1) {
		b[i][1]=a[i];
		b[i][2]= xmlElements[i+1].XmlText;
			writeoutput("stockcode: " & b[i][1] & "  quantity is:" & b[i][2] & "<br>");
		}  
		
		
		//writeOutput("number of xmlelements is:" & arraylen(xmlelements) & "query record count is " & q.recordcount & "<br/>");
		//writeOutput("number of stock quantities queried was" & arraylen(a) & "<br/>");
		
		/* for (i = 1; i LTE ArrayLen(a); i = i + 1) {
       	 	writeoutput("stockcode: " & a[i] & "  quantity is:" & xmlElements[i+1].XmlText & "<br>");
		}*/
		
		//writeOutput("One extra element in the XML ... <br/>");
		//writeOutput(xmlformat(serialize(xmlElements)));
	</cfscript>