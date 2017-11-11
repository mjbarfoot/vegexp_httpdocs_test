<!--- 
	Component: xwtablecustomfunctions.cfc
	File: /cfc/xwtable/xwtablecustomfunctions.cfc
	Description: Custom functions which can be used for providing output to custom columns
	Author: Matt Barfoot
	Date: 05/04/2006
	Revisions:
	
	19/04/2006: Added notes to hint about parsing passed data/query values to make sure they are XML formatted before adding any XHTML.
	--->
	
<cfcomponent name="customfunctions" output="false" displayname="xwtablecustomfunctions" 
hint="cusom functions are defined here. If a column in a table needs to do something special then a custom function is defined to do the job. 
Custom functions parse any passed bind (query) values to make sure they are XML compliant strings. If they include XHTML, format any bind variables before adding XHTML">

<cfobject component="cfc.couk.clearview-webmedia.xwidget.xwutil" 			name="xwutil">

<cffunction name="emptyFn" access="public" returnType="string" hint="">
<cfscript>
return "";
</cfscript>
</cffunction>

<cffunction name="qsdateformat" access="public" output="false" returnType="string" hint="">
<cfargument name="myDate" type="any" required="true" />
<cfset var ret = ""/>

<cfif isValid("eurodate", ARGUMENTS.myDate) AND ARGUMENTS.myDate neq "">

	<cftry>
	<cfif LSTimeFormat(mydate,"HH:MM TT") neq "00:00 AM">
		<cfset ret='#LSDateFormat(myDate,"dd/mm/yyyy")# #LSTimeFormat(mydate,"HH:MM TT")#' />
	<cfelse>
		<cfset ret='#LSDateFormat(myDate,"dd/mm/yyyy")#' />
	</cfif>
	<cfcatch type="any">
	<cfscript>
	application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Error: function qsdateformat() - could not format date: #ARGUMENTS.mydate# details: #cfcatch.message#");
	</cfscript>
	</cfcatch>
	</cftry>

<cfelseif ARGUMENTS.myDate neq "">
	<cfscript>
	application.applog.write(timeformat(now(), 'h:mm:ss tt') & " Error: function qsdateformat() - not a valid eurodate: #ARGUMENTS.mydate#");
	</cfscript>

</cfif>

<cfreturn ret /> 
</cffunction>

<cffunction name="qsstatus" access="public" output="false" returnType="string" hint="">
<cfargument name="qsa_status" type="string" required="true" />
<cfset var ret = ""/>
<cfswitch expression="#lcase(ARGUMENTS.qsa_status)#">
<cfcase value="new">
	<cfset ret="NEW" />
</cfcase>
<cfcase value="withdrawn">	
	<cfset ret='<span style="color:red">WITHDRAWN</span>' />
</cfcase>
<cfcase value="approved">	
	<cfset ret='<span style="color:##228B22">APPROVED</span>' />
</cfcase>
<cfcase value="qsreview">	
	<cfset ret='<span style="color:##D2691E">QSREVIEW</span>' />
</cfcase>
</cfswitch>
<cfreturn ret /> 

</cffunction>

<cffunction name="getArrow" access="public" returnType="string" hint="">
<cfargument name="myWonum" type="string" required="true" />
<cfscript>
var myLink = '<a id="expand_#ARGUMENTS.myWonum#" href="#cgi.script_name#?#xwutil.parsedQS("",true)#&amp;reqtype=custom&amp;widgetid=xwtableRemote&amp;methodid=getWODetails&amp;paramVal=#ARGUMENTS.myWonum#" title="expand Work Order"><img id="img_#ARGUMENTS.myWonum#" src="#SESSION.view.skins.default.path#arrow-right-9.gif" alt="Expand" /></a>';	
return myLink;
</cfscript>
</cffunction>	

<cffunction name="getHistoryArrow" access="public" returnType="string" hint="">
<cfargument name="myWonum" type="string" required="true" />
<cfscript>
var myLink = '<a id="expand_#ARGUMENTS.myWonum#" href="#cgi.script_name#?#xwutil.parsedQS("",true)#&amp;reqtype=custom&amp;widgetid=xwtableRemote&amp;methodid=getWOHistoryDetails&amp;paramVal=#ARGUMENTS.myWonum#" title="expand Work Order"><img id="img_#ARGUMENTS.myWonum#" src="#SESSION.view.skins.default.path#arrow-right-9.gif" alt="Expand" /></a>';	
return myLink;
</cfscript>
</cffunction>


<cffunction name="getSelectBox" access="public" returnType="string" hint="">
<cfargument name="myWonum" type="string" required="true" />

<cfscript>
var isSelected = SESSION.ob.woSelectList.isSelected(ARGUMENTS.myWonum);	
var myLink = '<input class="chkbox" type="checkbox" id="fldSelect_#ARGUMENTS.myWonum#" value="#ARGUMENTS.myWonum#" #IIF(isSelected, DE('checked="true"'), DE(''))# />';	
return myLink;
</cfscript>
</cffunction>

<cffunction name="getRemoveIcon" access="public" returnType="string" hint="">
<cfargument name="myWonum" type="string" required="true" />
<cfscript>
var myLink = '#myWonum#';
myLink = '<a id="removeWO_#ARGUMENTS.myWonum#" href="javascript:void(0);" title="remove #ARGUMENTS.myWonum#"><img src="#SESSION.view.skins.default.path#icon-remove.gif" alt="remove #ARGUMENTS.myWonum#" /></a>';	
return myLink;
</cfscript>
</cffunction>

</cfcomponent>