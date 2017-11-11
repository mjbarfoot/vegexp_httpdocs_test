var fReq = {
	init: function(frmName) {
		if (!document.getElementById(frmName)) {
			return;
		}
		
		
		var customerPOfield = document.getElementById('customerPO');
		
		if (customerPOfield) {
					
			var submitBtn1 = document.getElementById('frmSubmitCheckOut1');
			if (submitBtn1) {
				eV.addEvent(submitBtn1,'click', fReq.checkCustomerPO, false);
			}
			
			var submitBtn2 = document.getElementById('frmSubmitCheckOut2');
			if (submitBtn2) {
				eV.addEvent(submitBtn2,'click', fReq.checkCustomerPO, false);
			}
		}
	},
	
	checkCustomerPO: function(e) {
		
		var target = window.event ? window.event.srcElement : e ? e.target : null;

		
		if (!target) return;
	    
	    
	    var customerPOfield = document.getElementById('customerPO');
	    
	    if (customerPOfield) {
	    	if (customerPOfield.value == "" || customerPOfield ==null)  {
	    		alert("Please enter a customer PO reference before checking out. Thanks.");
	  		  // stop the event propogating and causing the form submit event to fire
				  if (e && e.stopPropagation && e.preventDefault) {
			        e.stopPropagation();
			        e.preventDefault();
			      }
			      
			      if (window.event) {
			        window.event.cancelBubble = true;
			        window.event.returnValue = false;
			      }
	    	}
	    }
	}
	
	
}

var fBg = {
	init: function(frmName) {
		
		//other related pages to the registration process may not contain the form
		//test for existinence, if not present do nothing
		if (!document.getElementById(frmName)) {
		return;
		}
		
		//add the event listeners
		var inputFields = document.getElementById(frmName).getElementsByTagName('input');
		
		//iterate through them and add the listener event clickNav
		for (var i = 0; i < inputFields.length; i++) {
	     
	  	      eV.addEvent(inputFields[i], 'focus', fBg.focusBG, false);
		      inputFields[i].onfocus = function() { return false; }; // Safari
		      
		      eV.addEvent(inputFields[i], 'blur', fBg.blurBG, false);
		      inputFields[i].onblur = function() { return false; }; // Safari 
	    	
	    }
	 		
	},
	
	focusBG: function(e) {
	var target = window.event ? window.event.srcElement : e ? e.target : null;
    if (!target) return;
	
	target.style.color="Black";
	//target.style.borderColor="Black";
	//target.style.background="White";
	
	},
	
	blurBG: function(e) {
    var target = window.event ? window.event.srcElement : e ? e.target : null;
    if (!target) return;
	
	target.style.color="#177730";
	//target.style.borderColor="#7F9DB9";
	//target.style.background="#2E2E2E";
	
	}
}