<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title><cfoutput>#request.view.title#</cfoutput></title>
<meta http-equiv="expires" content="0" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Content-Language" content="en" />
<meta name="description" content="QSApp - Quantity Surveyors' Facilitator-MXES Audit Application" />
<meta name="copyright" content="Copyright RBS (c) 2007" />
<link rel="stylesheet" type="text/css" href="/css/login.css" />
</head>	
<body>
<cfif isdefined("SESSION.Auth.Error")> 
<span><cfoutput>#SESSION.Auth.Error#</cfoutput></span></cfif>
<form method="post" action="/index.cfm">
	<input type="text" id="q_username" name="q_username" value="" />
	<input type="password" id="q_password" name="q_password" value="" />
	<input type="image" src="/skin/default/login_button.gif" id="frmSubmit" value="frmSubmit" />
</form>
</body>
</html>