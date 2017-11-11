<cfprocessingdirective suppresswhitespace="true">
<cfsilent>
<cfxml variable="myContent">
			<div id="content">
		
<!--- 						<a href="##" id="a-tabpic-offers"><img id="tabpic-offers" 		  src="/resources/home-tabpic-offers.gif" alt="special offers"  /></a>	 --->

						<div id="welcome-msg-wrapper">
							<span id="welcome-msg-span">Welcome to our <span id="welcome-msg-span-green">Online Ordering Facility</span></span>

							<p>Please log in to place an order, or feel free just to browse our extensive range of products.</p>

							 <p><span id="welcome-msg-span-nc">New to Vegetarian Express? </span><br/>  Become a Customer and set up your account today by completing our <a href="/register.cfm">registration form</a>.
							 <br/><br/> Alternatively call us on 01923 249714 or <a href="mailto:sales@vegexp.co.uk">email us</a> to discuss your credit requirements.
							</p>

							<p><span  id="welcome-msg-span-ec">Already a Customer?<br/> <a href="/register.cfm">Register online</a></span> to start using our order portal.</p>
						</div>
			</div>
</cfxml>
<cfset content=replace(toString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
</cfsilent>
<cfinclude template="/views/default.cfm">
</cfprocessingdirective>
