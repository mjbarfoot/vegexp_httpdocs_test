<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->

<cfparam name="url.refURL" default="" />

<cfscript>
//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Comments");

// create the departements view object
request.departments.view=createObject("component", "cfc.departments.view");

//form handler
if (isdefined("form.frmSubmit")) {
	
	result = SESSION.comments.do("add", FORM);
	if (result eq true) {
			// get thank you page
			commentContent = SESSION.comments.thanks();			
			
				eml=createObject("component", "cfc.shop.dispatchMsg");
	
				//send confirmation to customer
				msg = structnew();
				msg.body = structnew();
				msg.title = "Please review these website comments:";
				msg.body = form;
				eml.sendEmail(APPLICATION.var_DO.getVar("salesEmailAddress"),APPLICATION.var_DO.getVar("WebSalesEmailAddress"),"Website Comments from #form.yourName#", msg, "/views/emlCommentsForm.cfm");
	} else {
			// if failed pass back the reason why and the form
			commentContent = SESSION.comments.add(result, FORM);	
	}

} 
	// display the contact form
	else {

	commentContent = SESSION.comments.add();

}

//add the css file
if (isdefined("request.css")) {
	request.css	=	request.css & "," &  "/css/comment.css";
} else {
	request.css	= 	"/css/comment.css";
}

request.js = "/js/formUI.js"; // [27/09/06 MB]  & "," & "/js/comment.js"; 

request.tabSelected="";
</cfscript>

<!--- build the content on to an xml variable --->
<cfxml variable="myContent">
<cfoutput>
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		#commentContent#	
	</div>
</div>	
</cfoutput>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>


<cfinclude template="/views/default.cfm">
</cfprocessingdirective>