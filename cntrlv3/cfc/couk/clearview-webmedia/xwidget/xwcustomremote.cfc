<!--- 
	Component: xwcustomremote.cfc
	File: /cfc/couk/clearview-webmedia/xwidget/xwcustomremote.cfc
	Description: Servers Taconiteb GET requests with xwtable content
	Author: Matt Barfoot
	Date: 27/06/2007
	Revisions:
	
	--->
	
<cfcomponent name="xwcustomremote" output="false" displayname="xwcustomremote" 
hint="cusom functions are defined here. If a column in a table needs to do something special then a custom function is defined to do the job. 
Custom functions parse any passed bind (query) values to make sure they are XML compliant strings. If they include XHTML, format any bind variables before adding XHTML">

<cfobject component="xwutil" 			name="xwutil">

<cffunction name="emptyFn" access="public" returnType="string" hint="">
<cfscript>
return "";
</cfscript>
</cffunction>


<cffunction name="getShowingXofY" access="remote" returntype="string" output="false">
<cfargument name="ElementID" type="string" required="true">
<cfargument name="TableID" type="string" required="true">

<cfsavecontent variable="myContent"> 
<cfoutput>
<taconite-root xml:space="preserve">
<taconite-replace  contextNodeID="#ARGUMENTS.ElementID#" parseInBrowser="true">
<span id="qsa_ah_woqueue_tableheader">
<cfoutput>Showing <span class="txtBlue">#REQUEST.xwtable.getValue(ARGUMENTS.TableID,"startrow")#</span> to <span class="txtBlue">#REQUEST.xwtable.getValue(ARGUMENTS.TableID,"endrow")#</span> of <span class="txtBlue">#REQUEST.xwtable.getValue(ARGUMENTS.TableID,"sqlquery.recordcount")#</span> records</cfoutput> 
</span>
</taconite-replace>
</taconite-root>
</cfoutput>
</cfsavecontent>
<cfreturn myContent />
</cffunction>

<!---*** Duplicate of Method getWoDetails, 
but if called passes additional argument (historic) to method getWoDetails ***--->
<cffunction name="getWOHistoryDetails" access="remote" returntype="string" output="false">
<cfargument name="ElementID" type="string" required="true">
<cfargument name="WONUM" type="string" required="true">
<cfreturn getWoDetails(ARGUMENTS.ElementID, ARGUMENTS.WONUM, true) />
</cffunction>

<cffunction name="getWoDetails" access="remote" returntype="string" output="false">
<cfargument name="ElementID" type="string" required="true">
<cfargument name="WONUM" type="string" required="true">
<cfargument name="Historic" type="boolean" required="false" default="false">

<cfscript>
if (ARGUMENTS.historic) {
myWoDetailQry = APPLICATION.ob.qs_dao.getWOHistoryDetail(ARGUMENTS.WONUM);
} else {
myWoDetailQry = APPLICATION.ob.qs_dao.getWODetail(ARGUMENTS.WONUM);	
}
</cfscript>

