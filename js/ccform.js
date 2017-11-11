var useDelAddressToggle=false;

var CCfrm = {
		useDelAddress: function() {
		
		if (!useDelAddressToggle) {
				 document.getElementById("billBuilding").value=document.getElementById("delbuilding").value;
                  document.getElementById("billLine1").value=document.getElementById("delline1").value;
                  document.getElementById("billLine2").value=document.getElementById("delline2").value;
                  document.getElementById("billLine3").value=document.getElementById("delline3").value;
                  document.getElementById("billTown").value=document.getElementById("deltown").value;
                  document.getElementById("billCounty").value=document.getElementById("delcounty").value;
                  document.getElementById("billPostcode").value=document.getElementById("delpostcode").value;
			useDelAddressToggle=true;
		} else {
				 document.getElementById("billBuilding").value="";
                  document.getElementById("billLine1").value="";
                  document.getElementById("billLine2").value="";
                  document.getElementById("billLine3").value="";
                  document.getElementById("billTown").value="";
                  document.getElementById("billCounty").value="";
                  document.getElementById("billPostcode").value="";
             useDelAddressToggle=false;     
		}
		
    }, //end function
    
    chkStartDate: function() {
    	var startDate = document.getElementById('start_date').value;
    	var issueNumber = document.getElementById('issue').value;
    	
    	if ((startDate == "" || startDate ==null) && (issueNumber == "" || issueNumber ==null)) {
    	alert("You enter either a start date or an issue number depending on your card type");
    	return false;
    	}
    	
    }
} // end object