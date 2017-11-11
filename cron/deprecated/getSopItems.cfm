<cfquery name="qGetSOPITEM" datasource="veSageDb" result="qRes">
select ORDER_NUMBER, STOCK_CODE, DESCRIPTION, QTY_ORDER from SOP_ITEM
</cfquery>

<cfloop query="qGetSOPITEM">
	<cfif order_number eq "-1">
		<cfoutput>currentrow:#currentrow# ORDER_NUMBER: #ORDER_NUMBER#, STOCK_CODE: #STOCK_CODE#, DESCRIPTION: #DESCRIPTION#, QTY_ORDER: #QTY_ORDER#</cfoutput> 
	</cfif>
</cfloop>