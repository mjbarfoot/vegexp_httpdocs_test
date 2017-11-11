<!--- 
	Filename: /cfc/shopper/comments_do.cfc ("Lists, adds, edits, deletes and approves comments")
	Created by:  Matt Barfoot on 4/08/2006 Clearview Webmedia Limited
	Purpose:  Provides comments functionality for VE website
--->

<cfcomponent output="false">

<cfscript>
THIS.name			= "comments_do";
THIS.displayname	= "comments_do";
THIS.hint			= "Lists, adds, edits, deletes and approves comments in the database";
</cfscript>

<cffunction name="init" access="public" output="false" returntype="any" hint="initiates component">
<cfscript>
//return the Object
return THIS;
</cfscript>
</cffunction>

<cffunction name="getComments" access="public" output="false" returntype="query" hint="lists comments">
<cfargument name="about" required="false" type="string" default="" hint="what the comments is about" />
<cfargument name="includeDraft" required="false" type="boolean" default=false hint="include draft comments in the list" />

	<cfquery name="QryGet"  datasource="#APPLICATION.dsn#">
	SELECT ID, yourName, emailAddress, commentTitle, comment, commentStatus, commentDate, commentTime
	FROM tblComment
	<cfif ARGUMENTS.about neq "">
	WHERE commentAbout =  '#ARGUMENTS.about#'
	</cfif>
	<cfif NOT ARGUMENTS.includeDraft>
	AND commentStatus = 1
	</cfif>
	</cfquery>

<cfreturn QryGet>
</cffunction>

<cffunction name="updateComment" access="public" output="false" returntype="integer" hint="counts comments">
<cfargument name="FORM" required="true" type="STRUCT"  />

	<cfquery name="QryUpdate"  datasource="#APPLICATION.dsn#">
	UPDATE tblComment 
	SET yourName = '#ARGUMENTS.FORM.yourName#', 
		emailAddress = '#ARGUMENTS.FORM.emailAddress#',  
		commentTitle = '#ARGUMENTS.FORM.commentTitle#',  
		comment = '#ARGUMENTS.FORM.comment#',  
		commentAbout = '#ARGUMENTS.FORM.commentAbout#',  
		commentStatus = #ARGUMENTS.FORM.commentStatus#, 
		commentDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ARGUMENTS.FORM.commentDate#">,  
		commentTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#ARGUMENTS.FORM.commentTime#">
	WHERE ID = #ARGUMENTS.FORM.ID#


	</cfquery>

<cfreturn true />
</cffunction>

<cffunction name="insertComment" access="public" output="false" returntype="any" hint="adds comments">
<cfargument name="FORM" 	required="true" type="struct" />

<cftry>
	<cfquery name="QryUpdate"  datasource="#APPLICATION.dsn#">
	INSERT INTO tblComment 
	(yourName, emailAddress, commentTitle, comment, commentAbout, commentStatus, commentDate, commentTime)
	VALUES (
	'#ARGUMENTS.FORM.yourName#', 
	'#ARGUMENTS.FORM.emailAddress#',  
	'#ARGUMENTS.FORM.commentTitle#',  
	'#ARGUMENTS.FORM.comment#',  
	'#ARGUMENTS.FORM.commentAbout#',
	0, 
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),'dd/mm/yyyy')#">,  
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#timeformat(now(),'H:MM TT')#">

	)
	</cfquery>
<cfreturn true />
<cfcatch type="database">
<cfreturn cfcatch.message>
</cfcatch>
</cftry>
</cffunction>

<cffunction name="deleteComment" access="public" output="false" returntype="booelean" hint="adds comments">

	<cfquery name="QryUpdate"  datasource="#APPLICATION.dsn#">
	DELETE FROM  tblComment 
	WHERE WHERE ID =# ARGUMENTS.FORM.ID#
	</cfquery>


<cfreturn true />
</cffunction>

<cffunction name="countComments" access="public" output="false" returntype="integer" hint="adds comments">
<cfargument name="about" required="false" type="string" default="" hint="what the comments is about" />
<cfargument name="includeDraft" required="false" type="boolean" default=false hint="include draft comments in the list" />

<cfquery name="QryCount"  datasource="#APPLICATION.dsn#">
	SELECT count(ID) as "reccount"
	FROM tblComment
	<cfif ARGUMENTS.about neq "">
	WHERE commentAbout =  '#ARGUMENTS.about#'
	</cfif>
	<cfif NOT ARGUMENTS.includeDraft>
	AND commentStatus = 1
	</cfif>	
</cfquery>

<cfreturn QryCount.reccount>
</cffunction>


</cfcomponent>