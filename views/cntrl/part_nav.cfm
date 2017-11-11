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
			
			<h3 class="display" title="customers"><a href="#customers">Customers</a></h3>
			<div class="stretcher">
				<div class="menuitem">
				<ol>
				<li><a title="Users Logged in" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=customers&value=email">Update Email</a><li>
				<li><a title="Setup Favourites" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=customers&value=setupFavourites">Setup Favourites</a><li>
				<li><a title="Refresh Customer Data" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=customers&value=importCustomerData">Refresh Customer Data</li>
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
				<li><a title="Categories" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=products&value=categoryList">Categories</a><li>
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
			
			<h3 class="display" title="tests"><a href="#tests">Sage Gateway Tests</a></h3>
			<div class="stretcher">
			<div class="menuitem">
			<ol>
				<li><a title="GetCustomerList" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=tests&value=ListCustomers">ListCustomers</a><li>
				<li><a title="GetCustomerListByPartialPostcode" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=tests&value=ListCustomersByPartialPostcode">ListCustomersByPartialPostcode</a><li>
				<li><a title="PlaceSalesOrder" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=tests&value=PlaceSalesOrder">PlaceSalesOrder</a><li>
				<li><a title="DeleteSalesOrder" href="<cfoutput>#cgi.script_name#</cfoutput>?ev=tests&value=CancelSalesOrder">CancelSalesOrder</a><li>
			</ol>
			</div>
			</div>
			
		</div>