<cfsavecontent variable="myContent"> 
<cfoutput query="myWoDetailQry">
<taconite-root xml:space="preserve">
<taconite-insert-after  contextNodeID="#ARGUMENTS.ElementID#" parseInBrowser="true">
<tr id="#ElementID#_data" class="woDataRow">
<td class="lhscol rhscol" style="text-align: left;" colspan="10"> 
 	<div id="woDetailForm">
		<input type="hidden" id="woDetail_wonum" value="#ARGUMENTS.WONUM#" />
		<fieldset id="PropDetails"> 
			<label id="lbl_propref" for="propref">PROPERTY REFERENCE</label>
			<input readonly="true" type="text" id="propref" name="propref" value="#xmlformat(propref)#" />
			<label id="lbl_propname" for="propref">PROPERTY NAME</label>
			<input readonly="true" type="text" id="propname" name="propname" value="#xmlformat(propname)#" />		
			<label id="lbl_district" for="propref">DISTRICT</label>
			<input readonly="true" type="text" id="district" name="district" value="#xmlformat(district)#" />
			<label id="lbl_description" for="Description">DESCRIPTION</label>
			<textarea readonly="true" id="description" name="description">#xmlformat(LONGDESCRIPTION)#</textarea>
		</fieldset>
		<fieldset id="PropDates"> 
			<label id="lbl_date_requested" for="propref">DATE REQUESTED</label>
			<input readonly="true" type="text" id="date_requested" name="date_requested" value="#dateformat(date_requested, 'dd/mm/yyyy')#" />		
			<label id="lbl_date_phycomp" for="date_phycomp">DATE PHYS COMP</label>
			<input readonly="true" type="text" id="date_phycomp" name="date_phycomp" value="#dateformat(date_phycomp, 'dd/mm/yyyy')#" />
			<label id="lbl_date_fincomp" for="date_fincomp">DATE FIN COMP</label>
			<input readonly="true" type="text" id="date_fincomp" name="date_fincomp" value="#dateformat(date_fincomp, 'dd/mm/yyyy')# #timeformat(date_fincomp, 'HH:MM TT')#" />
			<label id="lbl_tenure" for="tenure">TENURE</label>
			<input readonly="true" type="text" id="tenure" name="tenure" value="#xmlformat(tenure)#" />
			<label id="lbl_opuscode" for="opuscode">OPUSCODE</label>
 			<input readonly="true" type="text" id="opuscode" name="opuscode" value="#xmlformat(opuscode)#" />
		</fieldset>
		<fieldset id="PropMIS"> 
			<label id="lbl_propmis1" for="propmis1">PROPMIS1</label>
			<input readonly="true" type="text" id="propmis1" name="propmis1" value="#xmlformat(propmis1)#" />		
			<label id="lbl_propmis2" for="propmis2">PROPMIS2</label>
			<input readonly="true" type="text" id="propmis2" name="propmis2" value="#xmlformat(propmis2)#" />
			<label id="lbl_costcentre" for="costcentre">COST CENTRE 1</label>
			<input readonly="true" type="text" id="costcentre" name="costcentre" value="#xmlformat(costcentre)#" />
			<label id="lbl_costcentre2" for="costcentre2">COST CENTRE 2</label>
			<input readonly="true" type="text" id="costcentre2" name="costcentre2" value="#xmlformat(costcentre2)#" />
			<label id="lbl_pcmcode" for="pcmcode">PCMCODE</label>
 			<input readonly="true" type="text" id="pcmcode" name="pcmcode" value="#xmlformat(pcmcode)#" />
			<label id="lbl_criticality" for="criticality">CRITICALITY</label>
 			<input readonly="true" type="text" id="criticality" name="criticality" value="#xmlformat(criticality)#" />
		</fieldset>
		<fieldset id="AccAudit"> 
			<label id="lbl_accountaudited" for="accountaudited">ACCOUNT<br /> AUDITED</label>
			<input readonly="true" type="checkbox" id="accountaudited" name="accountaudited" value="#xmlformat(accountaudited)#" #IIF(accountaudited eq 1, DE('checked="true"'), DE(''))# />		
