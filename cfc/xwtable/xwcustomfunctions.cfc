<!--- 
	Component: xwtablecustomfunctions.cfc
	File: /cfc/xwtable/xwtablecustomfunctions.cfc
	Description: Custom functions which can be used for providing output to custom columns
	Author: Matt Barfoot
	Date: 05/04/2006
	Revisions:

	19/04/2006: Added notes to hint about parsing passed data/query values to make sure they are XML formatted before adding any XHTML.
	--->

<cfcomponent name="customfunctions" output="false" displayname="xwtablecustomfunctions"
        hint="cusom functions are defined here. If a column in a table needs to do something special then a custom function is defined to do the job.
Custom functions parse any passed bind (query) values to make sure they are XML compliant strings. If they include XHTML, format any bind variables before adding XHTML">

    <cffunction name="getPortionSize" access="public" returnType="string" hint="Caculates the portion cost (if appopriate)">
        <cfargument name="UnitOfSale" type="String" required="true" hint="The pack size description e.g. 1x144"/>
        <cfargument name="SalePrice" type="numeric" required="true" hint="The total price"/>

        <cfscript>
//is there a multiplier i.e. 1x144 the x indicates only a quantity of 1 there fore portion cost is not relevant
            var positionOfMultiplier = find("x", UnitOfSale);
            var packQuantity = "";
            var portionCost = "";
            var sp = 0;


            if (positionOfMultiplier neq 0) {

// is there a pack size defined which includes only one portion?
                if (left(positionOfMultiplier, 1) eq 1 AND positionOfMultiplier eq 2) {
                    return ""; //return empty string
                }
// found a pack of several items
                else {
                    packQuantity = mid(UnitOfSale, 1, (positionOfMultiplier - 1));
                    packQuantity = rereplace(packQuantity, "[^0-9x]", "", "ALL");
                    sp = getDiscountedPrice(SalePrice)
                    if (sp neq "") {
                        portionCost = sp / packQuantity;
                    } else {
                        portionCost = SalePrice / packQuantity;
                    }
//return the portion cost as a string (but formatted as a decimal)
                    return "#XMLFormat(decimalFormat(portionCost))#";
                }
            } else {
// single pack size - return empty string
                return "";
            }

        </cfscript>
    </cffunction>

    <cffunction name="convertCodesToIcons" access="public" returnType="string" hint="Looks for the Organic, Gluten Free and Vegan codes and converts them to icons">
        <cfargument name="description" type="String" required="true" hint="the string to check"/>
        <cfargument name="StockID" type="numeric" required="true"/>
        <cfargument name="StockQuantity" type="numeric" required="true"/>
        <cfargument name="IsFavourite" type="numeric" required="false" default="0"/>
        <cfscript>
//is there a multiplier i.e. 1x144 the x indicates only a quantity of 1 there fore portion cost is not relevant
            var iconWrapLeft = '<span class="desc-col-lefpad">';
            var OrganicIcon = '<img class="desc-col-icon"  	src="/resources/icon-organic.gif" 		alt="organic" />';
            var GlutenFreeIcon = '<img class="desc-col-icon" 	src="/resources/icon-glutenfree.gif" 	alt="glutenfree" />';
            var VeganIcon = '<img class="desc-col-icon"     src="/resources/icon-vegan.gif" 		alt="vegan" />';
            var iconWrapRight = '</span>';
//replace any non compliant XML characters from the description query string
            description = XMLFormat(description);


//search highlighter
            if (isdefined("url.pQ") AND len(url.pQ) gt 0) {
                description = ReplaceNoCase(description, url.pq, "<span style='color:blue'>#url.pq#</span>");
            } else
                if (isdefined("form.qDescription") AND form.qDescription neq "") {
                    description = ReplaceNoCase(description, form.qDescription, "<span style='color:blue'>#form.qDescription#</span>");
                }

            if (Find("(FROZEN)", description)) description = replace(description, "(FROZEN)", "");
            if (Find("(CHILLED)", description)) description = replace(description, "(CHILLED)", "");

            if (Find("(ORG)", description)) {
                description = replace(description, "(ORG)", "");
                description = description & iconWrapLeft & OrganicIcon & iconWrapRight;
            }

            if (Find("(Vegan)", description)) {
                description = replace(description, "(Vegan)", "");
                description = description & iconWrapLeft & VeganIcon & iconWrapRight;
            }

            if (Find("(Gluten Free)", description) or FindNoCase("(GF)", description)) {
                description = replace(description, "(Gluten Free)", "");
                description = replaceNoCase(description, "(GF)", "");
                description = description & iconWrapLeft & GlutenFreeIcon & iconWrapRight;
            }


