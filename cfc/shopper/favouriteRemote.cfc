<!---
 Filename: /cfc/shopper/favouriteRemote.cfc
 Created by: Matt Barfoot (Clearview Webmedia)
 Purpose: Generates XHTML for the contents of the shopping basket
 Date: 01/07/15
 History:
--->
<cfcomponent output="false" name="favouriteRemote" displayname="favouriteRemote" hint="Favourites API">
    <cffunction name="addRemote" access="remote" returntype="void" output="true">
        <cfargument name="ProductID" type="numeric" required="true" />

       <cfscript>
            // get the Favourites Data Object
            var favouritesDO=createObject("component", "cfc.shopper.fav_do").init();

            // get the Departments Data Object
            var departmentDO=createObject("component", "cfc.departments.do");

            favouritesDO.addFavourite(departmentDO.getStockCode(ARGUMENTS.ProductID));

        </cfscript>

        <cfcontent type="text/xml"/>
        <cfoutput>
        <taconite-root xml:space="preserve">
            <taconite-replace  contextNodeID="fav-productid-#ARGUMENTS.ProductID#" parseInBrowser="true">
                <img id="fav-productid-#ARGUMENTS.ProductID#" class="iconFav" src="/resources/fav_14_selected.gif" alt="Already added to your Favourites" />
            </taconite-replace>
        </taconite-root>
        </cfoutput>

    </cffunction>
</cfcomponent>