<!--- 			<label id="lbl_withdrawnaccstatus" for="withdrawnaccstatus">  WITHDRAWN ACC STATUS</label>
			<input readonly="true" type="text" id="withdrawnaccstatus" name="withdrawnaccstatus" value="#xmlformat(withdrawnaccstatus)#" /> --->
			<label id="lbl_srfobtained" for="srfobtained">SRF<br />OBTAINED</label>
			<input readonly="true" type="checkbox" id="srfobtained" name="srfobtained" value="#xmlformat(srfobtained)#" #IIF(srfobtained eq 1, DE('checked="true"'), DE(''))# />
			<label id="lbl_jobpack" for="jobpack">JOB<br />PACK</label>
			<input readonly="true" type="checkbox" id="jobpack" name="jobpack" value="#xmlformat(jobpack)#" #IIF(jobpack eq 1, DE('checked="true"'), DE(''))# />
			<label id="lbl_amountapproved" for="amountapproved">AMOUNT APPROVED</label>
			<input readonly="true" type="text" id="amountapproved" name="amountapproved" value="#xmlformat(amountapproved)#" />
			<label id="lbl_approvedby" for="approvedby">APPROVED BY</label>
 			<input readonly="true" type="text" id="approvedby" name="approvedby" value="#xmlformat(approvedby)#" />
			<label id="lbl_approveddate" for="approveddate">APPROVED DATE</label>
 			<input readonly="true" type="text" id="approveddate" name="approveddate" value="#dateformat(approveddate, 'dd/mm/yyyy')# #timeformat(approveddate, 'hh:mm tt')#" />
			<label id="lbl_compthreshdeduc" for="compthreshdeduc">COMP T'HLD<br />DEDUC</label>
 			<input readonly="true" type="checkbox" id="compthreshdeduc" name="compthreshdeduc" value="#xmlformat(compthreshdeduc)#" #IIF(compthreshdeduc eq 1, DE('checked="true"'), DE(''))# />
			<label id="lbl_mannedsite" for="mannedsite">MANNED<br />SITE</label>
 			<input readonly="true" type="checkbox" id="mannedsite" name="mannedsite" value="#xmlformat(mannedsite)#" #IIF(mannedsite eq 1, DE('checked="true"'), DE(''))# />
			<label id="lbl_linkedjob" for="linkedjob">LINKED JOB</label>
 			<input readonly="true" type="text" id="linkedjob" name="linkedjob" value="#xmlformat(linkedjob)#" /> 
		</fieldset>
		<fieldset id="AccStatus"> 
