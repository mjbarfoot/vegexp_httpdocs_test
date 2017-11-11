<cfscript>
if (NOT isdefined("Msg")) {
Msg = structnew();
Msg.title = "Please click the link below to reset your password";
Msg.body.link = "http://vegexp.clearview.local/activate.cfm?lkajsdlkjasldkjalsdkjdlakjlskjalskjalskjasdlkjlakjsldkjasl/index.htm";
}	

</cfscript>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
#wrapper {margin-left: 20px; margin-right: auto; width: 800px; padding: 1em; border: 1px solid #177730;}
#logo {background: url(https://<cfoutput>#cgi.server_name#</cfoutput>/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
#header {height: 40px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: #177730; color: White; padding-left: 14px;}
p {magin-bottom: 1.6em;}
p a {color: #177730;}
#questions {background-image: url(https://<cfoutput>#cgi.server_name#</cfoutput>/pix/icon-info.gif); background-position: top left; background-repeat: no-repeat; padding-left: 70px; margin-bottom: 1em;} */
</style>
</head>
<body>
<div id="wrapper">
	<cfoutput>
	<div id="logo"></div>
	<div id="header">
		<h1>#Msg.title#</h1>
	</div>
	<p>The following link will take you back to our website where you choose a new password for your account:</p>
	<p style="width:400px;"><a href="#Msg.Body.link#" >#Msg.Body.link#</a></p>
	<p id="questions" style="height: 70px;">
	For any questions you may have please contact Vegetarian Express on 01923 249 714 or <a href="mailto:questions@vegexp.co.uk">email us</a> 
	</p>
	</cfoutput>
</div>
</body>
</html>