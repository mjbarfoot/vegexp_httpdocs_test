<cfset  tickBegin=getTickCount()>
<cfset  tickEnd=0>

<cfinvoke
	webservice="https://www.secpay.com/java-bin/services/SECCardService?wsdl"
	method="validateCardFull"
	mid="secpay" 
	vpn_pswd="secpay"
	trans_id="123456_test"
	ip="195.137.79.165"
	name="Mr Cardholder"
	card_number="4444333322221111"
	amount="50.00"
	expiry_date="0906"
	issue_number=""
	start_date=""
	order=""
	shipping=""
	billing=""
	options="test_status=true,dups=false,card_type=Visa"
	returnVariable="authResponse"
	>

<cfscript>
tickEnd=getTickCount();
tickinterval=(tickend-tickbegin)/1000;
</cfscript>

<cfoutput>Response time: #tickinterval# seconds <br />
<br />
Response String: #authResponse#
</cfoutput>
	

                        