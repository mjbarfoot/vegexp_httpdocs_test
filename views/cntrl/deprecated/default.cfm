<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Vegetarian Express Control Panel</title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<link rel="stylesheet" type="text/css" media="screen" href="<cfoutput>#session.shop.skin.path#cntrl.css</cfoutput>" />
<script type="text/javascript" src="/js/prototype.lite.js"></script>
<script type="text/javascript" src="/js/moo.fx.js"></script>
<script type="text/javascript" src="/js/moo.fx.pack.js"></script>
<script type="text/javascript" src="/js/cntrl.js"></script>
<!--- <script type="text/javascript">
	

	//the main function, call to the effect object
	function init(){
	
	
		var stretchers = document.getElementsByClassName('stretcher'); //div that stretches
		var toggles = document.getElementsByClassName('display'); //h3s where I click on

		//accordion effect
		var myAccordion = new fx.Accordion(
			toggles, stretchers, {opacity: true, duration: 300}
		);

		//hash function
		
		function checkHash(){
			var found = false;
			toggles.each(function(h3, i){
				if (window.location.href.indexOf(h3.title) > 0) {
					myAccordion.showThisHideOpen(stretchers[i]);
					found = true;
				}
			});
			return found;
		}
		
		if (!checkHash()) myAccordion.showThisHideOpen(stretchers[0]);
	}
	</script> --->
</head>
<body>
<div id="header">
<a id="vegexp_logo" href="/index.cfm">
	<img src="<cfoutput>#session.shop.skin.path#</cfoutput>vegexp_logo_small_greenbg.gif" alt="Vegetarian Express" />
</a>
		<h1>Web Control Panel</h1>
</div>
<div id="container">
		<div id="content">
		<h3 class="display" title="status"><a class="menutop" href="#status">Status</a></h3>
			<div class="stretcher">
				<div class="menuitem">
				<ol>
				<li><a title="Users Logged in" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=status&value=current">Current Status</a><li>
				<li><a title="Application Log" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=status&value=disconnect">Disconnect for Sage Backup</a><li>
				</ol>
				</div>
			</div>
			
			<h3 class="display" title="info"><a href="#info">Stats and logs</a></h3>
			<div class="stretcher">
				<div class="menuitem">
				<ol>
				<li><a title="Users Logged in" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=info&value=loggedinusers">Users Logged in</a><li>
				<li><a title="Application Log" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=info&value=applog">Application Log</a><li>
				<li><a title="Cron Task Log" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=info&value=crontsklog">Cron Task Log</a><li>
				<li><a title="Query Log" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=info&value=querylog">Query Log</a><li>
				<li><a title="Sage Web Service Log" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=info&value=sageWSlog">Sage Web Service Log</a><li>
				</ol>
				</div>
			</div>

			<h3 class="display" title="sched"><a href="#sched">Scheduled Jobs</a></h3>
			<div class="stretcher">
			<div class="menuitem">
			<ol>
				<li><a title="Job List" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=jobs&value=loggedinusers">Job List</a><li>
			</ol>
			</div>
			</div>

			<h3 class="display" title="products"><a href="#products">Products</a></h3>
			<div class="stretcher">
			<div class="menuitem">
			<ol>
				<li><a title="Stock List" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=products&value=list">Stock List</a><li>
				<li><a title="Categories" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=products&value=categories">Categories</a><li>
			</ol>
			</div>
			</div>

			<h3 class="display" title="editor"><a href="#editor">Edit Content</a></h3>
			<div class="stretcher">
			<div class="menuitem">
			<ol>
				<li><a title="Recipes" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=content&value=recipes">Recipes</a><li>
				<li><a title="Special Offers" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=content&value=specialoffers">Special Offers</a><li>
			</ol>
			</div>
			</div>
		</div>
</div>		
<div id="main">
<div id="breadcrumb"><cfoutput>#request.breadcrumb#</cfoutput></div>
<div id="content"><cfoutput>#content#</cfoutput></div>
</div>
<!--- 	<script type="text/javascript">
		Element.cleanWhitespace('content');
		init();
	</script> --->
</body>
</html>
