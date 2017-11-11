<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->
<cfparam name="url.RecipeID"  default=0 />
<cfparam name="url.ProductID" default=0 />

<cfscript>
//get the Currently viewing information bar
shopFilterDisplayBar=session.shopper.shopfilter.getFilterInfo();

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Recipes");

// create the departements view object
request.departments.view=createObject("component", "cfc.departments.view");
request.departments.dep_do=createObject("component", "cfc.departments.do");

// if there is a recipeID in the URL get the details
if (url.RecipeID) {
recipeContent = request.departments.view.getRecipe(url.RecipeID);
} 

// if ProductID/StockID passed then shopper came from one of the product list pages 
else if (url.ProductID) {
	//is there more than one recipe for this product?
	if (request.departments.dep_do.countRecipe(url.ProductID) gt 1) {
		recipeContent = request.departments.view.getRecipeListByProductID(url.ProductID);
	} 
	// Only 1 then display the recipe for that product
	else {
		recipeContent = request.departments.view.getRecipe(0, url.ProductID);
	}		
}
// if not get the recipe list	
	else {
recipeContent = request.departments.view.getRecipeList();	
}

//add the css file
if (isdefined("request.css")) {
request.css=request.css & "," &  session.shop.skin.path & "recipes.css";
} else {
request.css= session.shop.skin.path & "recipes.css";
}

request.js = "/js/recipes.js"; 

request.tabSelected="";
</cfscript>


<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<cfoutput>
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput> 
		<div id="recipeWrap" class="clearfix">
			#recipeContent#	
		</div>	
	</div>
</div>	
</cfoutput>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>

<cfif StructKeyExists(URL, "pfriendly")>
<cfinclude template="/views/recipe_print.cfm">
<cfelse>
<cfinclude template="/views/default.cfm">
</cfif>
</cfprocessingdirective>