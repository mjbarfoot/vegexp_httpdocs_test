<cfprocessingdirective suppresswhitespace="true">
<!--- / Page Defaults / --->


<cfscript>
//switch back to default skin
//session.shop.skin.path = application.skins.default.path;

//get the breadcrumb trail
shopperBreadcrumbTrail=session.shopper.breadcrumb.getBreadCrumbTrail("Contact Us");

// create the departements view object
request.departments.view=createObject("component", "cfc.departments.view");


//captcha code

encryptKey = "ackFire99";
blnIsBot = true ;

try {
	if (NOT isdefined("FORM.submitted")) {
		FORM.submitted = 0;
	}

	if (NOT isdefined("FORM.captcha")) {
		FORM.captcha = "";
	}


} catch (Any Ex) {
	FORM.submitted = 0;
}

if ( form.submitted ) {
	try {
		request.strCaptcha = Decrypt(FORM.captcha_check,encryptKey,"CFMX_COMPAT","HEX");
		if (request.strCaptcha EQ FORM.captcha) {
			blnIsBot = false;
		}
	} catch (Any ex) {
		blnIsBot = true;
	}

	if (blnIsBot) {
		request.sCaptchaError = "Sorry, please the text you entered did not match the image. Please try again";
	}

}
arrValidChars = ListToArray("A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,2,3,4,5,6,7,8,9");
CreateObject("java","java.util.Collections").Shuffle(arrValidChars);
request.strCaptcha = (arrValidChars[ 1 ] & arrValidChars[ 2 ] & arrValidChars[ 3 ] & arrValidChars[ 4 ] & arrValidChars[ 5 ] & arrValidChars[ 6 ] & arrValidChars[ 7 ] & arrValidChars[ 8 ]);
FORM.captcha_check = Encrypt(request.strCaptcha,encryptKey,"CFMX_COMPAT","HEX");


//form handler
if (isdefined("form.frmSubmit") and  NOT blnIsBot) {
	
	eml=createObject("component", "cfc.shop.dispatchMsg");
	
	//send confirmation to customer
	msg = structnew();
	msg.body = structnew();
	msg.title = "Please respond to this customer message below:";
	msg.body = form;
	eml.sendEmail("tracymoore@vegexp.co.uk","webcontactform@vegexp.co.uk","Web Contact Form Message from #form.firstName# #form.lastname# of #form.company#", msg, "/views/emlContactForm.cfm", "willmatier@vegexp.co.uk");
	
	// get thank you page
	contactContent = request.departments.view.getContactThanks();		

}
	// display the contact form
	else {

	contactContent = request.departments.view.getContactForm();

}

//add the css file
if (isdefined("request.css")) {
	request.css	=	request.css & "," &  "/css/contact.css";
} else {
	request.css	= 	"/css/contact.css";
}

request.js = "/js/formUI.js" & "," & "/js/contactform.js"; 

request.tabSelected="";
</cfscript>

<!--- build the content on to an xml variable --->
<cfsavecontent variable="myContent">
<cfoutput>
<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		#contactContent#	
	</div>
</div>	
</cfoutput>
</cfsavecontent>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfset content=reReplace(content, ">[[:space:]]+#chr( 13 )#<", "all")>


<cfinclude template="/views/default.cfm">
</cfprocessingdirective>