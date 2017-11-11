<!---
  Created by mbarfoot on 02/07/15.
--->
<cfoutput> Testing AddRemote Method of BasketRemote<br/></cfoutput>
<cfscript>
testBasketRemote=createObject("component", "cfc.shopper.basketContents").init();
</cfscript>
<cfoutput><h1>test output</h1>
<pre> #htmleditformat(testBasketRemote.addRemote(ProductID=url.productID,Qty=1))#</pre>
</cfoutput>