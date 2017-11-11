<!--- 
	Filename: /cfc/shopper/breadcrumb.cfc 
	Created by:  Matt Barfoot on 15/04/2006 Clearview Webmedia Limited
	Purpose:  Creates and manages a breadcrumb trail to help shopper find their way around
--->

<cfcomponent name="breadcrumb" displayname="breadcrumb"  output="false" hint="Creates and manages a breadcrumb trail to help shopper find their way around">

<!--- / Object declarations / --->
<cfscript>
departments_do=createObject("component", "cfc.departments.do");
</cfscript>

<cffunction name="init" output="false" access="public">
<cfreturn this> 
</cffunction>


<cffunction name="getBreadCrumbTrail" output="false" access="public" returntype="string">
<cfargument name="breadcrumbtext" required="false" type="string" default="" />

<!--- backwards compatibility hook --->
<cfif NOT isdefined("url.categoryid")>
	<cfset URL.categoryID=0>
</cfif>

<cfxml variable="myBreadCrumbs">
<cfprocessingdirective suppresswhitespace="true">
<cfoutput>
<div id="breadCrumbTrail">
<cfif url.CategoryID neq 0>
	<cfset request.pageTitle = request.tabSelected & XMLFormat(departments_do.getCategoryName(URL.CategoryID)) />
	<a id="breadCrumbTrail-Top" 		href="#cgi.script_name#"	 >#request.tabSelected#</a> /
	<a id="breadCrumbTrail-Category" 	href="#cgi.scipt_name#?CategoryID=#url.CategoryID#&amp;ShowProducts=True">#XMLFormat(departments_do.getCategoryName(URL.CategoryID))#</a> 
    <a id="breadCrumbTrail-Another"     href="#cgi.script_name#">Choose Another Category</a>
<cfelseif isdefined("url.pQ")>
<cfset request.pageTitle = "Search results for " & XMLformat(url.Pq) />
<cfif LEN(URL.Pq) neq 0>
Showing #session.xwtable.results.getVar("sqlquery.recordcount")# results for: #XMLFormat(url.Pq)#
<cfelse>No search specified</cfif>
<cfelseif NOT isdefined("url.pQ") AND session.shopper.prod_filter eq  "ALL" AND FindNoCase("search.cfm", CGI.SCRIPT_NAME) AND NOT FindNoCase("_search.cfm", CGI.SCRIPT_NAME)>
<cfset request.pageTitle = "All " & url.fldProdFilter & "products " />
Viewing ALL #url.fldProdFilter# products 
<cfelse>
	<cfif ARGUMENTS.breadcrumbtext neq "">	
	<cfset request.pageTitle = rereplace(ARGUMENTS.breadcrumbtext, "<(.|\n)*?>","", "ALL") />
	<!--- if a string has been passed to use as the breadcrumb use that --->
	#ARGUMENTS.breadcrumbtext#
	<cfelseif FindNoCase("ShowProducts=true", CGI.QUERY_STRING)>
	<cfset request.pageTitle = "Viewing All #request.tabSelected# Products" />
	Viewing All #request.tabSelected# Products
	 <a id="breadCrumbTrail-Another"     href="#cgi.script_name#">Choose a Category</a>
	<cfelse>
		<!--- generate the breadcrumb trail basedupon the cgi.SCRIPT_NAME --->
		<cfswitch expression=#lcase(cgi.SCRIPT_NAME)#>
		<cfcase value="/search.cfm">
		<cfset request.pageTitle ="Showing All Products" />
		Showing All Products
		</cfcase>
		<cfcase value="/basket.cfm">
		<cfset request.pageTitle ="Shopping Basket" />
		Shopping Basket
		</cfcase>
		<cfcase value="/oldbasket.cfm">
		<cfset request.pageTitle ="Your last shopping basket" />
		Your last shopping basket
		</cfcase>
		<cfcase value="/register.cfm">
		<cfset request.pageTitle ="Account Registration" />
		Account Registration
		</cfcase>
		<cfdefaultcase>
		<cfif NOT isdefined("url.pQ") AND session.shopper.prod_filter neq "ALL" AND FindNoCase("search.cfm", CGI.SCRIPT_NAME) EQ 0>
		<cfset request.pageTitle=session.shopper.prod_filter />
		#session.shopper.prod_filter# 
		</cfif>		
		#request.tabSelected#: View <a class="selectALL" href="#cgi.script_name#?CategoryID=0&amp;ShowProducts=true">All</a> or select a category below:
		<cfset request.pageTitle=request.tabSelected &  ":" & "View All or select a category below" />
		</cfdefaultcase>
		</cfswitch>
	</cfif>
</cfif>
</div>
</cfoutput>
</cfprocessingdirective>
</cfxml>

<cfset myBreadCrumbs=replace(toString(myBreadCrumbs), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<!--- <cfset myBreadCrumbs=ReReplace(myBreadCrumbs, "[\r\n]+", "#Chr(10)#", "ALL")> --->
<cfset myBreadCrumbs=ReReplace(myBreadCrumbs, "[\r]+", "", "ALL")>
<cfset myBreadCrumbs=ReReplace(myBreadCrumbs, "[\n]+", "", "ALL")>
<cfset myBreadCrumbs=reReplace(myBreadCrumbs, ">[[:space:]]+#chr(13)#<", "ALL")>

<cfreturn myBreadCrumbs />

</cffunction>

</cfcomponent>