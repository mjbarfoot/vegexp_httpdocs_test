<cfsetting enablecfoutputonly="true">
<cfprocessingdirective suppresswhitespace="true">

<!--- *** REQUEST TYPE HANDLER *** --->
<cfswitch expression="#REQUEST.ACTION.reqType#">
	
	<!--- *** VOID request *** --->
	<cfcase value="void">
		<!---Nothing to do: The request only corresponds to an event and wants nothin back!--->
		<cfcontent type="text/xml" />
		<cfoutput>
		<taconite-root xml:space="preserve">
		</taconite-root>
		</cfoutput>
	</cfcase>
	
	
	<!--- *** TAB REQUEST (TACONITE) *** --->
	<cfcase value="tab">
	<cfcontent type="text/xml" />
		<cfoutput><taconite-root xml:space="preserve">
		<taconite-replace  contextNodeID="content_wrapper" parseInBrowser="true">
		#REQUEST.view.content#
		</taconite-replace>
		 <taconite-execute-javascript parseInBrowser="true">
	        <script type="text/javascript">
	           init();
	           TabAction.setActiveTab("tab#REQUEST.action.tabid#");
	        </script>
	    </taconite-execute-javascript>
		</taconite-root>
	</cfoutput>
	</cfcase>
	
	<!--- *** INFOBAR (TACONITE) *** --->
	<cfcase value="section">
	
	
	</cfcase>
	
	<!--- *** WIDGET (TACONITE) *** --->
	<cfcase value="widget">
	<cfcontent type="text/xml" />
	<cfoutput>
	<taconite-root xml:space="preserve">
	<taconite-#REQUEST.action.nodeAction#  contextNodeID="#REQUEST.action.nodeID#" parseInBrowser="true">
		#REQUEST.view.content#
	</taconite-#REQUEST.action.nodeAction#>
   <taconite-execute-javascript parseInBrowser="true">
       <script type="text/javascript">
       		refresh_init();
		</script>
    </taconite-execute-javascript>
	</taconite-root>
	</cfoutput>
	</cfcase>
	
	
	<!--- *** CUSTOM (TACONITE) *** --->
	<cfcase value="custom">
	<cfcontent type="text/xml" />
	<cfoutput>#REQUEST.view.TaconitePacket#</cfoutput>
	</cfcase>
	
	<!--- *** DEBUG (TACONITE) *** --->
	<cfcase value="debug">
	<cfcontent type="text/xml" />
	<cfoutput>
	<taconite-root xml:space="preserve">
	<taconite-replace  contextNodeID="debugDIV" parseInBrowser="true">
	<cfif APPLICATION.debugMode><div id="debugDIV">
	<table style="width: 300px;">
	<thead />
	<tbody>
	<tr><td width="100px">Moduleid: </td><td>#SESSION.debuginfo.moduleid#</td></tr>	
	<tr><td>Tabid: </td><td>#SESSION.debuginfo.tabid#</td></tr>
	<tr><td>Result: </td><td>#SESSION.debuginfo.status.result#</td></tr>
	<tr><td>Message: </td><td>#SESSION.debuginfo.status.message#</td></tr>
	<tr><td>Last GET: </td><td width="200px"><textarea id="DebugAjaxLastGetInfo" style="width: 200px;">#xmlformat(SESSION.debuginfo.lastRequest)#</textarea></td></tr>
	<tr><td>Ajax GET: </td><td><textarea id="DebugAjaxGetInfo" style="width: 200px;"></textarea></td></tr>
	<tr><td></td><td style="text-align: right"><a href="javascript:void(0)" onclick="document.getElementById('debugDIV').style.display='none';"> [ Hide me ] </a></td></tr>
	<tr><td></td><td style="text-align: right"><a href="#APPLICATION.root#/?reloadApp=777" >Reload App </a></td></tr>
	</tbody>
	</table>
	</div></cfif>
	</taconite-replace>
	</taconite-root>
	</cfoutput>
	</cfcase>	
	
	<!--- *** LOGIN REQUEST *** --->
	<cfcase value="login">
	<cfsetting enablecfoutputonly="false"><cfinclude template="#APPLICATION.root#/views/login.cfm" />
	</cfcase>
	
	<cfcase value="logout">
	<cfsetting enablecfoutputonly="false"><cfinclude template="#APPLICATION.root#/views/login.cfm" />
	</cfcase>
	

	<!--- **** PAGE REQUEST (DEFAULT) *** --->
	<cfdefaultcase>
	<cfsetting enablecfoutputonly="false"><cfinclude template="#APPLICATION.root#/views/default.cfm" />
	</cfdefaultcase>
</cfswitch>
</cfprocessingdirective>