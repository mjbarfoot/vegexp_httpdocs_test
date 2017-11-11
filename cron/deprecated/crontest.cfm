<cffunction name="postRequest" output="false" returntype="struct" access="public">
<cfargument name="soapRequest" type="string" required="true">
<cfargument name="sageWSMethod" type="string" required="true">

	<cfhttp url="http://213.210.52.169/accountsWS/AccountsIntegration.asmx" GetAsBinary="no" charset="utf-8" method="post" timeout="90">
		<cfhttpparam name="SOAPAction" type="header"  value="http://www.aspidistra.com/WebService/AccountsIntegration/#sageWSMethod#">
		<cfhttpparam name="xml" 	   value="#ARGUMENTS.soapRequest#" type="xml" />
	</cfhttp>  


	<!---< <cfhttp url="http://213.210.52.169/accountsWS/AccountsIntegration.asmx/#ARGUMENTS.sageWSMethod#"
			method="post">
	<cfhttpparam name="xml" value="#ARGUMENTS.soapRequest#" type="xml" />  
	</cfhttp>	--->


<cfreturn cfhttp />

</cffunction>

<cffunction name="generateSOAP" output="false" returntype="string" access="private">
<cfxml variable="soap">
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetProductListFull xmlns="http://www.aspidistra.com/WebService/AccountsIntegration/" />
  </soap:Body>
</soap:Envelope>
<!--- <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:acc="http://www.aspidistra.com/WebService/AccountsIntegration/">
   <soapenv:Body>
      <acc:GetStockCategoryList/>
   </soapenv:Body>
</soapenv:Envelope> --->
</cfxml>

<cfreturn toString(soap)>
</cffunction>

<cfset response = postRequest(generateSoap(), "GetProductListFull") />
<cfoutput>
response.charSet: #response.charSet# <br />
response.errorDetail: #response.errorDetail# <br />
response.fileContent: #response.fileContent# <br />
response.header: #response.header# <br />
response.mimeType: #response.mimeType# <br />
response.responseHeader: <cfloop collection="#response.responseHeader#" item="key">
						#response.responseHeader[key]# <br />
						</cfloop>
response.statusCode: #response.statusCode# <br />
response.text: #response.text# <br /> 

    <!---    <form target="_blank" action='http://213.210.52.169/accountsws/AccountsIntegration.asmx/GetStockCategoryList' method="POST">                      
                        
                          <table cellspacing="0" cellpadding="4" frame="box" bordercolor="dcdcdc" rules="none" style="border-collapse: collapse;">
                          
                        
                        <tr>
                          <td></td>
                          <td align="right"> <input type="submit" value="Invoke" class="button"></td>

                        </tr>
                        </table>
                      

          </form> --->
</cfoutput>

