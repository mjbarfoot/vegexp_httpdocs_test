<cfquery name="qryGetOfferShorts"  datasource="#APPLICATION.dsn#">
	SELECT o.StockCode, p.description as "itemdesc", o.Description, 
	o.ImageSrc, o.ImageAlt, o.ThumbSrc, p.UnitOfSale, p.SalePrice, p.StockID
	FROM  tblOfferInfo o, tblOffer t, tblProducts p
	WHERE o.StockCode = t.Stockcode
	AND   p.Stockcode = t.Stockcode
	<!--- AND   t.OfferID = #ARGUMENTS.OfferID# --->
	ORDER BY o.Stockcode asc
</cfquery>

<cfoutput>#qryGetOfferShorts.columnList#</cfoutput>	