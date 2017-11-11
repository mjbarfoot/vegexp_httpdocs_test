<div id="productListWrapper">
	<div id="productList">
		<cfoutput>#shopperBreadcrumbTrail#</cfoutput>
		<cfoutput>
		<div id="checkoutContainer">	
		<cfform id="checkoutForm" method="post" action="#xmlformat(cgi.SCRIPT_NAME)#" onsubmit="#IIF(NOT isCreditAuthorised, DE('return CCfrm.chkStartDate();'), DE(''))#">
			<input type="hidden" name="delbuilding" id="delbuilding" 	value="#deliveryAddress.building#" />
   			<input type="hidden" name="delline1" 	id="delline1" 		value="#deliveryAddress.line1#" />
			<input type="hidden" name="delline2" 	id="delline2" 		value="#deliveryAddress.line2#" />
			<input type="hidden" name="delline3" 	id="delline3" 		value="#deliveryAddress.line2#" />
			<input type="hidden" name="deltown" 	id="deltown" 		value="#deliveryAddress.town#" />
			<input type="hidden" name="delcounty" 	id="delcounty" 		value="#deliveryAddress.county#" />
			<input type="hidden" name="delpostcode" id="delpostcode"	value="#deliveryAddress.postcode#" />
								
		<span id="checkoutActions">
			<span id="checkoutTitle">Please check your order details below carefully before clicking "Confirm Order".<br /> A copy of these details will also be available in your confirmation email</span>
			<input name="frmSubmit" type="submit" value="Confirm Order" />
		</span>
		<div class="chkoutSec">
			<span class="chkoutSecTitle">Your items</span>			
			#shoppingList#
		</div>			
		<div class="chkoutSec">
			<span class="chkoutSecTitle">Delivery Details</span>			
			<p>Your items will be delivered on <span id="addDelDay">#SESSION.Auth.DelDay#</span> to:</p>
			<table id="delAddress" summary="Delivery address details">
			  <tr>
			    <td class="delColDesc">Building No/Name:</td>
				<td><span class="delField">#deliveryAddress.building#</span></td>
			  </tr>
			  <tr>
			    <td  class="delColDesc">Address:</td>
				<td><cfif deliveryAddress.line1 neq ""><span class="delField">#deliveryAddress.line1#</span><br /></cfif>
					<cfif deliveryAddress.line2 neq ""><span class="delField">#deliveryAddress.line2#</span><br /></cfif>
					<cfif deliveryAddress.line3 neq ""><span class="delField">#deliveryAddress.line3#</span><br /></cfif>
					<cfif deliveryAddress.town neq ""><span class="delField">#deliveryAddress.town#</span><br /></cfif>
					<cfif deliveryAddress.county neq ""><span class="delField">#deliveryAddress.county#</span><br /></cfif>
				</td>
			  </tr>
			  	  <tr>
			    <td class="delColDesc">Postcode:</td>
				<td><span class="delField">#deliveryAddress.Postcode#</span></td>
			  </tr>
			</table>	
		</div>
		<div class="chkoutSec">	
			<span class="chkoutSecTitle">Payment Details <cfif NOT isCreditAuthorised><img style="padding-left: 82px;" src="/resources/cardicons.gif" alt="icons of accepted credit cards" /></cfif></span>					
		</div>
		<cfif NOT isCreditAuthorised>
		  <cfinclude template="/views/ccform.cfm" />
		<cfelse>
			<div id="isCreditAuthorised">
			 &pound;#session.shopper.basket.getGrandTotal()# will be charged to your account.
			</div>	
		</cfif>  	 
		<div class="chkoutSec">	
			<span class="chkoutSecTitle">Notes</span>	
		    <ul id="ordNotes">
		     <li>Once you click "confirm" you will be given an order reference</li>
		 	 <li>You will receive a copy of all these details via email</li>
			 <li>If you need to cancel or change any order details please contact our sales team by 3pm for next day deliveries or within 24 hours of your delivery date for all other deliveries.</li>
			</ul> 					
		</div>
		<span id="checkoutActions">
			<span id="checkoutTitle">Please check your order details below carefully before clicking "Confirm Order".<br /></span>
			<input name="frmSubmit" type="submit" value="Confirm Order" />
		</span>
		</cfform>
	</div>
	</cfoutput>
	</div>
</div>	