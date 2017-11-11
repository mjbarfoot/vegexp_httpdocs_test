					<div id="nav" class="clearfix">
						<div id="mainWSLinkWrap"	class="navbox">
							<div id="mainWSLink"   class="navbox">
								<span><a href="http://www.vegetarianexpress.co.uk">Vegetarian Express Website</a></span>
							</div>
						</div>
						
						
						<div id="navTelNumWrap"	class="navbox">
							<div id="navTelNum"   class="navbox">
								<span>01923 249714</span>
							</div>
						</div>
						
						<div id="navMyAccountWrap">
							<div id="navMyAccount">
								<a href="myAccount.cfm">My Account</a>
								<div id="navMyAccountLogin">
								   <cfif SESSION.AUTH.AccountID neq "">	
									 <cfoutput>Logged in: #session.auth.firstname# #session.auth.lastname#</cfoutput>
									 <span id="myAccountLinks"><a href="/myAccount.cfm">Edit my details</a> / <a href="/logout.cfm">logout</a></span>
									<cfelse>
									 <span><a href="/login.cfm">Login</a> / <a href="/register.cfm">Register</a></span><br/>
									 <span><a href="/forgot_pass.cfm">Forgot password?</a>	
									</cfif> 
								</div>							
							</div>
						</div>

						<div id="navBasketWrap">
							<div id="navBasket">
							<cfif (FindNoCase("basket.cfm", cgi.SCRIPT_NAME) eq 0) AND (FindNoCase("checkout.cfm", cgi.SCRIPT_NAME) eq 0) AND (FindNoCase("logout.cfm", cgi.SCRIPT_NAME) eq 0)>
								<a href="basket.cfm">Shopping Basket</a>
								<a id="basketEdit" href="basket.cfm"><img src="<cfoutput>#session.shop.skin.path#</cfoutput>nav_basket_edit.gif" alt="View and edit my shopping basket" /></a>
 								<div id="basketExpandWrapper">
									
									 <cfoutput>#session.basketContents.show()#</cfoutput>
									
									<div id="baskettotal">
										TOTAL: <span id="grandTotal" <cfif session.shopper.basket.getGrandTotal() lt session.auth.mov>class="movAlert"</cfif>>
                                            <cfif SESSION.Auth.isLoggedIn or SESSION.Auth.viewPrices>
                                                <cfoutput>&pound; #DecimalFormat(session.shopper.basket.getGrandTotal())#</cfoutput>
                                            </cfif>
                                        </span>
								 </div>
								</div>
							<cfelse>
							<span class="basketdisabled">Shopping Basket</span>
							</cfif>	
							</div>
						</div>

						<div id="navCheckOutWrap"	class="navbox">
							<div id="navCheckOut"   class="navbox">
								<a href="/checkout.cfm">Check out</a>
							</div>
						</div>
						
<!--- 						<div id="navRecipesWrap"	class="navbox">
							<div id="navRecipes"    class="navbox">
								<a href="/recipes.cfm">Recipes</a>
							</div>
						</div> --->
						
						<div id="navVeganWrap"		class="navbox">
							<div id="navVegan"      class="navbox">
								<a href="/search.cfm?fldProdFilter=Vegan&showProducts=true">All Vegan</a>
							</div>
						</div>
						
						<div id="navGlutenFreeWrap"	class="navbox">
							<div id="navGlutenFree" class="navbox">
								<a href="/search.cfm?fldProdFilter=GlutenFree&showProducts=true">All Gluten Free</a>	
							</div>
						</div>
						
						<div id="navOrganicWrap">
							<div id="navOrganic"    class="navbox">
								<a href="/search.cfm?fldProdFilter=Organic&showProducts=true">All Organic</a>
							</div>
						</div>
						
						<cfif isdefined("session.comments")>
						<div id="navCommentsWrap">
							<div id="navComments"    class="navbox">
								<a href="/comment.cfm?refURL=<cfoutput>#cgi.script_name#</cfoutput>">Comments</a>
							</div>
						</div>
						</cfif>
					</div>