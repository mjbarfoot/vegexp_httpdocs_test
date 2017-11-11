<cfif structKeyExists(url, "browser")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>unsupported browser!</title>		 
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
</head>
<style>
body {font-family: Arial, sans-serif;}
li {margin-top: 1em; margin-bottom: 1em;}
</style>
<body> 	
<h1>You are not using a supported internet browser. This website works with these popular browsers:</h1>
<ul>
<li>Firefox V1.0 or higher</li>
<li>Internet Explorer V6 </li>
</ul>
</body>
</html> 
<cfelseif structKeyExists(url, "cookiesDisabled")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>Cookies not enabled!</title>		 
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
</head>
<style>
body {font-family: Arial, sans-serif;}
li {margin-top: 1em; margin-bottom: 1em;}
p {margin-top: 1em; margin-bottom: 1em; font-size: 1.2em;}
</style>
<body> 	
<h1>Cookies are disabled in your internet browser. We use cookies to enable key features of this website to work. Please enable them and then click the link below to start using this website:</h1>
<p>
<a href="<cfoutput>#APPLICATION.root#</cfoutput>/index.cfm?sessionflush=true">Click here once you have enabled cookies</a>
</p>
 </body>
</html>
<cfelseif structKeyExists(url, "jsDisabled")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>Javascript disabled!</title>		 
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
</head>
<style>
body {font-family: Arial, sans-serif;}
li {margin-top: 1em; margin-bottom: 1em;}
p {margin-top: 1em; margin-bottom: 1em; font-size: 1.2em;}
</style>
<body> 	
<h1>Javascript is disabled in your internet browser. We use JavaScript to enable key features of this website to work. Please enable JavaScript and then click the link below to start using this website:</h1>
<p>
		<a href="<cfoutput>#APPLICATION.root#</cfoutput>/index.cfm?sessionflush=true">Click here once Javascript is enabled</a>
</p>
</body>
</html>
</cfif>