//add to favourites link if not favourties page
            if (SESSION.AUTH.AccountID neq "" and FindNoCase("favourites.cfm", CGI.SCRIPT_NAME) eq 0) {
                if (ARGUMENTS.isFavourite eq 1) {
                    description = description & iconWrapLeft & "<img id='fav-productid-#ARGUMENTS.StockID#' class='iconFav' src='/resources/fav_14_selected.gif' alt='Already added to your Favourites' />" & iconWrapRight;
                } else {
                    description = description & iconWrapLeft & "<a id='fav-productid-#ARGUMENTS.StockID#' title='Add to Favourites' href='/favourites.cfm?ev=favourites&amp;action=add&amp;StockID=#ARGUMENTS.StockID#' class='iconFav'><img src='/resources/fav_14.gif' alt='add to Favourites' /></a>" & iconWrapRight;
                }
            }


            if (ARGUMENTS.StockQuantity gte 1 AND ARGUMENTS.StockQuantity lt 10) {
                description = description & " <span class='outOfStock'>(Low Stock)</span>";
            } else
                if (ARGUMENTS.StockQuantity eq 0) {
                    description = description & " <span class='outOfStock'>(Out of Stock) </span>";
                }


            return description;
        </cfscript>
    </cffunction>

    <cffunction name="prodInfoLinks" access="public" returnType="string" hint="Displays the links/icons for product information and recipes">
        <cfargument name="StockID" type="numeric" required="true"/>
        <cfargument name="StockCode" type="string" required="false"/>

<!--- <img  src='/skin/default/icon_info_small.gif' alt='more info' /> --->
        <cfscript>
//--- / Object declarations / ----------------------/
            var depDO = createObject("component", "cfc.departments.do");
            var moreInfoLink = "";
            var recipeLink = "";

//check if there is a record
            if (depDO.isProdInfo(ARGUMENTS.StockID)) {
                moreInfoLink = "<a class='prodinfo' style='position:relative;' id='prodinfo:#ARGUMENTS.StockID#' href='/showProductInfo.cfm?ProductID=" & ARGUMENTS.stockid & "'><img src='" & session.shop.skin.path & "icon_info_small.gif' alt='more info' /></a>";
            }

            // 10/04/15 - disabled
           /* if (depDO.isRecipeInfo(ARGUMENTS.StockID)) {
                recipeLink = "<a class='recipeinfo' style='position:relative;' id='recipe:#ARGUMENTS.StockID#' href='/recipes.cfm?ProductID=" & ARGUMENTS.stockid & "'><img src='/skin/default/icon_recipe_small.gif' alt='recipe info' /></a>";
            }*/

            return moreInfoLink & recipeLink;
        </cfscript>
    </cffunction>

    <cffunction name="Add2BasketLinks" access="public" returnType="string" hint="If product is in stock returns a link to add to basket">
        <cfargument name="StockID" type="numeric" required="true"/>
        <cfargument name="StockQuantity" type="boolean" required="true"/>

        <cfscript>
            var Add2BasketLink = "";


