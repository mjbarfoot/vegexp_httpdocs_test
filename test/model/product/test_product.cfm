<cfscript>
//myproduct =  createObject("component","cfc.model.product.product").init("ack");
//writeOutput("product id  is " &  myproduct.productid);
//myproduct.productid = "foo";
//writeOutput("product id  is " &  myproduct.productid);
//dump(myproduct);


myproduct =  createObject("component","cfc.model.product.product").init(6155);

writeOutput("Product:" & myproduct.getStockCode() & " TotalPrice:" & myproduct.getTotalPrice());

//myproduct.myvar = "ack";
//writeOutput(myproduct.myvar);
//dump(myproduct);
</cfscript>