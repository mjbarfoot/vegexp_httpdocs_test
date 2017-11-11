/*******************************************************************************/
//	File:			/js/admin.js 										
//	Description: 	QS Audit Specific Admin Methods/Objects/Setup
// 	Author: 		Matt Barfoot - Clearview Webmedia Limited
//  Date:			25/07/2007
//  History: 			
/*******************************************************************************/ 

var selectHandler = {
 		init: function() {
 			var selectElements = document.getElementsByTagName('select');
 			for (var i=0;i<selectElements.length;i++) {
 				//event.addEvent(selectElements[i], "change", selectHandler.testMeth, false);	
 				eV.addEvent(selectElements[i], "change", selectHandler.enableButtons, false);	
 			}
 			
 			
 			var sFldUserID = document.getElementById('sFldUserID');
 			eV.addEvent(sFldUserID, "change", selectHandler.changeUserID, false);
 			
 			var fldSave = document.getElementById('fldSave');
 			eV.addEvent(fldSave, "click", selectHandler.save, false);
 			// ************************** IE HACK ******************************
 
 			
 			/*IE Fix for select elements created via DOM method in IE6 (Fixed in IE7)
 			 Select elements are not created with Multiple=true attribute therefore
 			 the value is not set.
 			 
 			 In this instance we need to allow a few milliseconds for IE to create the 
 			 elements before setting the attribute */
 			 
 			var s1 = document.getElementById('availRoles');
 			var s2 = document.getElementById('targetRoles');
 			s1.setAttribute("length","10");
 			s2.setAttribute("length","10");
 			s1.setAttribute("multiple","true");
 			s2.setAttribute("multiple","true");
 
 			
 			//Add Supplier Button - disable by default
 			var addButton = document.getElementById('addRole');
 			eV.addEvent(addButton, "click", selectHandler.disallowMove, false);
 			
			//Remove Supplier Button - disabled by default
 			var removeButton = document.getElementById('removeRole');
 			eV.addEvent(removeButton, "click", selectHandler.disallowMove, false);		
 			
 			//Add All Button - enabled by default
 			var addAllButton = document.getElementById('addAll');
 			eV.addEvent(addAllButton, "click", selectHandler.allowMove, false);
 			
 			//Remove All Button - enabled by default
 			var removeAllButton = document.getElementById('removeAll');
 			eV.addEvent(removeAllButton, "click", selectHandler.allowMove, false);
 		},
 		
 		
 		save: function(e) {
 			var target = window.event ? window.event.srcElement : e ? e.target : null;
			if (!target) target = e.srcElement;	
    		if (!target) return false;
 			
 			//construct the URL and refresh the tab
			var moduleid = 'admin';
			var tabid = 'supplier_authorisation';
			var action = 'user_supplier_save';
			var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid
			+ "&action=" + action;
			
			var qS = "suppliers=";
			var suppliers = document.getElementById('targetRoles');
			for(i=0; i<suppliers.options.length; i++) {
			    if (suppliers.options[i].value && suppliers.options[i].value!=null && suppliers.options[i].value!="") {
					qS += suppliers.options[i].value;
					if (i < suppliers.options.length-1) qS += ",";
			  	}
			 }	 
			
			
				
			AJAX_CLIENT.ShowLoadingDiv();
			
			var ajaxRequest = new AjaxRequest(myURL);
			ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);
		    ajaxRequest.setUsePOST();
		    ajaxRequest.setQueryString(qS);
		    ajaxRequest.addFormElements(document.getElementById('frmSecRoles'));
		    //ajaxRequest.setEchoDebugInfo()
		    ajaxRequest.sendRequest();	
 			
 			
 		},
 		
 		changeUserID: function(e) {
 			var target = window.event ? window.event.srcElement : e ? e.target : null;
			if (!target) target = e.srcElement;	
    		if (!target) return false;
 			
 			//construct the URL and refresh the tab
			var moduleid = 'admin';
			var tabid = 'supplier_authorisation';
			var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid;
				
			AJAX_CLIENT.ShowLoadingDiv();
			
			var ajaxRequest = new AjaxRequest(myURL);
			ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);
		    ajaxRequest.setUsePOST();
		    ajaxRequest.addFormElementsById('sFldUserID');
		    //ajaxRequest.setEchoDebugInfo()
		    ajaxRequest.sendRequest();	
 		
 		},
		
		disallowMove: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
		
		if (!target) {
    		target = e.srcElement;	
    	}
		
		if (!target) return false;
		
		return false;	
		},
		
		allowMove: function(e) {
			var target = window.event ? window.event.srcElement : e ? e.target : null;		
    		
    		if (!target) {
    		target = e.srcElement;	
    		}	
			
			if (!target) return;
			
			// is the button clicked the "AddRole" or "Remove Role"
			if (target.id == "addRole" || target.id == "addAll" ) {
				var from = document.getElementById('availRoles');
				var to = document.getElementById('targetRoles');	
			} else if (target.id == "removeRole" || target.id == "removeAll") {
				var from = document.getElementById('targetRoles');
				var to = document.getElementById('availRoles');		
			}		
			
			if (target.id.indexOf("All")==-1) {
				selectHandler.moveSelected(from, to);
				selectHandler.disableButtons();	
				selectHandler.enableButtons();					
			} else if (target.id.indexOf("All")!=-1) {
				selectHandler.moveAll(from, to);
				selectHandler.disableButtons();	
				selectHandler.enableButtons();			
			}

		},
		
		disableButtons: function() {
			var addButton = document.getElementById('addRole');
			var removeButton = document.getElementById('removeRole');	
	    	addButton.className="disabled";
	    	removeButton.className="disabled";
	    	eV.removeEvent(removeButton, "click", selectHandler.allowMove, false);
	    	eV.removeEvent(addButton, "click", selectHandler.allowMove, false);	
		 	eV.addEvent(removeButton, "click", selectHandler.disallowMove, false);	
			eV.addEvent(addButton, "click", selectHandler.disallowMove, false);	
		},
		
		enableButtons: function() {
			var from = document.getElementById('availRoles');
			var to = document.getElementById('targetRoles');
			var addButton = document.getElementById('addRole');
			var removeButton = document.getElementById('removeRole');
			var addAllButton = document.getElementById('addAll');
			var removeAllButton = document.getElementById('removeAll');
			
	   	 	// iterate through options in the "from" Select element
	   	 	 for(i=0; i<from.options.length; i++) {
			    if (from.options[i].selected && from.options[i].value!=null &&  from.options[i].value!="") {
			     //found a selected element. remove disallowMove and enable AddMove
			   		addButton.className="enabled";
			    	addAllButton.className="enabled";
			    	eV.removeEvent(addButton, "click", selectHandler.disallowMove, false);	
			    	eV.addEvent(addButton, "click", selectHandler.allowMove, false);	
			    	eV.removeEvent(addAllButton, "click", selectHandler.disallowMove, false);	
			    	eV.addEvent(addAllButton, "click", selectHandler.allowMove, false);
			    	// break the loop
			    	break;
			    } 			
	   	 	 }
	   	 	 
	   	 	 //iterate through the options in the "to" Select element
	   	 	  for(i=0; i<to.options.length; i++) {
			    if (to.options[i].selected) {
			     //found a selected element. remove disallowMove and enable AddMove
			   		removeButton.className="enabled";
			   		removeAllButton.className="enabled";
			    	eV.removeEvent(removeButton, "click", selectHandler.disallowMove, false);	
			    	eV.addEvent(removeButton, "click", selectHandler.allowMove, false);	
			    	eV.removeEvent(removeAllButton, "click", selectHandler.disallowMove, false);	
			    	eV.addEvent(removeAllButton, "click", selectHandler.allowMove, false);	
			    	// break the loop
			    	break;
			    } 			
	   	 	 }
	   	 	
	   	 	
	   	 	 			
		},

		cloneOption: function(option) {
		  var out = new Option(option.text,option.value);
		  
		  //if Admin add ID and Name attributes
		  /*if (option.value=="admin") {
			  out.setAttribute("id","admin");	
		  	  out.setAttribute("name","admin");		
		  }*/
		  
		  out.selected = option.selected;
		  out.defaultSelected = option.defaultSelected;
		  return out;
		},
			
		
		moveAll: function(from, to) {
			
			newTo = new Array();
			oldTo = new Array();
			
			 // existing To array has null options because size of select element is 6
			 // we don't want them so we create an array with only the elements which have values
			 for(i=0; i<to.options.length; i++) {
			    if (to.options[i].value) {
			    	oldTo[oldTo.length-1] = selectHandler.cloneOption(to.options[i]);
			    	oldTo[oldTo.length-1].selected = false;
			  	}
			 }	
		
						
			  //get the existing options from the "to" select element and add to the array
			  for(i=0; i<from.options.length; i++) {
			    newTo[newTo.length] = selectHandler.cloneOption(from.options[i]);
			    newTo[newTo.length-1].selected = false;
			  	
			  }
			  
			  from.options.length=0;
			
			//check for null elements 
			
			
			// if the "to" array has some options
			if (oldTo.length) {
				//zero length because we have a copy in the oldTo array
				to.options.length=0;
				
				// iterate over "oldTo" array adding options to "to" array			
			 	for(i=0; i<oldTo.length; i++) {
			    	for(x=0; x<newTo.length; i++) {
			    		//check the option value against options already selected
			    		if (oldTo[i].value == newTo[x].value) {
			    			break;
			    		} else {
			    			to.options[to.options.length] = oldTo[i];
			    		}
			  		}
			  	}
			 	
			 	// iterate over "newTo" array adding options to "to" array
			 	for(i=0; i<newTo.length; i++) {
			    	to.options[to.options.length] = newTo[i];
			  	}  // end for
			  	
			 } else {
			 	// no options in "to" array so just add everything 			 
			 	for(i=0; i<newTo.length; i++) {
			 		to.options[i] = newTo[i];
			 	}
			 } 
		},
		
		// * ---------/ Move selected Option from source select to target / -----------* //
		moveSelected: function(from, to) {
		
			  newTo = new Array();
			  var addSupplier=true;	
			  //get the elements select and now append		  
			  for(i=0; i<from.options.length; i++) {
			    if (from.options[i].selected) {
			      // iterate over the suppliers already existed to check we are not adding one
			      // that already exists
			      
			      // if adding from available suppliers/roles check whether role is already select
			      if (from.id=="availRoles") {
			      
			      		for (x=0; x<to.options.length; x++) {
			      			//if selected element already exists, ignore and break out of loop
			      			if (from.id=="availRoles" && from.options[i].value == to.options[x].value) {
			      				//alert("don't add");
			      				addSupplier=false;
			      				break;
			      			} //end if 
			      		}
			      	
			      		if (addSupplier) {
			      			newTo[newTo.length] = selectHandler.cloneOption(from.options[i]);
			      		}			      	
			      		
			      } else if (to.id=="availRoles") {
			      	//just remove option from selectedRoles
			     	from.options[i]=null;
				  }// end if "availRoles"
				} //end if option is selected
			    addSupplier=true;
			  }// end for
			 
			  //get the existing options from the "to" select element and add to the array
			  for(i=0; i<to.options.length; i++) {
			    newTo[newTo.length] = selectHandler.cloneOption(to.options[i]);
			
			    newTo[newTo.length-1].selected = false;
			  }
			
			 			 
			  to.options.length = 0;
			
			  for(i=0; i<newTo.length; i++) {
			    to.options[to.options.length] = newTo[i];
			  }
			  //selectHandler.selectionChanged(to,from);
		
		}	
  }