<!--- 			<label id="lbl_accountstatus" for="accountstatus">ACCOUNT STATUS</label>
			<input readonly="true" type="text" id="accountstatus" name="accountstatus" value="#xmlformat(accountstatus)#" />		 --->
			<label id="lbl_taxalloc" for="taxalloc">TAX ALLOCATION</label>
			<input readonly="true" type="text" id="taxalloc" name="taxalloc" value="#xmlformat(taxalloc)#" />
			<label id="lbl_keyworddescofwork" for="keyworddescofwork">KEY DESCRIPTION OF WORK</label>
			<textarea readonly="true" id="keyworddescofwork" name="keyworddescofwork">#xmlformat(keyworddescofwork)#</textarea>
		</fieldset>
		<fieldset id="PaymentClass"> 
			<label id="lbl_paymentclassif" for="paymentclassif">PAYMENT<BR />CLASSIFICATION</label>
			<input readonly="true" type="text" id="paymentclassif" name="paymentclassif" value="#xmlformat(paymentclassif)#" />		
			<label id="lbl_ibuyitemcode" for="ibuyitemcode">IBUY ITEM<BR />CODE</label>
			<input readonly="true" type="text" id="ibuyitemcode" name="ibuyitemcode" value="#xmlformat(ibuyitemcode)#" />
			<label id="lbl_commodcode" for="commodcode">COMMODITY<BR />CODE</label>
			<input readonly="true" type="text" id="commodcode" name="commodcode" value="#xmlformat(commodcode)#" />
			<label id="lbl_commoddesc" for="commoddesc">COMMODITY<BR />DESCRIPTION</label>
			<input readonly="true" type="text" id="commoddesc" name="commoddesc" value="#xmlformat(commoddesc)#" />
			<label id="lbl_legalentity" for="legalentity">LEGAL<BR />ENTITY</label>
			<input readonly="true" type="text" id="legalentity" name="legalentity" value="#xmlformat(legalentity)#" />
			<input type="button" id="btnviewjournals" name="btnviewjournals" value="VIEW JOURNALS" />
		</fieldset>
		<fieldset id="AmountClaimed"> 
			<label id="lbl_amtclaimedlab" for="amtclaimedlab">AMT CLM'D<BR />LABOUR</label>
			<input readonly="true" type="text" id="amtclaimedlab" name="amtclaimedlab" value="#decimalformat(amtclaimedlab)#" />		
			<label id="lbl_amtclaimedmeasure" for="amtclaimedmeasure">AMT CLM'D<BR />MEASURE</label>
			<input readonly="true" type="text" id="amtclaimedmeasure" name="amtclaimedmeasure" value="#decimalformat(amtclaimedmeasure)#" />
			<label id="lbl_amtclaimedmaterials" for="amtclaimedmaterials">AMT CLM'D<BR />MATERIALS</label>
			<input readonly="true" type="text" id="amtclaimedmaterials" name="amtclaimedmaterials" value="#decimalformat(amtclaimedmaterials)#" />
			<label id="lbl_amtclaimedother" for="amtclaimedother">AMT CLM'D<BR />OTHER</label>
			<input readonly="true" type="text" id="amtclaimedother" name="amtclaimedother" value="#decimalformat(amtclaimedother)#" />
			<label id="lbl_amclaimedtotal" for="amclaimedtotal">AMT CLM'D<BR />TOTAL</label>
			<input readonly="true" type="text" id="amclaimedtotal" name="amclaimedtotal" value="#decimalformat(amclaimedtotal)#" />
			<label id="lbl_valreceived" for="valreceived">VALUE RECV'D<BR />FOR AUDIT</label>
			<input readonly="true" type="text" id="valreceived" name="valreceived" value="#decimalformat(valreceived)#" />
			<label id="lbl_agreedfinalaccount" for="agreedfinalaccount">AGREED FINAL<BR /> ACCOUNT</label>
			<input readonly="true" type="text" id="agreedfinalaccount" name="agreedfinalaccount" value="#decimalformat(agreedfinalaccount)#" />
			<label id="lbl_auditdiff" for="auditdiff">AUDIT<BR />DIFFERENCE</label>
			<input readonly="true" type="text" id="auditdiff" name="auditdiff" value="#decimalformat(auditdiff)#" />			
		</fieldset>
		<fieldset id="Payables"> 
			<label id="lbl_grosspayable" for="grosspayable">GROSS<BR />PAYABLE</label>
			<input readonly="true" type="text" id="grosspayable" name="grosspayable" value="#decimalformat(grosspayable)#" />		
			<label id="lbl_auditpctdeduc" for="auditpctdeduc">AUDIT %<BR />DEDUC</label>
			<input readonly="true" type="text" id="auditpctdeduc" name="auditpctdeduc" value="#decimalformat(auditpctdeduc)#" />
			<label id="lbl_netpayable" for="netpayable">NET PAYABLE</label>
			<input readonly="true" type="text" id="netpayable" name="netpayable" value="#decimalformat(netpayable)#" />
			<label id="lbl_profit" for="profit">PROFIT</label>
			<input readonly="true" type="text" id="profit" name="profit" value="#decimalformat(profit)#" />
			<label id="lbl_kpiprofitabatement" for="kpiprofitabatement">KPI PROFIT<BR />ABATEMENT</label>
			<input readonly="true" type="text" id="kpiprofitabatement" name="kpiprofitabatement" value="#decimalformat(kpiprofitabatement)#" />
			<label id="lbl_totaldue" for="totaldue">TOTAL DUE<BR />TO SUPPLIER</label>
			<input readonly="true" type="text" id="totaldue" name="totaldue" value="#decimalformat(totaldue)#" />
			<label id="lbl_valnumber" for="valnumber">VALUATION<BR />NUMBER</label>
			<input readonly="true" type="text" id="valnumber" name="valnumber" value="#xmlformat(valnumber)#" />
			<label id="lbl_certnum" for="certnum">CERTIFICATE<BR />NUMBER</label>
			<input readonly="true" type="text" id="certnum" name="certnum" value="#xmlformat(certnum)#" />			
		</fieldset>
	</div> 
</td>
</tr>
</taconite-insert-after>
<taconite-execute-javascript parseInBrowser="true">
<script type="text/javascript">
JOURNALS.init();
</script>
</taconite-execute-javascript>
</taconite-root>
</cfoutput>
</cfsavecontent>
<cfreturn myContent />
</cffunction>

</cfcomponent>