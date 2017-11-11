<cfscript>
if (NOT isdefined("Msg")) {
Msg = structnew();
Msg.title = "Web Contact Form Message from Johny Tester";
Msg.body = structnew();
Msg.body.firstname="Johny"; 
Msg.body.lastname="Tester";
Msg.body.company="Johny Testing Limited";
Msg.body.telnum="0123456789";
Msg.body.emailAddress="johny@testing.com";
Msg.body.contactPref="Phone";
Msg.body.Message="This is a test message";
}	

</cfscript>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
#wrapper {margin-left: 20px; margin-right: auto; width: 500px; padding: 1em; border: 1px solid #177730;}
#logo {background: url(http://localhost:8050/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
#header {height: 20px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: #177730; color: White; padding-left: 14px;}
p {magin-bottom: 1.6em;}
p a {color: #177730;}
#questions {background-image: url(http://localhost:8050/pix/icon-info.gif); background-position: top left; background-repeat: no-repeat; padding-left: 70px; margin-bottom: 1em;} */
</style>
</head>
<body>
<div id="wrapper">
	<cfoutput>
	<div id="logo"></div>
	<div id="header">
		<h1>#Msg.title#</h1>
	</div>
	<p>
	Dear Vegetarian Express,<br /><br />
	A customer/visitor to the website gave the following comments/feedback on #Dateformat(now(), "dd/mm/yyyy")# at #timeformat(now(), "H:MM TT")#:
	<ul>
	<li>Company: #Msg.body.company#</li>
	<li>Name: #Msg.body.firstname# #Msg.body.lastname#</li>
	<li>Phone Number: #Msg.body.telnum#</li>
	<li>Email Address: #Msg.body.emailAddress#</li>
	<li>Contact Preference: <cfif isdefined("Msg.body.contactPref")>#Msg.body.contactPref#</cfif></li>
	</ul>
	</p> 
	<p>Their message is: <br /><hr />
	#Msg.body.Message#
	<br /><hr />
	</p>
	</cfoutput>
</div>
</body>
</html>