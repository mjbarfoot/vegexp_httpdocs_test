<div id="ccFieldset">
<fieldset>
<p>  
<label for="card">Card type:</label> 
 <select name="card_type" id="card_type">
    <option value="Master Card" <cfif isdefined("session.shopper.card_type") AND session.shopper.card_type eq "Master Card">selected="selected"</cfif>>Master Card</option>
    <option value="Delta" 		<cfif isdefined("session.shopper.card_type") AND session.shopper.card_type eq "Delta">selected="selected"</cfif>>Visa Debit, Delta or Electron</option>
    <option value="Visa" 		<cfif isdefined("session.shopper.card_type") AND session.shopper.card_type eq "Visa">selected="selected"</cfif>>Visa</option>
    <option value="Switch" 		<cfif isdefined("session.shopper.card_type") AND session.shopper.card_type eq "Switch">selected="selected"</cfif>>Switch/UK Maestro</option>
	<option value="Solo"		<cfif isdefined("session.shopper.card_type") AND session.shopper.card_type eq "Solo">selected="selected"</cfif>>Solo</option>
   </select>
</p>
<p>
	<label for="card_no">Card number:</label>
	<cfinput type="text" name="card_no" id="card_no" value="" maxlength="19" validate="creditcard" required="true" message="Please enter a valid credit card number" />
</p>
<p>
	<label for="customer">Card holder:</label>
	<cfif NOT isdefined("session.shopper.customer")><cfset session.shopper.customer=""></cfif>
	<cfinput type="text" name="customer" id="customer" value="#session.shopper.customer#" required="true" message="Please enter your name as it appears on the card" />
</p>
<p> 
	<label for="start_date">Start Date:</label>
	<cfinput type="text" class="medsmall" name="start_date" id="start_date" value="" maxlength="5" mask="99/99" />
	<label class="fldinline" for="expiry">Expiry Date:</label>
	<cfinput type="text" class="medsmall" name="expiry" id="expiry" value="" maxlength="5" required="true" message="Please enter a valid expiry date" mask="99/99" />
</p>
<p>

</p>
<p>
	<label for="card">Issue Number (Switch only):</label>
	<cfinput class="small" type="text" name="issue" id="issue" value="" />
</p>
<p>
	<label for="card">Security Code:</label>
	<cfinput class="small" type="text" name="cv2" id="cv2" value="" maxlength="4" required="true" message="Please enter your security code (the last 3/4 digits on the reverse of your card)" />
</p>
</fieldset>
<fieldset>
<p>
	<label style="width:350px;" for="billAddress">Card billing address is the same as my delivery address:</label>
	<cfinput class="small" type="checkbox" name="useDelAddress" id="useDelAddress" checked="false" value="1" onchange="CCfrm.useDelAddress();" />
</p>
</fieldset>
<fieldset>
<div id="ccBillAddress">
	<p>
		<label for="billBuilding">Building No./Name:</label>
		<cfif NOT isdefined("session.shopper.billBuilding")><cfset session.shopper.billBuilding=""></cfif>
		<cfinput class="med" type="text" name="billBuilding" id="billBuilding"  value="#session.shopper.billBuilding#"  />
	</p>
    <p>
		<label for="billPostcode">Postcode:</label>
		<cfif NOT isdefined("session.shopper.billPostcode")><cfset session.shopper.billPostcode=""></cfif>
		<cfinput class="medsmall" type="text" name="billPostcode" id="billPostcode"  value="#session.shopper.billPostcode#" />
		<cfinput type="button" class="btn" name="findAddress" value="Find Address"  onclick="pcaFastAddressBegin()" /> 
	</p>
	<p>
		<label for="billLine1">Address Line 1:</label>
		<cfif NOT isdefined("session.shopper.billLine1")><cfset session.shopper.billLine1=""></cfif>
		<cfinput class="med" type="text" name="billLine1" id="billLine1"  value="#session.shopper.billLine1#" />
	</p>
	<p>
		<label for="billLine2">Address Line 2:</label>
		<cfif NOT isdefined("session.shopper.billLine2")><cfset session.shopper.billLine2=""></cfif>
		<cfinput class="med" type="text" name="billLine2" id="billLine2" value="#session.shopper.billLine2#"  />
	</p>
	<p>
		<label for="billLine3">Address Line 3:</label>
		<cfif NOT isdefined("session.shopper.billLine3")><cfset session.shopper.billLine3=""></cfif>
		<cfinput class="med" type="text" name="billLine3" id="billLine3" value="#session.shopper.billLine3#"  />
	</p>
	<p>
		<label for="billTown">Town:</label>
		<cfif NOT isdefined("session.shopper.billTown")><cfset session.shopper.billTown=""></cfif>
		<cfinput type="text" name="billTown" id="billTown"  value="#session.shopper.billTown#" />
	</p>
	<p>
		<label for="billCounty">County:</label>
		<cfif NOT isdefined("session.shopper.billCounty")><cfset session.shopper.billCounty=""></cfif>
		<cfinput type="text" name="billCounty" id="billCounty"  value="#session.shopper.billCounty#" />
	</p>
</div>
</fieldset>
</div>