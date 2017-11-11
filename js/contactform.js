/*******************************************************************************/
//	File:			/js/contactform.js 										
//	Description: 	Contact form preference validation
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			26/06/06
//  History: 		
/*******************************************************************************/ 


var CONTfrm = {
	chkPref: function() {
			// is the form loaded?
			if (!document.getElementById('contactPref')) return; 	
	
			var chkBox = document.getElementsByName('contactPref'); 
						
			
			// is one of them checked
			if (chkBox[0].checked || chkBox[1].checked) {
			
				// phone preference checked
				if (chkBox[0].checked) {
					
					// is a phone number supplied?
					if (document.getElementById('telnum').value.length == 0 || document.getElementById('telnum').value == null || document.getElementById('telnum').value=="") {
						alert("You have selected you wished to be contacted by phone, but have not entered a phone number. \n\nPlease could you enter your telephone number.");
						return false;
					} else {
						return true;
					} 
					
				} 
				// email preference checked
				else if (chkBox[1].checked) {
				
					//email address supplied?
					if (document.getElementById('emailAddress').value.length == 0 || document.getElementById('emailAddress').value == null || document.getElementById('emailAddress').value=="") {
						alert("You have selected you wished to be contacted by email, but have not entered an email address. \n\nPlease could you enter your email address.");
						return false;
					} else {
						return true;
					} 
				
				
				
				}		
			} 
			
			// nothing checked 
			else {
				alert("Please indicate your contact preference by selecting Phone or Email");
				return false;
			}
			
	}
}