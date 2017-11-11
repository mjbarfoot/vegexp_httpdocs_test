<!--- 
	Component: dispatchMsg
	File: /cfc/shop/dispatchMsg.cfc 
	Description: sends Emails
	Author: Matt Barfoot - Clearview Webmedia Limited
	Date: 27/02/2006 for Streammag.com project
	Revisions:

	25/04/2006: Added new parameter msg (struct) and msgtpl (string) to use a cfml template and 
	populate the template based upon the message structure.
	This version introduces dependencies between the msg structure and the template. This is better for template design.
	
--->

<cfcomponent name="dispatchMsg" hint="sends Emails">

<!--- / Object Declarations / --->
<cfscript>
</cfscript>

<cffunction name="sendEmail" access="public" >
	<cfargument name="emlTo" required="true" type="string" />
	<cfargument name="emlFrom" required="true" type="string" />
	<cfargument name="emlSubject" required="true" type="string" />
	<cfargument name="msg" required="true" type="struct" />
   	<cfargument name="tpl" required="true" type="string" />
	<cfargument name="emlCC" required="false" type="string" default="" />

    
<cfscript>
application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Sending email arguments FROM: " & ARGUMENTS.emlFrom & " TO: " & ARGUMENTS.emlTo & " SUBJECT: " & ARGUMENTS.emlSubject);		    
</cfscript>    
    
<cftry>
<cfmail to="#ARGUMENTS.emlTo#" 
        from="#ARGUMENTS.emlFrom#"  
        subject="#ARGUMENTS.emlSubject#" 
        cc="#ARGUMENTS.emlCC#" 
        server = "email-smtp.eu-west-1.amazonaws.com"
        username = "AKIAIRWEPDJDQXQY56EA"
        password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
        port="587"
        useTLS="true"    
        type="html">
	<cfinclude template="#ARGUMENTS.tpl#">
</cfmail>
<cfcatch type="any">
<cfmail to="matt.barfoot@clearview-webmedia.co.uk" from="support@orders.vegetarianexpress.co.uk"  server = "email-smtp.eu-west-1.amazonaws.com"
        username = "AKIAIRWEPDJDQXQY56EA"
        password = "AvijQKLVEq9veHNNi9ANm3VNzbF8dlDUYVWWXohtwQQU"
        port="587"
        useTLS="true"  subject="orders.vegexp - email error" type="html">
	  <cfoutput>
            <!--- and the diagnostic message from the ColdFusion server --->
            <p>#cfcatch.message#</p>
            <p>Caught an exception, type = #CFCATCH.TYPE# </p>
            <p>The contents of the tag stack are:</p>
            <cfloop index = i from = 1 
                    to = #ArrayLen(CFCATCH.TAGCONTEXT)#>
                <cfset sCurrent = #CFCATCH.TAGCONTEXT[i]#>
                <br>#i# #sCurrent["ID"]# 
                    (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) 
                    #sCurrent["TEMPLATE"]#
            </cfloop>

  			<ul>			
			<cfloop collection = "#ARGUMENTS#" item = "key">
	        <li>#key# - </li>
    	    <li>#serialize(StructFind(ARGUMENTS, key))#</li>
			</cfloop>

			<cfdump var="#ARGUMENTS.msg#">
        </cfoutput>
</cfmail>
<cfrethrow/>
</cfcatch>
</cftry>


</cffunction>

</cfcomponent>