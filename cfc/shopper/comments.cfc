<!--- 
	Filename: /cfc/shopper/comments.cfc ("Lists, adds, edits, deletes and approves comments")
	Created by:  Matt Barfoot on 4/08/2006 Clearview Webmedia Limited
	Purpose:  Provides comments functionality for VE website
--->

<cfcomponent output="false">

<cfscript>
THIS.name			= "comments";
THIS.displayname	= "comments";
THIS.hint			= "Lists, adds, edits, deletes and approves comments";
</cfscript>

<cffunction name="init" access="public" output="false" returntype="any" hint="initiates component">
<cfscript>
VARIABLES.comments_do = createObject("component","cfc.shopper.comments_do").init();
//return the Object
return THIS;
</cfscript>
</cffunction>

<cffunction name="do" access="public" output="false" returntype="any" hint="lists comments">
<cfargument name="action" 	required="true" type="string" />
<cfargument name="FORM" 	required="true" type="struct" />

<cfscript>
var isSuccessful="";
switch (lcase(ARGUMENTS.action)) {
case "add": 			isSuccessful=VARIABLES.comments_do.insertComment(ARGUMENTS.FORM);	
						;
					break;	
default: 				;	
}


// return true or an error message
return 	isSuccessful;
</cfscript>

</cffunction>


<cffunction name="list" access="public" output="false" returntype="string" hint="lists comments">

</cffunction>

<cffunction name="getCount" access="public" output="false" returntype="integer" hint="counts comments">

</cffunction>

<cffunction name="add" access="public" output="false" returntype="string" hint="adds comments">
<cfargument name="result" required="false" type="string" />
<cfargument name="FORM"   required="false" type="struct" />

<cfscript>
//  vars

</cfscript>

<cfxml variable="myContent">
<cfoutput>
						<div id="commentFormContainer">
							<cfform id="frmComment" name="frmComment" action="comment.cfm" method="post" format="html">
							<p style="margin-bottom:1em;"><cfif isdefined("ARGUMENTS.result")>#ARGUMENTS.result#<cfelse>Add your comment</cfif></p>
							<fieldset>
								 <cfif isdefined("URL.refURL")>
								 <input type="hidden" name="commentAbout" id="commentAbout" value="#trim(lcase(URL.refURL))#" />	
								 <cfelse>
								 <input type="hidden" name="commentAbout" id="commentAbout" value="#IIf(IsDefined('Form.commentAbout'), Evaluate(DE('Form.commentAbout')), DE(''))#" />	
								 </cfif>
								 <p>
								    <label for="commentTitle">Title: *</label>
								    <input type="text" name="commentTitle" id="commentTitle" required="true" message="Please enter your company name" value="#IIf(IsDefined('Form.commentTitle'), Evaluate(DE('Form.commentTitle')), DE(''))#" />
								</p>
								 <p>
								     <label for="comment">Your Comment: *</label>
								     <textarea name="comment" id="comment" required="true" validate="noblanks" message="Please enter a comment">#IIf(IsDefined('Form.comment'), Evaluate(DE('Form.comment')), DE(' '))#</textarea>
							    </p>
							    <p>
									<label for="yourName">Your Name: *</label>
								    <input type="text" class="med" name="yourName" id="yourName"  required="true" message="Please enter your name" value="#IIf(IsDefined('Form.yourName'), Evaluate(DE('Form.yourName')), DE(''))#" />
								</p>
								<p>
								    <label for="emailAddress">Email Address: </label>
								    <input type="text" class="med" name="emailAddress" id="emailAddress" value="#IIf(IsDefined('Form.emailAddress'), Evaluate(DE('Form.emailAddress')), DE(''))#" />
								</p>
								</fieldset>
								<p style="text-align: center">
								<input type="submit" name="frmSubmit" value="Submit" /> 
								</p>
								</cfform>				
							</div>						
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>
</cffunction>

<cffunction name="remove" access="public" output="false" returntype="booelean" hint="adds comments">

</cffunction>

<cffunction name="thanks" access="public" output="false" returntype="string" hint="adds comments">

<cfscript>
//  vars

</cfscript>

<cfxml variable="myContent">
<cfoutput>
<div id="commentFormContainer">
	<div>
		<p><img src="/resources/ok.gif"  alt="Message Sent" style="float:left;padding: 6px 6px 6px 6px;" /></p>
	</div>
	<div style="margin-left: 80px; font-size: 0.9em;">
	<p style="margin-bottom: 1em;"><strong>Thanks for your comments.</strong></p>
	<p style="margin-bottom: 4em;">A member of staff will contact you if you submitted a question. Remember, if you need to contact us urgently you can always call us on 01923 294714. Thank you.</p>	
	</div>						
</div>						
</cfoutput>
</cfxml>

<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=ReReplace(content, "[\r\n]+", "#Chr(10)#", "ALL")>

<cfreturn  reReplace(content, ">[[:space:]]+#chr( 13 )#<", "ALL")>
</cffunction>




<cffunction name="edit" access="public" output="false" returntype="booelean" hint="adds comments">

</cffunction>

<cffunction name="approve" access="public" output="false" returntype="booelean" hint="adds comments">

</cffunction>

</cfcomponent>