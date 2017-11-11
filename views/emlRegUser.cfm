<cfscript>
if (NOT isdefined("Msg")) {
Msg = structnew();
Msg.title = "Thanks for Registering";
Msg.body = structnew();
Msg.body.firstname="Johny";
Msg.body.lastname="Tester";
Msg.body.AccountID="ACME001";
Msg.body.accPass="Te57er";
}	

</cfscript>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Vegetarian Express Email</title>
<style>
body {background-color: White; color: Black; font-family: Arial; font-size: 0.9em;}
#wrapper {margin-left: 100px; margin-right: auto; width: 500px; padding: 1em; border: 1px solid #177730;}
#logo {background: url(http://localhost:8050/skin/default/vegexp_logo.gif) left top; background-repeat: no-repeat; width: 500px; height: 100px;}
#header {height: 20px; margin-left: -1em; margin-right: -1em;}
h1 {font-size: 1.4em; background-color: #177730; color: White; padding-left: 1em;}
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
	Dear #Msg.body.firstname# #Msg.body.lastname#,<br /><br />
	Your AccountID is: ?<br />
	Your Password  is: #Msg.body.accPass#</p> 
	<p>
	You will need these details when using the Vegetarian Express website. Please keep them safe.
	</p>
	<p>
	If you have applied for a credit account you receive notification by email or phone once it has been authorised.
	</p>
	<p id="questions" style="height: 70px;">
	For any questions you may have please contact Vegetarian Express on 01923 249 714 or <a href="mailto:questions@vegexp.co.uk">email us</a> 
	</p>
	</cfoutput>
</div>
</body>
</html>