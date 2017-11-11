   var rF = {
   	setCompType: function(compType) {
   		if (compType == "contract") {
   			document.getElementById('fldContractCompany').style.display="inline";   			
   			var newLabelTxt = document.createTextNode("Client company: *");
   			document.getElementById('lblCientCompany').replaceChild(newLabelTxt, document.getElementById('lblCientCompany').firstChild);
   		
   		} else if (compType == "independent") {
   			document.getElementById('fldContractCompany').style.display="none";
   			var newLabelTxt = document.createTextNode("Company name: *");
   			document.getElementById('lblCientCompany').replaceChild(newLabelTxt, document.getElementById('lblCientCompany').firstChild);
   		} else {
   		return;	
   		}   			
   	}
   }