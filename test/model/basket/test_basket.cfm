<cfsavecontent variable="results">
	<cfscript>
		testProduct = 6155;
		testbasket = createObject("component","cfc.model.basket.basket").init(testProduct);
		
		add;
		listAdd;
		update;
		remove;
		empty;
		list;
		listProductIDs;		

	</cfscript>
</cfsavecontent>

<cfinclude template="/view/test/defaultTest.cfm" />