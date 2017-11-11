<cfoutput>
SESSION.UserAgent.id: #SESSION.UserAgent.id#<br />
SESSION.UserAgent.version: #SESSION.UserAgent.version#<br />
SESSION.UserAgent.CookieAndJSenabled: #SESSION.UserAgent.CookieAndJSenabled#<br />
SESSION.UserAgent.supported: #SESSION.UserAgent.supported#<br />
session.skins.default.css: #session.skins.default.css#<br />
CGI.HTTP_USER_AGENT: #CGI.HTTP_USER_AGENT#
</cfoutput> 
<cfif structKeyExists(url, "browser")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>unsupported browser!</title>		 
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <link rel="stylesheet" type="text/css" href="/css/import.css" />
  <link rel="stylesheet" type="text/css" href="/css/common.css" />
  <link rel="stylesheet" type="text/css" href="/skin/default/layout.css" />
</head>
<style>
li {margin-top: 1em; margin-bottom: 1em;}
</style>
<body> 	
	 <div id="wrapper">
		<div id="head">	
			<a href="/index.cfm"><img src="/skin/default/vegexp_logo.gif" alt="Vegetarian Express" /></a>	
		</div>					
		<div style="margin-left: 30px; margin-top: 1em;">		
			<span style="font-size: 1.4em;  margin-bottom: 2em ;margin-top: -1em;">
			You are not using a supported internet browser. This website works with these popular browsers:
			</span>
			<ul>
			<li>Firefox V1.0 or higher: <a style="padding-left: 150px" title="Get Firefox" href="http://www.mozilla.com/firefox/"><img src="/resources/getfirefox.gif" alt="get Firefox"></a></li>
			<li>Internet Explorer V6 or higher: <a style="padding-left: 100px" title="Get Internet Explorer" href="http://www.microsoft.com/windows/ie/"><img src="/resources/getIE.gif" alt="get Internet Explorer"></a></li>
			<li>Opera 8 or higher <a style="padding-left: 180px" title="Get Firefox" href="http://www.opera.com"><img src="/resources/getopera.gif" alt="get opera"></a></li>
			</ul>
		<p style="font-size: 1.2em;margin-top: 2em; margin-bottom:2em;">
		If you wish to place an order or check stock availability please call us using the number below
		</p>
		</p>
		</div>
		<div id="ordhot_wrapper">
						<span id="hotline">Sales Office: <span id="hot_telnum">01923 249714</span></span>
						<span id="nextday">Orders must be placed by 3.30pm for next day delivery</span>
		</div>
	</div>
 </body>
</html> 
<cfelseif structKeyExists(url, "cookiesDisabled")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>Cookies not enabled!</title>		 
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <link rel="stylesheet" type="text/css" href="/css/import.css" />
  <link rel="stylesheet" type="text/css" href="/css/common.css" />
  <link rel="stylesheet" type="text/css" href="/skin/default/layout.css" />
</head>
<style>
li {margin-top: 1em; margin-bottom: 1em;}
p {margin-top: 1em; margin-bottom: 1em; font-size: 1.2em;}
</style>
<body> 	
	 <div id="wrapper">
		<div id="head">	
			<a href="/index.cfm"><img src="/skin/default/vegexp_logo.gif" alt="Vegetarian Express" /></a>	
		</div>					
		<div style="margin-left: 30px; margin-top: 1em;">		
			<span style="font-size: 1.4em;  margin-bottom: 2em ;margin-top: -1em;">
			Cookies are disabled in your internet browser. We use cookies to enable key features of this website to work. Please enable them and then click the link below to start using this website:
			</span>
			<p>
			<a href="/index.cfm?sessionflush=true">Click here once you have enabled cookies</a>
			</p>
		<p style="font-size: 1.2em;margin-top: 2em; margin-bottom:2em;">
		If you wish to place an order or check stock availability please call us using the number below
		</p>
		</p>
		</div>
		<div id="ordhot_wrapper">
						<span id="hotline">Sales Office: <span id="hot_telnum">01923 249714</span></span>
						<span id="nextday">Orders must be placed by 3.30pm for next day delivery</span>
		</div>
	</div>
 </body>
</html>
<cfelseif structKeyExists(url, "jsDisabled")>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>Javascript disabled!</title>		 
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <link rel="stylesheet" type="text/css" href="/css/import.css" />
  <link rel="stylesheet" type="text/css" href="/css/common.css" />
  <link rel="stylesheet" type="text/css" href="/skin/default/layout.css" />
</head>
<style>
li {margin-top: 1em; margin-bottom: 1em;}
p {margin-top: 1em; margin-bottom: 1em; font-size: 1.2em;}
</style>
<body> 	
	 <div id="wrapper">
		<div id="head">	
			<a href="/index.cfm"><img src="/skin/default/vegexp_logo.gif" alt="Vegetarian Express" /></a>	
		</div>					
		<div style="margin-left: 30px; margin-top: 1em;">		
			<span style="font-size: 1.4em;  margin-bottom: 2em ;margin-top: -1em;">
			Javascript is disabled in your internet browser. We use JavaScript to enable key features of this website to work. Please enable JavaScript and then click the link below to start using this website:
			</span>
			<p>
			<a href="/index.cfm?sessionflush=true">Click here once Javascript is enabled</a>
			</p>
		<p style="font-size: 1.2em;margin-top: 2em; margin-bottom:2em;">
		If you wish to place an order or check stock availability please call us using the number below
		</p>
		</p>
		</div>
		<div id="ordhot_wrapper">
						<span id="hotline">Sales Office: <span id="hot_telnum">01923 249714</span></span>
						<span id="nextday">Orders must be placed by 3.30pm for next day delivery</span>
		</div>
	</div>
 </body>
</html>
</cfif>

