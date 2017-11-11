<!--- 
	Filename: 	 /cfc/cntrl/customers.cfm 
	Created by:  Matt Barfoot - Clearview Webmedia Limited
	Purpose:     Methods for customer related control panel events
	Date: 		 15/09/2006
	Revisions:
--->

<cfcomponent output="false" name="event" displayname="event" hint="Methods for control panel events">

<!--- / Object declarations / --->
<cfscript>
VARIABLES.cntrl_do 	= createObject("component", "cfc.cntrl.do"); 
VARIABLES.util 		= createObject("component", "cfc.cntrl.util"); 
</cfscript>

<!--- *** INIT Method *** --->
<cffunction name="init" access="public" returnType="any" output="false">
<cfscript> 
return this;
</cfscript>
</cffunction> 


<!--- *** Update a customers email *** --->
<cffunction name="email" access="public" returnType="any" output="false">
<cfscript>
var Str="";
if (isdefined("form.fldSubmit")) {
Str = VARIABLES.cntrl_do.updateEmail(form.accountCode, form.emailAddress);
return "<div><p style='padding: 0em 0em 2em; font-size: 0.9em;'>"  
		& Str & "</p></div>" & getForm("updateEmail");	
} else {
Str = getForm("updateEmail");	
return Str;	
}
</cfscript>

</cffunction>

<!--- *** UPLOAD DATA EXPORTED FROM MS ACCESS *** --->
<cffunction name="importCustomerData" access="public" returnType="any" output="false">
<cfscript>
var Str="";
var myFile="";
var myData="";
var myQuery="";

// if form submitted 
if (isdefined("form.fldSubmit")) {
	
	//create query2csv object
	try {
		oCSV = createObject('component','cfc.lib.redbd.csv');
	}
	catch (Application exVar) {return "Could not find/load cfc.lib.redbd.csv.cfc";}	

	
	//upload the file
	myFile = VARIABLES.util.file("upload", "", "fldCustDataFile");
	
	//was the file saved
	if (myFile.fileWasSaved) {
		//read the file 
		myData =  VARIABLES.util.file("read",  myFile.serverFile, "");
	} else {
		// file was not saved, try again
	  Str="<span style='color:red'>We could save your file this time, please try again...</span>" & getForm("importCustomerData");
	}
	
	//read the file into a query object
	myQuery = oCSV.csv2query(myData);
	
	Str = VARIABLES.util.dump(myQuery);
	return Str;	

} else {
Str = getForm("importCustomerData");	
return Str;	
}


</cfscript>
</cffunction>


<cffunction name="getForm" access="private" returntype="string" outoutpu="false">
<cfargument name="formname" required="true" type="string" />

<cfswitch expression="#ARGUMENTS.formname#">
<cfcase value="updateEmail">
	<cfxml variable="myContent">
	<cfoutput>
	<div>
	<style>
	p {padding: 6px 0em; font-size: 0.9em;}
	</style>	
	<form id="frmPartPostcode" name="frmPartPostcode" method="post">
 		<p>
		<span>Enter Customer Account code and new email address below:</span><br />
		</p>
		<p>
		<label for="accountCode">Account Code:</label> 
		<input type="text" id="accountCode" name="accountCode" size="8" /> 
		</p>
		<p>
		<label for="emailAddress">Email Address:</label> 
		<input type="text" id="emailAddress" name="emailAddress" style="width: 250px;" /> 
		</p>
		<p>
			<input type="submit" id="fldSubmit" name="fldSubmit" value="submit" />		
		</p>
		</form>
	</div>	 
	</cfoutput>
	</cfxml>
</cfcase>
<cfcase value="importCustomerData">
	<cfxml variable="myContent">
	<cfoutput>
	<div>
	<style>
	p {padding: 6px 0em; font-size: 0.9em;}
	</style>	
	<form id="frmimportCustomerData" name="frmImportCustomerData" method="post" enctype="multipart/form-data">
 		<p>
		<span>Please select the CSV file containing the customer data:</span>
		</p>
		<p>
		<label for="accountCode">File name:</label> 
		<input type="file" id="fldCustDataFile" name="fldCustDataFile" /> 
		</p>
		<p>
			<input type="submit" id="fldSubmit" name="fldSubmit" value="submit" />		
		</p>
		</form>
	</div>	 
	</cfoutput>
	</cfxml>
</cfcase>
<cfdefaultcase>
<!--- nothing --->
</cfdefaultcase>
</cfswitch>


<cfset myContent=replace(ToString(myContent), '<?xml version="1.0" encoding="UTF-8"?>', '')>
<cfreturn ReReplace(myContent, "[\r\n]+", "#Chr(10)#", "ALL")>

</cffunction>


</cfcomponent>