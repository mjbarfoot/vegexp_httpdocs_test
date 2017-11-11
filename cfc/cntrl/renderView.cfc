<!--- 
	Filename: 	 /cfc/cntrl/renderView.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     creates XML to be consumed by Spry
	Date: 
	Revisions:
--->

<cfcomponent output="false" name="renderView" displayname="renderView" hint="reates XML to be consumed by Spry">


<!--- *** getTabs: SPRY interface *** --->
<cffunction name="getTabs" output="true" returntype="void" access="remote">
<cfargument name="moduleid" required="true" type="string" />
<cfcontent type="text/xml">
<cfoutput>#generateTabs(ARGUMENTS.moduleid)#</cfoutput>
</cffunction>


<!--- *** generateTabs: XML *** --->
<cffunction name="generateTabs" output="false" returntype="string" access="private">
<cfargument name="moduleid" required="true" type="string" />

<cfsavecontent variable="tabsxml">
<cfoutput>
<cfswitch expression="#lcase(ARGUMENTS.moduleid)#">
<cfcase value="sage">
<tabs>
	<tab>
		<name>Summary</name>
	</tab>
	<tab>
		<name>Settings</name>
	</tab>
	<tab>
		<name>Tests</name>
	</tab>
</tabs>
</cfcase>
<cfcase value="content">
<tabs>
	<tab>
		<name>Categories</name>
	</tab>
	<tab>
		<name>Recipes</name>
	</tab>
	<tab>
		<name>Offers</name>
	</tab>
	<tab>
		<name>Pages</name>
	</tab>
</tabs>
</cfcase>
<cfdefaultcase>
<tabs>
	<tab>
		<name>Welcome</name>
	</tab>
	<tab>
		<name>Help</name>
	</tab>
</tabs>
</cfdefaultcase>
</cfswitch>
</cfoutput>
</cfsavecontent>
<cfreturn tabsxml />
</cffunction>

<cffunction name="getInfoBar" output="true" returntype="void" access="remote">
<cfargument name="moduleid" required="true" type="string" />
<cfargument name="tabid" required="false" type="string" default="" />
<cfargument name="elementid" required="false" type="string" default="" />

<!---if no tab has been clicked yet, find the default tab--->
<cfif ARGUMENTS.tabid eq "">
<cfset ARGUMENTS.tabid  = getDefaultTabName(ARGUMENTS.moduleid) />
</cfif>

<cfcontent type="text/xml" /> 
<cfoutput>
<cfswitch expression="#lcase(ARGUMENTS.elementid)#">
	<cfcase value="ack">
	</cfcase>
	<cfdefaultcase>
	<content>
	<item>
	<![CDATA[<span id="breadcrumb">> <a title="#ARGUMENTS.moduleid#" href="index.cfm?moduleid=#ARGUMENTS.moduleid#">#UCASE(ARGUMENTS.moduleid)#</a> -> <a href="index.cfm?moduleid=#ARGUMENTS.moduleid#&tabid=#ARGUMENTS.tabid#">#UCASE(ARGUMENTS.tabid)#</a></span>]]>
	</item>
	</content>
	</cfdefaultcase>
</cfswitch>
</cfoutput>
</cffunction>



<cffunction name="getContent" output="true" returntype="void" access="remote">
<cfargument name="moduleid" required="true" type="string" />
<cfargument name="tabid" required="false" type="string" default="" />
<cfargument name="action" required="false" type="string" default="" />
<cfargument name="debug" required="false" type="boolean" default="false" />
<cfset var contentRequestor = createObject("component", "cfc.cntrl.event").init() />
<!---if no tab has been clicked yet, find the default tab--->
<cfif ARGUMENTS.tabid eq "">
<cfset ARGUMENTS.tabid  = getDefaultTabName(ARGUMENTS.moduleid) />
</cfif>

<!---remove spaces so they correspond to actual methods--->
<cfset ARGUMENTS.tabid = Replace(ARGUMENTS.tabid, " ", "", "ALL") />

<cfif ARGUMENTS.debug>
	<cfoutput>#contentRequestor.requestXML(ARGUMENTS.moduleid, ARGUMENTS.tabid)#</cfoutput>
<cfelse>
	<cfcontent type="text/xml" /> 
	<cfoutput>
	 <content>
		<item>	 
		<![CDATA[
		#contentRequestor.requestXML(ARGUMENTS.moduleid, ARGUMENTS.tabid)#
	 	]]>
		</item>
	</content>	 
	</cfoutput>
</cfif>

</cffunction>




<cffunction name="getDefaultTabName" output="false" returntype="string" access="private">
<cfargument name="moduleid" required="true" type="string" />

<cfset var myTabs = generateTabs(ARGUMENTS.moduleid)/>
<cfset var myTabsXML = XMLParse(myTabs) />
<cfset var myTabNames = XmlSearch(myTabsXML, "/tabs/tab/name") />
<cfreturn myTabNames[1].xmlText />
</cffunction>

</cfcomponent>