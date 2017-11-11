<!--- 
	Component: xwtable_factory.cfc
	File: xwtable_factory.cfc
	Description: Builds an XHTML 1.0 Strict table based upon the table properties
	Author: Matt Barfoot
	Date: 02/04/20006
	Revisions:
	--->
	
<cfcomponent name="xwtable_factory" hint="xwtable_factory" output="false">	

<!--- / Object declarations / --->
<cfscript>
xwutil=createObject("component", "#APPLICATION.xWidget.path#.xwutil");
xwcustom=createObject("component", "#APPLICATION.xWidget.path#.xwcustomfunctions");
</cfscript>


<!--- constructor --->
<cffunction name="init" access="public" output="false" hint="initialises variables">
<cfargument name="tblname" required="true" type="string" />
<cfscript>
variables.tblname 			 =  arguments.tblname;
variables.parsedQueryString	 =	request.xwtable.getValue(arguments.tblname, "queryString_prepend") & xwutil.parsedQS(request.xwtable.getValue(arguments.tblname, "allowedParams"), true);

variables.myClass			 =  request.xwtable.getValue(arguments.tblname, "class");
variables.myWidth			 =  request.xwtable.getValue(arguments.tblname, "Width");
variables.myColWidths		 =  request.xwtable.getValue(arguments.tblname, "ColWidths");
variables.myAlignment		 =  request.xwtable.getValue(arguments.tblname, "alignment");

//set the URL for which links should point at
variables.myURL 				= request.xwtable.getValue(arguments.tblname, "URL");

// navigation
variables.showNextofNtext			=  request.xwtable.getValue(arguments.tblname, "showNextofNtext");
variables.myShowNavAtTop	 		=  request.xwtable.getValue(arguments.tblname, "ShowNavAtTop");
variables.myShowNavAtBottom  		=  request.xwtable.getValue(arguments.tblname, "ShowNavAtBottom");
variables.myFooterNavStyle				=  request.xwtable.getValue(arguments.tblname, "footerNavStyle");
variables.myShowFooter				=  request.xwtable.getValue(arguments.tblname, "ShowFooter");
variables.myShowLastRowBottomBorder = request.xwtable.getValue(arguments.tblname, "showLastRowBottomBorder");
variables.myEnableFilter			= request.xwtable.getValue(arguments.tblname, "EnableFilter");

// these variables may be used directly in the xml and need formatting accordingly
variables.mySummary  		 =  xmlformat(request.xwtable.getValue(arguments.tblname, "summary"));
variables.myCaption  		 =  xmlformat(request.xwtable.getValue(arguments.tblname, "caption"));
variables.myShowCaption  	 =  request.xwtable.getValue(arguments.tblname, "showcaption");
variables.myColumnNameList	 =  xmlformat(request.xwtable.getValue(arguments.tblname, "ColumnNameList")); 

variables.myColumnFormatList 		=  request.xwtable.getValue(arguments.tblname, "ColumnFormatList");	
variables.myColumnTypeList	 		=  request.xwtable.getValue(arguments.tblname, "ColumntypeList");	
variables.myQueryColumnList  		=  request.xwtable.getValue(arguments.tblname, "QueryColumnList");	
variables.myQueryColumnBindList  	=  request.xwtable.getValue(arguments.tblname, "QueryColumnBindList");	

variables.myColumnShowHideTitleList =  request.xwtable.getValue(arguments.tblname, "ColumnShowHideTitleList");	
variables.myQueryColumnPrimaryKey	=  request.xwtable.getValue(arguments.tblname, "QueryColumnPrimaryKey");	
variables.myCustomColumnValueList	=  request.xwtable.getValue(arguments.tblname, "CustomColumnValueList");	
variables.myCustomColumnTypeList	=  request.xwtable.getValue(arguments.tblname, "CustomColumnTypeList");	
variables.columnSortable			=  request.xwtable.getValue(arguments.tblname, "columnSortable");	

