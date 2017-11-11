<!--- 
	Filename: /cfc/shopper/shopfilter.cfc 
	Created by:  Matt Barfoot on 15/04/2006 Clearview Webmedia Limited
	Purpose:  Tells the shopper which product filter they have selected and allows them to change it
--->

<cfcomponent name="shopfilter" displayname="shopfilter"  output="false" hint="Tells the shopper which product filter they have selected and allows them to change it">

<!--- / Object declarations / --->
<cfscript>
</cfscript>

<cffunction name="init" output="false" access="public">

<cfreturn this> 

</cffunction>

<cffunction name="getFilterInfo" output="false" returntype="string">

<cfset var filterPos=ListContains(cgi.QUERY_STRING, "fldProdFilter=", "&")>
<cfset var qS=""/>
<cfset var filterList="All,Organic,Vegan,GlutenFree">

<cfif isdefined("url.pq")>
<cfset qs = "pQ=" & url.pq />
</cfif>

<cfif isdefined("url.categoryid")>
	<cfif len(qS)>
		<cfset qS = qS & "&amp;categoryID=#URL.CategoryID#"/>
	<cfelse>
		<cfset qS="categoryID=#URL.CategoryID#"/>
	</cfif>	
<!--- <cfset qs= qs & IIF(qs neq "", DE("&amp;"), "") & "categoryID=" & url.categoryID /> --->
</cfif>

<cfif isdefined("url.showProducts")>
	<cfif len(qS)>
		<cfset qS = qS & "&amp;showProducts=true"/>
	<cfelse>
		<cfset qS = "&amp;showProducts=true"/>	
	</cfif>	

<!--- <cfset qs= qs & IIF(qs neq "", DE("&amp;"), "") & "showProducts=true"/> --->
</cfif>

<!--- remove the product filter from the query string 
<cfif filterPos neq 0>
<cfset qS=ListDeleteAt(cgi.QUERY_STRING,filterPos,"&")> 
</cfif>--->



<cfxml variable="myFilter">
<cfoutput>
<div id="shopFilterDisplayBar">
<cfif session.shopper.prod_filter neq "All">
<span style="padding-right: 2em;">
Filtering by: <span id="shopFilterDisplayBar-#session.shopper.prod_filter#">#UCASE(session.shopper.prod_filter)#</span>
</span>
</cfif>
Filter by:
<cfloop list="#filterList#" index="listEl">
<cfif listEl neq session.shopper.prod_filter>
<a id="shopFilterDisplayBar-#listEl#" 	href="#cgi.scipt_name#?#qs#&amp;fldProdFilter=#listEl#">#UCASE(ListEl)#</a> /
</cfif>
</cfloop>
<cfif StructKeyExists(URL, "showProducts") OR FindNoCase("favourites.cfm", CGI.SCRIPT_NAME) neq 0  OR FindNoCase("search.cfm", CGI.SCRIPT_NAME) neq 0>
<div id="shopFilterSortBy">
		<cfif isdefined("URL.tblSort")>Sorting by: <strong>#URL.tblSort#<cfif StructKeyExists(URL, "tblSortOrder")>, #URL.tblSortOrder# </cfif></strong> <a style="padding-left: 1em;" id="sortHelp" href="javascript:void(0);" title="Sorting help">Help: <cfelse><a id="sortHelp" href="javascript:void(0);" title="Sorting help">Sorting Help:  </cfif><img src="#session.shop.skin.path#icon_help.png" /></a> 	
		<div class="helpHintWrapper" id="sortHelpWrapper">
		<div class="helpHintcontent" id="sortHelpContent">
			Click a column heading to sort products either ascending or descending.<br />
			<span class="activeColumn">Bold Coloured Headings</span> can be used to sort<br />
			<span class="unactiveColumn">Bold Black Headings</span> mean this column is 'non sortable'<br />
			<br /><br />
			<a id="closeHelp" href="javascript:void(0)">close</a>
		</div>
		</div>
</div>
</cfif>	
</div>
</cfoutput>
</cfxml>

<cfset myFilter=replace(ToString(myFilter), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myFilter, "[\r\n]+", "#Chr(10)#", "ALL")>
</cffunction>

</cfcomponent>