			<div id="test-banner" style="width: 100%; background-color: #f2f2f2; height: 30px; text-align: center; color: #ccc; vertical-align: middle"><h2 style="font-size: 1.4em;">Test Server <cfoutput>#cgi.REMOTE_ADDR#</cfoutput></h2></div>
			<div id="head_top" class="clearfix">
					<span id="logo_wrapper" class="clearfix">
					<a id="vegexp_logo" href="http://www.vegetarianexpress.co.uk"><img src="<cfoutput>#session.shop.skin.path#</cfoutput>vegexp_logo_350x151.png" alt="Vegetarian Express Website" /></a>
					</span>
					<div id="searchbar">
						<form id="frmsearch" method="get" action="search.cfm">
						<fieldset>
						  <label for="pQ">Search:</label>
						   <span id="fldsearchshadow"><input type="text" id="pQ" name="pQ" /></span>
						   <input type="submit" id="frmsubmit" value="Go" />
						 </fieldset>	
						<fieldset>
						    <a id="advsearch" href="/advanced_search.cfm">Advanced Search</a>
					   </fieldset>
						</form>
					</div>
					<div id="infobar">
						<cfoutput>
							<cfif session.shopper.prod_filter neq "All">
								<span id="info-filter-text">Filter:</span>
								<span id="info-filter-wrap">
								<span id="info-filter-#session.shopper.prod_filter#">#session.shopper.prod_filter#</span>
								</span>
							</cfif>
							<!--->
							<select id="fldProdFilter" name="fldProdFilter" onchange="document.getElementById('frmProdFilter').submit();">
							<option value="All" <cfif session.shopper.prod_filter eq "All">selected="selected"</cfif>>ALL PRODUCTS</option>
							<option value="Organic" <cfif session.shopper.prod_filter eq "Organic">selected="selected"</cfif>>ORGANIC</option>
							<option value="Vegan" <cfif session.shopper.prod_filter eq "Vegan">selected="selected"</cfif>>VEGAN</option>
							<option value="GlutenFree" <cfif session.shopper.prod_filter eq "GlutenFree">selected="selected"</cfif>>GLUTEN FREE</option>
							</select> --->
						   <cfif session.auth.delday neq "">
						    <span id="delDay<cfif session.shopper.prod_filter eq 'All'>NoLeftPad</cfif>">Your next delivery day is:<span id="delDayValue">#IIF(FindNoCase("(week)", session.auth.delday), DE(UCASE(Left(session.auth.delday, 3) & " (week)")), DE(UCASE(Left(session.auth.delday, 3))))#</span></span>
							</cfif>
	            <cfif session.auth.mov neq 0>
	                <span id="mov">Minimum order value: <span id="movValue">&pound; #decimalFormat(session.auth.mov)#</span></span>
	            </cfif>
						</cfoutput>
					</div>
				</div>