variables.myFormAction		 =  variables.myURL & "?" & variables.parsedQueryString;
variables.myWhereCol 		 =  request.xwtable.getValue(arguments.tblname, "wherecol");
variables.myWhereClause 	 =  request.xwtable.getValue(arguments.tblname, "whereClause");
variables.myCurrentPage		 =  request.xwtable.getValue(arguments.tblname, "CurrentPage");
variables.myTotalPages		 =  request.xwtable.getValue(arguments.tblname, "totalpages");
variables.myRecordCount 	 =  request.xwtable.getValue(arguments.tblname, "sqlquery.RecordCount"); 
variables.myStartRow 		 =  request.xwtable.getValue(arguments.tblname, "StartRow"); 
variables.myEndRow 			 =  request.xwtable.getValue(arguments.tblname, "EndRow"); 	
variables.myRowsPerPage		 =  request.xwtable.getValue(arguments.tblname, "rowsPerPage"); 
variables.myCFCUrl			 =  request.xwtable.getValue(arguments.tblname, "CFCUrl"); 
variables.mySqlQuery		 =  request.xwtable.getQuery(arguments.tblname, "sqlquery");

variables.linkFirstRecord	 =	variables.myURL & "?" & variables.parsedQueryString & "&amp;tblchangepg=first&amp;widgetID=#variables.tblname#";
variables.linkPrevRecord	 =	variables.myURL & "?" & variables.parsedQueryString & "&amp;tblchangepg=prev&amp;pageid=#variables.myCurrentPage#&amp;widgetID=#variables.tblname#";
variables.linkNextRecord	 =	variables.myURL & "?" & variables.parsedQueryString & "&amp;tblchangepg=next&amp;pageid=#variables.myCurrentPage#&amp;widgetID=#variables.tblname#";
variables.linkLastRecord	 =	variables.myURL & "?" & variables.parsedQueryString & "&amp;tblchangepg=last&amp;widgetID=#variables.tblname#";
variables.linkReset			 =	variables.myURL & "?" & variables.parsedQueryString & "&amp;tblreset=true";

variables.myDateFormat		 =  request.xwtable.getValue(arguments.tblname, "DateFormat");
variables.myTimeFormat		 =  request.xwtable.getValue(arguments.tblname, "TimeFormat");
return this;
</cfscript>
</cffunction>

<cffunction name="makeTable" access="public" output="false" hint="returns XHTML1.0 table" returntype="string">
<cfxml variable="myTable"> 
<cfoutput>
<form id="#variables.tblname#" action="#myFormAction#" method="post" style="width: #variables.myWidth#">
<cfif VARIABLES.showNextofNtext><div class="#myClass#_nextofn">
<cfoutput>Showing <span class="txtBlue">#variables.myStartRow#</span> to <span class="txtBlue">#variables.myEndRow#</span> of <span class="txtBlue">#variables.mySqlQuery.recordcount#</span> records</cfoutput> 
</div></cfif>
<table id="tbl#variables.tblname#" class="#myClass#" style="width: #variables.myWidth#" summary="#mySummary#">
<cfif variables.myShowCaption eq "Yes"><caption>#variables.myCaption#</caption></cfif>
#getHeader()#
#getBody()#
</table>
</form>
</cfoutput>
</cfxml> 