IPBlackList = {
		init: function() {
			var deleteButtons = document.getElementsByTagName('input');
 			for (var i=0;i<deleteButtons.length;i++) {
 				 if (deleteButtons[i].type=="submit") {
 					eV.addEvent(deleteButtons[i], "click", IPBlackList.IPremove, false);	
 				}
 			}
			
			//stop submission of forms by clicking enter in a text field			
			eV.addEvent(document.getElementById('frmIPBlackListEdit'), 'submit', ADMIN.stopSubmit, false);
			
		},
		
		IPremove: function(e) {
				var target = window.event ? window.event.srcElement : e ? e.target : null;
	   			if (!target) return;
				
				var ID = target.id.replace("delete_", ""); 
				
				//construct the URL and refresh the tab
				var moduleid = 'admin';
				var tabid = 'ip_blacklist';
				var action = 'ipblacklist_delete';
				var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid 
				+ '&action=' + action + '&id=' + ID;
					
				AJAX_CLIENT.ShowLoadingDiv();
				
				var ajaxRequest = new AjaxRequest(myURL);
				ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);
			    ajaxRequest.setUsePOST();
			    //ajaxRequest.setEchoDebugInfo()
				ajaxRequest.sendRequest();		
				AJAX_LINKS.stopBubble(target); 
				
		}
}


