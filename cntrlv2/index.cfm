<cfsetting enablecfoutputonly="true">
<cfprocessingdirective suppresswhitespace="true">

<!--- *** REQUEST TYPE HANDLER *** --->
<cfswitch expression="#lcase(URL.reqtype)#">
	
	<!--- *** TAB REQUEST (TACONITE) *** --->
	<cfcase value="tab">
	<cfcontent type="text/xml" />
		<cfoutput><taconite-root xml:space="preserve">
		<taconite-replace  contextNodeID="contentInfo" parseInBrowser="true">
		#REQUEST.view.info#
		</taconite-replace>
		<taconite-replace  contextNodeID="content" parseInBrowser="true">
		<div id="content">
		#REQUEST.view.content#
		</div>
		</taconite-replace>
		 <taconite-execute-javascript parseInBrowser="true">
	        <script type="text/javascript">
	           ALINK.init();
	           TabAction.setActiveTab("tab#REQUEST.action.tabid#");
	        </script>
	    </taconite-execute-javascript>
		</taconite-root>
	</cfoutput>
	</cfcase>
	
	<!--- *** INFOBAR (TACONITE) *** --->
	<cfcase value="infobar">
	
	
	</cfcase>
	
	<!--- *** WIDGET (TACONITE) *** --->
	<cfcase value="widget">
	<cfcontent type="text/xml" />
	<cfoutput>
	<taconite-root xml:space="preserve">
	<taconite-#REQUEST.action.nodeAction#  contextNodeID="#REQUEST.action.nodeID#" parseInBrowser="true">
	<!--- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />  --->
		#REQUEST.view.content#
	</taconite-#REQUEST.action.nodeAction#>
   <taconite-execute-javascript parseInBrowser="true">
       <script type="text/javascript">
       ALINK.init();
       xw.init();
		</script>
    </taconite-execute-javascript>
	</taconite-root>
	</cfoutput>
	</cfcase>
	
	<!--- **** PAGE REQUEST (DEFAULT) *** --->
	<cfdefaultcase>
	<cfsetting enablecfoutputonly="false"><cfinclude template="/views/cntrl/default_v3.cfm" />
	</cfdefaultcase>
</cfswitch>
</cfprocessingdirective>