//check if there is a record
            if (ARGUMENTS.StockQuantity eq 0) {
                Add2BasketLink = "<span class='outOfStock'>No Stock</span>";
            } else {
// add button
                Add2BasketLink = "<a class='addtobasket' href='#cgi.script_name#?#xmlformat(cgi.QUERY_STRING)#&amp;ev=basket&amp;action=Add&amp;ProductID=#ARGUMENTS.stockid#'>Add</a>";

// add quantity field
                Add2BasketLink = Add2BasketLink & "<input type=""text"" class=""addqty"" name=""BsQty#ARGUMENTS.stockid#"" id=""BsQty#ARGUMENTS.stockid#"" value=""1"" />";

            }

            return Add2BasketLink;
        </cfscript>
    </cffunction>

    <cffunction name="deleteFavouriteLink" access="public" returnType="string" hint="If product is in stock returns a link to add to basket">
        <cfargument name="FavID" type="numeric" required="true"/>

        <cfscript>
            var deleteFavLink = "<a class='remove' href='/favourites.cfm?ev=favourites&amp;action=remove&amp;FavID=#ARGUMENTS.FavID#'><img src='/skin/default/icon-remove.gif' alt='remove Favourite' /></a>";

            return deleteFavLink;
        </cfscript>
    </cffunction>


    <cffunction name="AdminActions" access="public" returnType="string" hint="If product is in stock returns a link to add to basket">
        <cfargument name="StockID" type="numeric" required="true"/>

        <cfscript>
            var ActionLinks = "";

// add Edit
            ActionLinks = "<a href='#cgi.script_name#?#xmlformat(cgi.QUERY_STRING)#&amp;ev=basket&amp;action=Add&amp;ProductID=#ARGUMENTS.stockid#'>Add</a>";

// Disable
            Add2BasketLink = Add2BasketLink & "<input type=""text"" class=""addqty"" name=""BsQty#ARGUMENTS.stockid#"" id=""BsQty#ARGUMENTS.stockid#"" value=""1"" />";


            return Add2BasketLink;
        </cfscript>
    </cffunction>


    <cffunction name="LastOrderInfo" access="public" returnType="string" hint="If product is in stock returns a link to add to basket">
        <cfargument name="LastOrderDate" type="any" required="false"/>
        <cfargument name="LastOrderQuantity" type="string" required="false" default=0/>

        <cfscript>
            var LastOrderInfo = "";

            if (isdefined("ARGUMENTS.LastOrderDate") and isDate(ARGUMENTS.LastOrderDate)) {
                LastOrderInfo = LSDateFormat(ARGUMENTS.LastOrderDate, "dd/mm/yyyy");
            }

            if (isdefined("ARGUMENTS.LastOrderQuantity") AND isNumeric(ARGUMENTS.LastOrderQuantity) AND ARGUMENTS.LastOrderQuantity neq 0) {
                LastOrderInfo = LastOrderInfo & " Qty: #ARGUMENTS.LastOrderQuantity#";
            }

            return LastOrderInfo;

        </cfscript>
    </cffunction>

    <cffunction name="categoryStatus" access="public" returnType="string" hint="If product is in stock returns a link to add to basket">
        <cfargument name="disabled" type="numeric" required="true"/>
        <cfscript>
            if (ARGUMENTS.disabled eq 1) {
                return "Disabled";
            } else {
                return "Enabled";
            }
        </cfscript>
    </cffunction>

    <cffunction name="catDescAndStockCount" access="public" returntype="string" hint="counts the number of items belonging to a particular categoryid">
        <cfargument name="categoryid" type="numeric" required="true"/>
        <cfargument name="category" type="string" required="true"/>

        <cfscript>
//--- / Object declarations / ----------------------/
            var depDO = createObject("component", "cfc.departments.do");

            return ARGUMENTS.category & " (" & depDO.getQryCountStockByCategory(ARGUMENTS.categoryid) & ")";

        </cfscript>
    </cffunction>

    <cffunction name="getDiscountedPrice" access="public" returntype="string" hint="returns the price based upon the customers discount rate">
        <cfargument name="salesprice" type="numeric" required="true"/>

        <cfif SESSION.Auth.isLoggedIn or SESSION.Auth.viewPrices>
            <cfreturn decimalformat(arguments.salesprice * (1 - (session.auth.discountRate / 100)))/>
            <cfelse>
            <cfreturn ""/>
        </cfif>
<!--- <cfreturn 0 /> --->
    </cffunction>

    <cffunction name="getDiscountedPrice_deprecated" access="public" returntype="numeric" hint="returns the price based upon the customers discount rate">
        <cfargument name="salesprice" type="numeric" required="true"/>

        <cfreturn decimalformat(arguments.salesprice * (1 - (session.auth.discountRate / 100)))/>
<!--- <cfreturn 0 /> --->
    </cffunction>

</cfcomponent>