UserStats = {
			init: function() {
			var inputButtons = document.getElementsByTagName('input');
 			for (var i=0;i<inputButtons.length;i++) {
 				 if (inputButtons[i].type=="submit") {
 					eV.addEvent(inputButtons[i], "click", UserStats.save, false);	
 				}
 			}
			
			//stop submission of forms by clicking enter in a text field			
			eV.addEvent(document.getElementById('frmUserStats'), 'submit', ADMIN.stopSubmit, false);
			
		},


		save: function(e) {
				var target = window.event ? window.event.srcElement : e ? e.target : null;
	   			if (!target) return;
				
				
				if (target.id=="frmClear") {
					document.getElementById('userid').options.selectedIndex=0;
					document.getElementById('fldevent').options.selectedIndex=0;
					document.getElementById('year').options.selectedIndex=0;
					document.getElementById('month').options.selectedIndex=0;
					document.getElementById('day').options.selectedIndex=0;
				
				}
				
				//construct the URL and refresh the tab
				var moduleid = 'stats';
				var tabid = 'user_log';
				var action = 'user_log_filter';
				var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid 
				+ '&action=' + action;
					
				AJAX_CLIENT.ShowLoadingDiv();
				
				var ajaxRequest = new AjaxRequest(myURL);
				ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);
			    ajaxRequest.setUsePOST();
			    ajaxRequest.addFormElements(document.getElementById('frmUserStats'));
			    //ajaxRequest.setEchoDebugInfo();
				ajaxRequest.sendRequest();		
				AJAX_LINKS.stopBubble(target); 
				
		},
		
		error_handler: function() {
			alert(getXMLHttpRequestObject().status);
		}
		
		
}

