<cfprocessingdirective suppresswhitespace="true">

<cfif NOT isdefined("url.complete")>
	<cfscript>
	//get the breadcrumb trail
	shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("processing...");
	</cfscript>
	<cfxml variable="myContent">
	<div id="productListWrapper">
		<div id="productList">
			<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
			<p><strong>Please wait</strong></p>
			<p>We are processing your order<br />
			This process may take up to a few minutes<br />
			Please do not Reload, press F5 or leave this page until the process is complete
			<img id="ordproc" src="/resources/processing.gif" alt="pc communicating with database" />
			</p>	
		</div>
	</div>	
	</cfxml>
<cfelse>
	<cfscript>
	//get the breadcrumb trail
	shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("order complete...");
	</cfscript>
	<cfxml variable="myContent">
	<div id="productListWrapper">
		<div id="productList">
			<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
			<p><strong>Thank you</strong><br />
			Your order has now been processed<br />
			</p>	
		</div>
	</div>	
	</cfxml>
</cfif>


<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>

<cfinclude template="/views/default.cfm">

<cfif NOT isdefined("url.complete")>
	<cfflush>
    <cfset initialTime = now()>
	<cfloop condition="dateDiff('s', initialTime, now()) lt 5"></cfloop>			
	<meta http-equiv="Refresh" content="0;url=/testflush.cfm?complete=true">
</cfif>	
</cfprocessingdirective>