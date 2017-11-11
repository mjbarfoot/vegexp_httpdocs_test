<!---
  Created by mbarfoot on 02/07/15.
--->

<cfscript>
// get the Favourites Data Object
    favouritesDO=createObject("component", "cfc.shopper.fav_do").init();

// get the Departments Data Object
    departmentDO=createObject("component", "cfc.departments.do");

    favouritesDO.addFavourite(departmentDO.getStockCode(url.productid));

</cfscript>