ADMIN = {
		
	init: function() {
			
			if (document.getElementById('frmSecRoles')) {
					selectHandler.init();
			}
			
			
			if (document.getElementById('frmIPBlackListEdit')) {
			 IPBlackList.init();
			 }
			
			if (document.getElementById('frmUserStats')) {
			 UserStats.init();
			 }
			
			
			//Edit buttons
			if (document.getElementById('frmUserEdit')) {
				var edit_buttons = document.getElementById('frmUserEdit').getElementsByTagName('input');
				for (var i=0; i<edit_buttons.length; i++) {
					if (edit_buttons[i].type=="submit") {
					eV.addEvent(edit_buttons[i], 'click', ADMIN.editUser, false);
					}
				} 
			
				//stop submission of forms by clicking enter in a text field
				eV.addEvent(document.getElementById('frmUserEdit'), 'submit', ADMIN.stopSubmit, false);
			}
			
			// Add buttons
			if (document.getElementById('frmUserAdd')) {
				var add_button = document.getElementById('frmUserAdd').getElementsByTagName('input');	
				for (var i=0; i<add_button.length; i++) {
					if (add_button[i].type=="submit") {
					eV.addEvent(add_button[i], 'click', ADMIN.addUser, false);
					}
				} 
				
				//stop submission of forms by clicking enter in a text field			
				eV.addEvent(document.getElementById('frmUserAdd'), 'submit', ADMIN.stopSubmit, false);
			}	
	},

	stopSubmit: function(e) {
		var frm = window.event ? window.event.srcElement : e ? e.target : null;
		if (!frm) return;
				 				
		// stop the event propogating and causing the form submit event to fire
		if (e && e.stopPropagation && e.preventDefault) {
			e.stopPropagation();
			e.preventDefault();
		}
				      
		if (window.event) {
			window.event.cancelBubble = true;
			window.event.returnValue = false;
		}
	
	},
	
	addUser: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return;
		
		var UserID = "";
		var action = "user_add";
		
		
		//construct the URL and refresh the tab
		var moduleid = 'admin';
		var tabid = 'users';
		var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action;
			
		AJAX_CLIENT.ShowLoadingDiv();
		
		var ajaxRequest = new AjaxRequest(myURL);
		ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);
	    ajaxRequest.setUsePOST();
	    ajaxRequest.addFormElements(document.getElementById('frmUserAdd'));
	    //ajaxRequest.setEchoDebugInfo()
		ajaxRequest.sendRequest();		

		AJAX_LINKS.stopBubble(target);   	 
	},

	editUser: function(e) {
		var target = window.event ? window.event.srcElement : e ? e.target : null;
	    if (!target) return;	
	    var UserID = "";
	    var action = "";
	    
	    //get the userid
	    switch (target.value) {
	    	case "delete":		 UserID = target.id.replace("delete_", ""); 		
	  							 action = "user_delete"; 			
	    						 break;
	    	case "save": 		 UserID = target.id.replace("save_", ""); 	
	    						 action = "user_save"; 
	    						 break;
	    	case "Yes - Remove": UserID = target.id.replace("remove_ipblacklist_", ""); 	
	    						 action = "user_whitelistIP"; 
	    						 break;														
	    	default:			
	    						 break;
	    }
	   
	    //construct the URL and refresh the tab
		var moduleid = 'admin';
		var tabid = 'users';
		var myURL = AppVars.reqURL + '?reqtype=tab&moduleid=' + moduleid + '&tabid=' + tabid 
		+ '&action=' + action + '&UserID=' + UserID;
			
		AJAX_CLIENT.ShowLoadingDiv();
		
		var ajaxRequest = new AjaxRequest(myURL);
		ajaxRequest.setPostRequest(AJAX_CLIENT.HideLoadingDiv);
	    ajaxRequest.setUsePOST();
	    ajaxRequest.addFormElements(document.getElementById('frmUserEdit'));
	    //ajaxRequest.setQueryString();
	    //ajaxRequest.setEchoDebugInfo()
		ajaxRequest.sendRequest();		

		AJAX_LINKS.stopBubble(target);    
	}
}


