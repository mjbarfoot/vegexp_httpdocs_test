<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
 <head>
  <title>Vegetarian Express Skeleton Layout</title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <link rel="stylesheet" type="text/css" href="/c/skel_layout.css" />
  <link rel="stylesheet" type="text/css" href="/c/skel_import.css" />
  </head>
 <body> 	
	 <div id="wrapper">
		<div id="head">
				<div id="head_top" class="clearfix">
					<span id="logo_wrapper" class="clearfix">
					<a id="vegexp_logo" href="/index.cfm"><img src="/pix/vegexp_logo.gif" alt="Vegetarian Express" /></a>
					</span>
					<div id="searchbar">
						<form id="frmsearch" method="post" action="search.cfm">
						<fieldset>
						<label for="fldsearchtxt">Search:</label>
						<span id="fldsearchshadow"><input type="text" id="fldsearchtxt" name="fldsearchtxt" /></span>
						<input type="submit" id="frmsubmit" value="Go" />
						<a id="advsearch" href="/advanced_search.cfm">Advanced Search</a>
						</fieldset>	
						</form>
					</div>
					<div id="infobar"> 
						<cfoutput>
						<form id="frmModeSelect" method="post" action="#cgi.script_name#">
						<fieldset>
						<label for="fldModeSelect">Showing:</label>
						<select id="fldModeSelect">
						<option value="All" selected="selected">ALL PRODUCTS</option>
						<option value="Organic">ORGANIC</option>
						<option value="Vegan">VEGAN</option>
						<option value="GlutenFree">GLUTEN FREE</option>
						</select>
						<label id="label_fldDelDay" for="fldDelDay">Your next delivery day is:</label>
						<input type="text" id="fldDelDay" value="Tues" readonly="readonly" />
						</fieldset>
						</form>
						</cfoutput>
					</div> 
				</div>
				<div id="head_tabs">
					<ol>
						<li class="tabfav"><a href="favourites.cfm">Favourites</a></li>
						<li class="tabamb"><a href="ambient.cfm">Ambient</a></li>
						<li class="tabfrz"><a href="frozen.cfm">Frozen</a></li>
						<li class="tabchl"><a href="chilled.cfm">Chilled</a></li>
						<li class="tabspc"><a href="offers.cfm">Special Offers</a></li>
						<li class="tabhome"><a href="home">Home</a></li>
					</ol>
				</div>	
			</div> 
			<div id="body_topborder"></div>
			<div id="body" class="clearfix">		
					<div id="nav" class="clearfix">
						<div id="navMyAccountWrap"  class="navbox">
							<div id="navMyAccount"  class="navbox">
								<a href="myAccount.cfm">My Account</a>
							</div>
						</div>
						
						<div id="navBasketWrap"		class="navbox">
							<div id="navBasket"     class="navbox">
								<a href="Basket.cfm">Shopping Basket</a>
							</div>
						</div>
						
						<div id="navCheckOutWrap"	class="navbox">
							<div id="navCheckOut"   class="navbox">
								<a href="CheckOut.cfm">Check out</a>
							</div>
						</div>
						
						<div id="navRecipesWrap"	class="navbox">
							<div id="navRecipes"    class="navbox">
								<a href="Recipes.cfm">Recipes</a>
							</div>
						</div>
						
						<div id="navVeganWrap"		class="navbox">
							<div id="navVegan"      class="navbox">
								<a href="Vegan.cfm">Vegan</a>
							</div>
						</div>
						
						<div id="navGlutenFreeWrap"	class="navbox">
							<div id="navGlutenFree" class="navbox">
								<a href="GlutenFree.cfm">Gluten Free</a>	
							</div>
						</div>
						
						<div id="navOrganicWrap">
							<div id="navOrganic"    class="navbox">
								<a href="index.cfm?displayMode=Organic">Organic</a>
							</div>
						</div>
					</div>
					<div id="content">
						<a href="##" id="a-tabpic-favourites"><img id="tabpic-favourites" src="/resources/home-tabpic-favourites.gif"  alt="favourites" /></a>
						<a href="##" id="a-tabpic-ambient"><img id="tabpic-ambient" 	  src="/resources/home-tabpic-ambient.gif" alt="ambient"  /></a>
						<a href="##" id="a-tabpic-frozen"><img id="tabpic-frozen" 		  src="/resources/home-tabpic-frozen.gif" alt="frozen"  /></a>
						<a href="##" id="a-tabpic-chilled"><img id="tabpic-chilled" 	  src="/resources/home-tabpic-chilled.gif" alt="chilled"  /></a>
						<a href="##" id="a-tabpic-offers"><img id="tabpic-offers" 		  src="/resources/home-tabpic-offers.gif" alt="special offers"  /></a>	
						
						<div id="welcome-msg-wrapper">
							<span id="welcome-msg-span">Welcome to <span id="welcome-msg-span-green">Vegetarian Express</span></span>
							<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. 
							Proin vestibulum pharetra ante. Maecenas auctor, diam sit 
							amet sagittis pulvinar, sem eros accumsan lectus, blandit interdum 
							velit dui id nulla. Mauris sem leo, ullamcorper et, iaculis vel, 
							tincidunt a, sem. Curabitur vitae augue. 	
							</p>
						</div>
					
					</div>
					<div id="ordhot_wrapper">
						<span id="hotline">Sales Office: <span id="hot_telnum">01923 249714</span></span>
						<span id="nextday">Orders must be placed by 3.30pm for next day delivery</span>
					</div>
			</div>
			<div id="foot">
				
				<a href="legal.html">Legal Information</a>
				|
				<a href="privacy.html">Privacy Policy</a>
				|
				<a href="contact.cfm">Contact Us</a>
				<span id="copyR">&copy; 2006 Vegetarian Express. All Rights Reserved</span>
			</div>
	</div>
 </body>
</html>
			<!---<div class="box" id="boxContent">
		 		A drop shadow around a box
		 	</div> --->