<cfset myTable=ReReplace(myTable, "[[:space:]\t]{2,}", "", "ALL")>
<cfset myTable=ReReplace(myTable, "</tr>", "</tr>#chr(13)##chr(10)#", "ALL")>
<cfset myTable=ReReplace(myTable, "</td>", "</td>#chr(13)##chr(10)#", "ALL")>
<cfreturn replace(ToString(myTable), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cffunction>

<cffunction name="getTableNav" access="private" output="false" returntype="string">
<cfargument name="prepend_to_id" required="true" type="string" />

<cfxml variable="TableNav">
<cfoutput>
			<table id="#arguments.prepend_to_id#-nav">
				<tbody>
					<tr id="#arguments.prepend_to_id#-tblNav">
						<td class="posleft">
							<cfif variables.myEnableFilter AND lcase(ARGUMENTS.prepend_to_id eq "head")>
							<span class="tblfilter">
								<cfif variables.myWhereCol neq "" and variables.myWhereClause neq "">
								<span class="filterActive">Filter Active:</span>
								<cfelse>
								Filter:
								</cfif>
								<a title="lhs: show the table column filter" id="showFilter" name="showFilter" href="##">show</a>
								<span class="txt_divider">|</span>
								<a title="lhs: close and clear the filter" id="hideFilter" name="hideFilter" href="##">clear</a>
							</span>
							</cfif>	
						</td>
						<td class="posCenter">
						<span class="recordnav">
							<!--- Go to first page --->
							<cfif variables.myCurrentPage neq 1>
 							<a title="Move to first set of records" href="#variables.linkFirstRecord#">&lt;&lt; first</a>
 							<cfelse>
 							<span>&lt;&lt; first</span>
 							</cfif>
 							<!--- Go to previous page --->
 							<cfif variables.myCurrentPage gt 1>
 							<a title="Show previous set of #variables.myrowsPerPage# records" href="#variables.linkPrevRecord#"> &lt; prev</a>	
 							<cfelse>
 							<span>&lt; prev</span>							
 							</cfif>
 						</span>
						<span class="txt_divider">|</span>
						<cfif variables.myRecordCount neq 0>
								 Rows: #variables.myStartRow# to #variables.myEndrow# of #variables.myRecordCount# 
						<cfelse>
								No records found matching your criteria
						</cfif>		 
						<span class="txt_divider">|</span>
						<span class="recordnav">
	 						<!--- Go to next page --->
	 						<cfif variables.myCurrentPage lt variables.myTotalPages>
	 						<a title="Show next set of #variables.myRowsPerPage# records" href="#variables.linkNextRecord#">next &gt;</a>	
	 						<cfelse>
	 						<span>next &gt;</span>
	 						</cfif>
 							<!--- Go to last page --->
 							<cfif variables.myCurrentPage neq variables.myTotalPages>
 							<a title="Move to last set of records in table" href="#variables.linkLastRecord#">last &gt;&gt;</a>
 							<cfelse>
 							<span>last &gt;&gt;</span>
 							</cfif>
 						</span>	
						</td>
						<td class="posRight">
							<span id="#arguments.prepend_to_id#.tblhelp">
								<a href="#variables.myCFCUrl#?method=getToolTip&amp;el=tblhelp" title="remote:#variables.myCFCUrl#?method=getToolTip&amp;el=tblhelp">help?</a>
							</span>
						</td>
					</tr>
				</tbody>
			</table>
</cfoutput>
</cfxml> 
<cfreturn replace(ToString(TableNav), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cffunction>

<cffunction name="getTableNavGoogleStyle" access="private" output="false" returntype="string">
<cfargument name="prepend_to_id" required="true" type="string" />

<cfset var NavLinksStart=0>
<cfset var NavLinksEnd=0>

<cfxml variable="TableNav">
<cfoutput>
			<table id="#arguments.prepend_to_id#-nav">
				<tbody>
					<tr id="#arguments.prepend_to_id#-tblNav">
						<td class="gs-posleft">
						<span class="gs-nav-text-results">Page <span class="pagenum">#variables.myCurrentPage#</span> of <span class="pagenum">#variables.myTotalPages#</span></span>
						<span class="prevpage">
 							<!--- Go to previous page --->
 							<cfif variables.myCurrentPage gt 1>
 							<!--- <a class="gs-nav-first" href="#variables.linkFirstRecord#">
 							<img src="#SESSION.view.skins.default.path#arrow-first.gif" alt="First page" /></a> --->
							<a class="gs-nav-previous" href="#variables.linkPrevRecord#">
 							<img src="#SESSION.view.skins.default.path#arrow-left.gif" alt="Previous page" /></a>
 							<a class="gs-nav-previous" href="#variables.linkPrevRecord#">Prev</a>					
 							<cfelse>
							 <span class="greyedOut"><img src="#SESSION.view.skins.default.path#arrow-left-disabled.gif" alt="Previous page" /> Prev</span>
							</cfif>
 						</span>
 						<span id="gs-pagelinks">
 						<cfscript>
 						//show 10 navigational links for the pages
 						if (variables.myCurrentPage gte 5) {
 						NavLinksStart = variables.myCurrentPage - 4;
 						} else {
						NavLinksStart = 1;
 						}
 						
 						// set navlinks end to 10 past the current page if they are that many record
 						if ((variables.myCurrentPage+8) gt variables.myTotalPages) {
 						NavLinksEnd = 	variables.myTotalPages;
 						} else {	
 						NavLinksEnd = NavLinksStart + 8;
 						}
 						
 						for(x=NavLinksStart; x lte NavLinksEnd; x=x+1) {
 							if (x eq variables.myCurrentPage AND x neq NavLinksEnd) {
 								writeOutput('<span>' & variables.myCurrentPage & '</span>'); 
 							} else if (x eq variables.myCurrentPage AND x eq NavLinksEnd) {
 							    writeOutput('<span class="greyedOut">' & variables.myCurrentPage & '</span>'); 
 							} else {
 								writeOutput('<a href="' & variables.myURL & '?' & variables.parsedQueryString & '&amp;tblchangepg=next&amp;pageid=' & (x-1) & '&amp;widgetID=' & variables.tblname & '">' & x & '</a>'); 
 							}
 						}
 						</cfscript> 
 						</span>
							<span class="nextpage">
	 						<!--- Go to next page --->
 	 						<cfif variables.myCurrentPage lt variables.myTotalPages>
	 						<a class="gs-nav-next" href="#variables.linkNextRecord#">
	 						Next</a>	
	 						<a class="gs-nav-next" href="#variables.linkNextRecord#"><img src="#SESSION.view.skins.default.path#arrow-right.gif" alt="Next page" /></a>
	 						<!--- <a class="gs-nav-last" href="#variables.linkLastRecord#">
 							<img src="#SESSION.view.skins.default.path#arrow-last.gif" alt="Lastt page" /></a> --->
	 						<cfelse>
							 <span class="greyedOut">Next <img src="#SESSION.view.skins.default.path#arrow-right-disabled.gif" alt="Next page" /></span>
							</cfif> 
 						</span>	
						</td>
						<td class="gs-posRight">
						<!--- startrow: #variables.myStartRow# endrow: #variables.myEndRow# currentpage: #variables.myCurrentPage#   --->
						</td>
					</tr>
				</tbody>
			</table>
</cfoutput>
</cfxml> 
<cfreturn replace(ToString(TableNav), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cffunction>

<cffunction name="getHeader" access="private" output="false" returntype="string">

<cfset var qCP=1> <!--- query column postition --->

<cfxml variable="myHeader"> 
<cfoutput>
<thead id="thead_cols">
	<!--- if table navigation is to be shown in the head --->
	<cfif variables.myShowNavAtTop>
	<tr class="nestedTblWrapper">
		<th colspan="#listlen(variables.myColumnNameList)#">
		#getTableNav("head")#		
		</th>
	</tr>
	</cfif>
	<!--- column titles --->
	<tr id="xw_col_titles">
	<cfloop from="1" to="#listlen(variables.myColumnNameList)#" index="lp">
	<th id="col#lp#_<cfif trim(listGetAt(variables.myColumnTypeList, lp)) eq "custom">custom<cfelse>#XWUTIL.encode_TH_ID(listGetAt(variables.myColumnNameList, lp))#</cfif>" style="<cfif variables.myColWidths neq ""><cfif len(trim(listGetAt(variables.myColWidths, lp))) neq 0>width: #listGetAt(variables.myColWidths, lp)#;</cfif></cfif><cfif variables.myAlignment neq "">text-align: #listGetAt(variables.myAlignment, lp)#;</cfif>"
		<cfif lp eq 1> class="lhscol"<cfelseif lp eq listlen(variables.myColumnNameList)> class="rhscol"</cfif>>
		<cfif listGetAt(variables.myColumnShowHideTitleList, lp) eq 1>
		  <!--- <cfif trim(listGetAt(variables.myColumnTypeList, lp)) eq "query" OR (variables.columnSortable NEQ "" AND trim(listGetAt(variables.columnSortable, lp)) neq "false")> --->
			<cfif variables.columnSortable NEQ "" AND trim(listGetAt(variables.columnSortable, lp)) neq "false">
			<a href="#variables.myURL#?#variables.parsedQueryString#&amp;tblsort=#trim(listGetAt(variables.columnSortable, lp))#">#listGetAt(variables.myColumnNameList, lp)#</a>
 			<cfelseif trim(listGetAt(variables.myColumnTypeList, lp)) eq "query" AND (variables.columnSortable NEQ "" AND trim(listGetAt(variables.columnSortable, lp)) eq "false")>
			<a href="#variables.myURL#?#variables.parsedQueryString#&amp;tblsort=#trim(listGetAt(variables.myQueryColumnBindList, qCP))#">#listGetAt(variables.myColumnNameList, lp)#</a> 
			<cfelseif variables.columnSortable neq "" AND trim(listGetAt(variables.columnSortable, lp)) eq "false">
			#listGetAt(variables.myColumnNameList, lp)#
			<cfelseif variables.columnSortable eq "">
			#listGetAt(variables.myColumnNameList, lp)#
			</cfif>
		  <!--- </cfif> --->
		</cfif>
	</th>
	<!--- query column list iterator --->
	<cfif trim(listGetAt(variables.myColumnTypeList, lp)) eq "query">
		<cfif lp eq listlen(variables.myColumnNameList)>
			<cfset qCP=1>
		<cfelse>
		    <cfset qCP=qCP+1>
		</cfif>	
	</cfif>		
	</cfloop>
	</tr>
</thead>
</cfoutput>
</cfxml> 
<cfreturn replace(ToString(myHeader), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cffunction>

<cffunction name="getBody" access="private" output="false" returntype="string">

<!--- used when formatting a row value because while the custom column list is continuous the position of a custom column may vary--->
<cfset var CustomColumnPosition=1>
<cfset var QueryColumnPosition=1>
<cfset var CustomRowValue="">
<cfset var boundQueryCol="">

<!---some generic variables for working with strings--->
<cfset var StrStart=0>
<cfset var StrEnd=0>
<cfset var Str="">

<cfxml variable="myBody"> 
<cfoutput>
<tbody id="tbodydatarows">
	<!----if the whereclause is defined i.e. the filter is active--->
	<cfif variables.myWhereCol neq "" and variables.myWhereClause neq "">
	<tr id="tblFilter" name="tblFilter">
	<cfloop from="1" to="#listlen(variables.myColumnNameList)#" index="listpos">
	<td<cfif listpos eq 1> class="lhscol"<cfelseif listpos eq listlen(variables.myColumnNameList)> class="rhscol"</cfif>>
	<!--- is it a query column --->
	<cfif trim(listGetAt(variables.myColumnTypeList, listpos)) eq "query">
		<input type="text" class="frmFilterFld" name="frmFilter_#trim(listGetAt(variables.myColumnNameList, listpos))#" id="frmFilter_#trim(listGetAt(variables.myColumnNameList, listpos))#" <cfif myWhereCol eq trim(listGetAt(variables.myQueryColumnList, listpos))>value="#variables.myWhereClause#"</cfif> />
	</cfif>	
	</td>	
	</cfloop>
	</tr>	
	</cfif>
	
	<!---are there any records--->
	<cfif myRecordCount neq 0>
	<cfloop query="#evaluate(de('variables.mySqlQuery'))#" startrow="#variables.myStartRow#" endrow="#variables.myEndRow#">
	<!---altrow handler and removal of bottom border if last row in set--->
	<tr id="row#currentrow#" 
	<cfif 	  (currentrow mod 2 eq 0) and currentrow neq variables.myEndRow> class="altrow"
	<cfelseif (currentrow mod 2 eq 0) and currentrow eq  variables.myEndRow and variables.myShowLastRowBottomBorder> class="altrow"
	<cfelseif (currentrow mod 2 eq 0) and currentrow eq  variables.myEndRow and variables.myShowLastRowBottomBorder eq 0> class="altrow nobtmbdr"
	<cfelseif (currentrow mod 2 eq 1) and currentrow eq  variables.myEndRow and variables.myShowLastRowBottomBorder eq 0> class="nobtmbdr" 
	</cfif>>
		<cfloop from="1" to="#listlen(variables.myColumnNameList)#" index="listpos">
		<td<cfif listpos eq 1> class="lhscol"<cfelseif listpos eq listlen(variables.myColumnNameList)> class="rhscol"</cfif>
		<cfif variables.myAlignment neq "">style="text-align: #listGetAt(variables.myAlignment, listpos)#;"</cfif>>
		<!---is the column a query column--->		
		<cfif trim(listGetAt(variables.myColumnTypeList, listpos)) eq "query">
			<!--- is any formatting to be applied to the row? --->
			<cfswitch expression=#trim(listGetAt(variables.myColumnFormatList, listpos))#>
				<cfcase value="text">
						#xmlformat(evaluate(listGetAt(variables.myQueryColumnBindList, QueryColumnPosition)))#
				</cfcase>
				<cfcase value="number">
						#xmlformat(evaluate("numberFormat(" & listGetAt(variables.myQueryColumnBindList, QueryColumnPosition) & ")"))#		
				</cfcase>
				<cfcase value="decimal">
						#xmlformat(evaluate("decimalFormat(" & listGetAt(variables.myQueryColumnBindList, QueryColumnPosition) & ")"))#		
				</cfcase>
				<cfcase value="date">
						#xmlformat(evaluate(replace(variables.myDateFormat, ":rowval", trim(listGetAt(myQueryColumnBindList, QueryColumnPosition)))))#
				</cfcase>
				<cfcase value="time">
						#xmlformat(evaluate(replace(variables.myTimeFormat, ":rowval", trim(listGetAt(myQueryColumnBindList, QueryColumnPosition)))))#	
				</cfcase>
				<cfcase value="datetime">
						#xmlformat(evaluate(replace(variables.myDateFormat, ":rowval", trim(listGetAt(myQueryColumnBindList, QueryColumnPosition)))))# #xmlformat(evaluate(replace(variables.myTimeFormat, ":rowval", trim(listGetAt(myQueryColumnBindList, QueryColumnPosition)))))#	
				</cfcase>		
				<cfdefaultcase>
				#xmlformat(evaluate(listGetAt(variables.myQueryColumnBindList, QueryColumnPosition)))#
				</cfdefaultcase>
			</cfswitch>
	
			<!--- if we have been through all columns then reset to 1 for the next row iteration --->
			<cfif QueryColumnPosition eq listlen(variables.myQueryColumnBindList)>
				<cfset QueryColumnPosition=1>			
			<cfelse>
				<!--- add one to the custom column position --->
				<cfset QueryColumnPosition=QueryColumnPosition+1>
			</cfif>
			
		<cfelseif trim(listGetAt(variables.myColumnTypeList, listpos)) eq "custom">
		<!---Found a custom column: no support for formmating in custom columns--->
	
			<!--- Could be URI or Function e.g. getPortionSize(:UnitofSale, :SalePrice) --->
			<cfset CustomRowValue = listGetAt(variables.myCustomColumnValueList, CustomColumnPosition)>
			
			<!--- what type of custom column do we have: function or URI?	 --->
			<cfswitch expression=#ucase(trim(listGetAt(variables.myCustomColumnTypeList, CustomColumnPosition)))#>
				<cfcase value="URI">	
					<!--- does the custom row value contain a bind variable --->
					<cfif Find(":", CustomRowValue) neq 0>
						<!--- loop through query columns to see if customeRowValue matches one of them --->
						<cfloop list="#variables.myQueryColumnPrimaryKey#,#VARIABLES.myQueryColumnList#" index="queryCol">
							<cfif FindNoCase(trim(queryCol), CustomRowValue) neq 0>
									<!--- we have a match, so we know which query column is used, break out the loop! --->
								<cfset boundQueryCol = trim(queryCol)>
								<cfbreak />	
							</cfif>	
						</cfloop>						
				<cfset CustomRowValue=replace(CustomRowValue, ":#boundQueryCol#" , evaluate(boundQueryCol), "ALL")>
						#CustomRowValue#
					<cfelse>
						#CustomRowValue#
					</cfif>	
				</cfcase>
				<cfcase value="FUNCTION">
					<!--- Custom functions must return XML Formatted strings --->
					<cfset CustomRowValue=replace(CustomRowValue, ";", ",")>
						#evaluate("xwcustom." & trim(CustomRowValue))#
				</cfcase>
			</cfswitch>	
	
			<!--- if we have been through all columns then reset to 1 for the next row iteration --->
			<cfif CustomColumnPosition eq listlen(variables.myCustomColumnValueList)>
				<cfset CustomColumnPosition=1>
			<cfelse>
				<!--- add one to the custom column position --->
			<cfset CustomColumnPosition=CustomColumnPosition+1>			
			</cfif>	
		</cfif>
		</td>
		</cfloop>
	</tr>
	</cfloop>
	<!--- No records found! --->
	<cfelse>
	<tr id="row1">
	<td colspan="#listlen(variables.myColumnFormatList)#" class="lhscol rhscol norecfound">Sorry, no records were found</td>
	</tr>
	</cfif>
	 <cfif variables.myShowNavAtBottom>
	<tr class="nestedTblWrapper nobtmbdr">
		<td colspan="#listlen(variables.myColumnNameList)#">
		 <cfif variables.myFooterNavStyle eq "Google">#getTableNavGoogleStyle("foot")#<cfelse>#getTableNav("foot")#</cfif> 	
		</td>
	</tr>
	</cfif>
	 <cfif variables.myShowFooter>#getFooter()#</cfif> 
</tbody>
</cfoutput>
</cfxml>
<cfreturn replace(ToString(myBody), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cffunction>

<cffunction name="getFooter" access="private" output="false" returntype="string">

<cfxml variable="myFooter">
<cfoutput>
	<tr class="nestedTblWrapperfoot">
	  <td colspan="#listlen(variables.myColumnNameList)#">
		<table id="foot-ftnav" name="foot-ftnav">
				<tbody>
					<tr>
						<td class="posleft">
						<!--- &##169; Table Widget V1.0  --->
						</td>
						<td class="posCenter">
						</td>
						<td class="posRight">
							<span class="tblActions">
								Actions: <a href="#variables.linkReset#">Refresh</a>
							</span>
							<input type="hidden" name="submit" value="submit" /> 	
						</td>
					</tr>
				</tbody>
			</table>	
		</td>	
	</tr>
</cfoutput>
</cfxml>

<cfreturn replace(ToString(myFooter), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cffunction>


<cffunction name="getToolTip" access="remote" output="true" hint="outputs XHTML for tool tips">
<cfargument name="el" required="false" default="">

<!--- if no element is provided --->
<cfif ARGUMENTS.el eq "">
<cfoutput><span style="color:red">No data available or no element provided</span></cfoutput>
<cfelse>
<cfprocessingdirective suppresswhitespace="true">
<cfoutput>#trim(getToolTipXHTML(el))#</cfoutput>
</cfprocessingdirective>
</cfif>

</cffunction>

<cffunction name="getToolTipXHTML" access="private" hint="returns formatted XHTML">
<cfargument name="el" required="true">

<cfset var strXHTML="">

<!--- Table help --->
<cfif ARGUMENTS.el eq "tblhelp">

	<cfxml variable="tableHelp">
	<div>
	<span style="display:block" class="top">
	<strong>Table Help</strong><br /><br />
	<strong>Sorting columns:</strong> Click the title of the column to change sort order from ascending to descending and vice. versa<br /><br />
	<strong>Filter:</strong> By "Filter" click "show" and a text field becomes available for each column which can be filtered. 
	</span>
	<b style="display:block" class="bottom"></b>
	</div>
	</cfxml>
	<cfset strXHTML=replace(ToString(tableHelp), '<?xml version="1.0" encoding="UTF-8"?>', '')>
	<cfset strXHTML=replace(strXHTML, "<div>","", "ALL")>
	<cfset strXHTML=replace(strXHTML, "</div>","", "ALL")>
</cfif>

<cfreturn strXHTML>
</cffunction>

</cfcomponent>